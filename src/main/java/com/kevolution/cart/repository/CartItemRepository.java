package com.kevolution.cart.repository;

import com.kevolution.cart.entity.Cart;
import com.kevolution.cart.entity.CartItem;
import com.kevolution.product.entity.Product;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface CartItemRepository extends JpaRepository<CartItem, Long> {
    Optional<CartItem> findByCartAndProduct(Cart cart, Product product);
}
