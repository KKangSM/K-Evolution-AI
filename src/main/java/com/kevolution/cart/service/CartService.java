package com.kevolution.cart.service;

import com.kevolution.cart.entity.Cart;
import com.kevolution.cart.entity.CartItem;
import com.kevolution.cart.repository.CartItemRepository;
import com.kevolution.cart.repository.CartRepository;
import com.kevolution.member.entity.Member;
import com.kevolution.member.repository.MemberRepository;
import com.kevolution.product.entity.Product;
import com.kevolution.product.repository.ItemOptionRepository;
import com.kevolution.product.repository.ProductRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CartService {

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;
    private final ItemOptionRepository itemOptionRepository;
    private final MemberRepository memberRepository;

    public Member getMember(String userId) {
        return memberRepository.findByUserId(userId)
            .orElseThrow(() -> new IllegalStateException("회원 정보를 찾을 수 없습니다."));
    }

    public Cart getCart(Member member) {
        return cartRepository.findByMember(member)
            .orElseGet(() -> cartRepository.save(Cart.builder().member(member).build()));
    }

    @Transactional
    public void addItem(String userId, Long productId, int quantity) {
        Member member = getMember(userId);
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new IllegalArgumentException("상품을 찾을 수 없습니다."));

        if (itemOptionRepository.sumStockByProduct(product) == 0) {
            throw new IllegalStateException("품절된 상품입니다.");
        }

        Cart cart = getCart(member);
        cartItemRepository.findByCartAndProduct(cart, product)
            .ifPresentOrElse(
                item -> item.updateQuantity(item.getQuantity() + quantity),
                () -> cartItemRepository.save(
                    CartItem.builder().cart(cart).product(product).quantity(quantity).build())
            );
    }

    @Transactional
    public void updateQuantity(String userId, Long cartItemId, int quantity) {
        CartItem item = getCartItemWithOwnerCheck(userId, cartItemId);
        if (quantity <= 0) {
            cartItemRepository.delete(item);
        } else {
            item.updateQuantity(quantity);
        }
    }

    @Transactional
    public void removeItem(String userId, Long cartItemId) {
        cartItemRepository.delete(getCartItemWithOwnerCheck(userId, cartItemId));
    }

    /** 결제 완료 후 장바구니 비우기 (orphanRemoval 로 항목 삭제) */
    @Transactional
    public void clearCart(String userId) {
        Cart cart = getCart(getMember(userId));
        cart.getCartItems().clear();
    }

    private CartItem getCartItemWithOwnerCheck(String userId, Long cartItemId) {
        CartItem item = cartItemRepository.findById(cartItemId)
            .orElseThrow(() -> new IllegalArgumentException("장바구니 항목을 찾을 수 없습니다."));
        if (!item.getCart().getMember().getUserId().equals(userId)) {
            throw new IllegalStateException("권한이 없습니다.");
        }
        return item;
    }
}
