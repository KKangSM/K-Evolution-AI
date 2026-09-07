package com.kevolution.product.controller;

import com.kevolution.product.dto.ProductOptionForm;
import com.kevolution.product.entity.Category;
import com.kevolution.product.entity.Product;
import com.kevolution.product.service.ProductService;
import com.kevolution.review.service.ReviewService;
import com.kevolution.storage.SupabaseStorageService;
import com.kevolution.wishlist.service.WishlistService;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.ArrayList;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;
    private final SupabaseStorageService storageService;
    private final WishlistService wishlistService;
    private final ReviewService reviewService;

    // ── 공개 조회 ─────────────────────────────────
    @GetMapping("/products")
    public String list(
        @RequestParam(required = false) String keyword,
        @RequestParam(required = false) String category,
        @RequestParam(defaultValue = "0") int page,
        Model model
    ) {
        // 잘못된 카테고리 값은 null(전체)로 처리 — URL 조작으로 400 나지 않게
        Category selected = Category.fromNameOrNull(category);
        Page<Product> products = productService.getProducts(keyword, selected, PageRequest.of(page, 12));

        model.addAttribute("products", products);
        model.addAttribute("stockMap", productService.getStockMap(products.getContent()));
        model.addAttribute("keyword", keyword);
        model.addAttribute("category", selected);
        model.addAttribute("currentPage", page);
        return "products/list";
    }

    @GetMapping("/products/{productId}")
    public String detail(@PathVariable Long productId,
                         @AuthenticationPrincipal UserDetails user,
                         Model model) {
        Product product = productService.getProduct(productId);
        model.addAttribute("product", product);
        model.addAttribute("images", productService.getProductImages(productId));
        model.addAttribute("optionGroups", productService.getProductOptionsGrouped(productId));
        model.addAttribute("totalStock", productService.getTotalStock(product));
        model.addAttribute("wished", wishlistService.isWished(user == null ? null : user.getUsername(), product));
        model.addAttribute("wishCount", wishlistService.count(product));
        model.addAttribute("reviews", reviewService.getProductReviews(product, PageRequest.of(0, 20)).getContent());
        model.addAttribute("reviewCount", reviewService.countByProduct(product));
        model.addAttribute("reviewAvg", reviewService.averageRating(product));
        model.addAttribute("reviewSummary", reviewService.getReviewSummary(product));
        return "products/detail";
    }

    // ── 관리자 관리 (/admin/** = ROLE_ADMIN) ──────────
    @GetMapping("/admin/products")
    public String adminList(
        @RequestParam(required = false) String search,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int pageSize,
        Model model
    ) {
        Page<Product> products = productService.getProducts(search, null, PageRequest.of(page, pageSize));
        model.addAttribute("activeMenu", "products");
        model.addAttribute("products", products);
        model.addAttribute("stockMap", productService.getStockMap(products.getContent()));
        return "admin/products/list";
    }

    @GetMapping("/admin/products/register")
    public String registerForm(Model model) {
        model.addAttribute("activeMenu", "products");
        return "admin/products/form";
    }

    @PostMapping("/admin/products/register")
    public String register(
        @RequestParam(required = false) String category,
        @RequestParam String name,
        @RequestParam int price,
        @RequestParam(required = false) String description,
        @RequestParam(required = false) MultipartFile imageFile,
        @RequestParam(required = false) List<MultipartFile> detailImages,
        @RequestParam(required = false) List<String> optionNames,
        @RequestParam(required = false) List<String> optionValues,
        @RequestParam(required = false) List<String> optionStocks,
        RedirectAttributes ra
    ) {
        try {
            String imageUrl = uploadImage(imageFile);
            List<String> detailUrls = uploadImages(detailImages);
            List<ProductOptionForm> options = buildOptions(optionNames, optionValues, optionStocks);
            productService.createProduct(Category.fromNameOrNull(category), name, price, description, imageUrl, detailUrls, options);
            ra.addFlashAttribute("successMsg", "상품이 등록되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "등록 중 오류가 발생했습니다: " + e.getMessage());
        }
        return "redirect:/admin/products";
    }

    @GetMapping("/admin/products/{productId}/edit")
    public String editForm(@PathVariable Long productId, Model model) {
        model.addAttribute("activeMenu", "products");
        model.addAttribute("product", productService.getProduct(productId));
        model.addAttribute("images", productService.getProductImages(productId));
        model.addAttribute("options", productService.getProductOptions(productId));
        return "admin/products/form";
    }

    @PostMapping("/admin/products/{productId}/edit")
    public String edit(
        @PathVariable Long productId,
        @RequestParam(required = false) String category,
        @RequestParam String name,
        @RequestParam int price,
        @RequestParam(required = false) String description,
        @RequestParam(required = false) MultipartFile imageFile,
        @RequestParam(required = false) List<MultipartFile> detailImages,
        @RequestParam(required = false) String existingImageUrl,
        @RequestParam(required = false) List<String> optionNames,
        @RequestParam(required = false) List<String> optionValues,
        @RequestParam(required = false) List<String> optionStocks,
        RedirectAttributes ra
    ) {
        try {
            boolean replaceThumbnail = (imageFile != null && !imageFile.isEmpty());
            String imageUrl = replaceThumbnail ? uploadImage(imageFile) : existingImageUrl;
            List<String> detailUrls = uploadImages(detailImages);
            List<ProductOptionForm> options = buildOptions(optionNames, optionValues, optionStocks);
            productService.updateProduct(productId, Category.fromNameOrNull(category), name, price, description, imageUrl, detailUrls, options);
            // 대표 이미지를 새로 올렸다면 교체된 옛 파일을 Storage 에서 정리한다.
            if (replaceThumbnail && existingImageUrl != null && !existingImageUrl.isBlank()) {
                storageService.deleteByPublicUrl(existingImageUrl);
            }
            ra.addFlashAttribute("successMsg", "상품이 수정되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "수정 중 오류가 발생했습니다: " + e.getMessage());
        }
        return "redirect:/admin/products";
    }

    @PostMapping("/admin/products/{productId}/delete")
    public String delete(@PathVariable Long productId, RedirectAttributes ra) {
        try {
            List<String> imageUrls = productService.deleteProduct(productId);
            imageUrls.forEach(storageService::deleteByPublicUrl); // Storage 파일도 정리
            ra.addFlashAttribute("successMsg", "상품이 삭제되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "삭제 중 오류가 발생했습니다: " + e.getMessage());
        }
        return "redirect:/admin/products";
    }

    /** 이미지 한 장을 Supabase Storage 에 올리고 공개 URL 을 돌려준다. (빈 파일이면 null) */
    private String uploadImage(MultipartFile file) {
        if (file == null || file.isEmpty()) return null;
        return storageService.upload(file, "product");
    }

    /** 여러 이미지를 Supabase Storage 에 올리고 공개 URL 목록을 돌려준다. (빈 파일은 건너뜀) */
    private List<String> uploadImages(List<MultipartFile> files) {
        List<String> urls = new ArrayList<>();
        if (files == null) return urls;
        for (MultipartFile file : files) {
            String url = uploadImage(file);
            if (url != null) urls.add(url);
        }
        return urls;
    }

    /** 폼의 옵션 입력(병렬 배열)을 옵션 폼 DTO 목록으로 묶는다. 빈 행은 서비스에서 걸러진다. */
    private List<ProductOptionForm> buildOptions(List<String> names, List<String> values, List<String> stocks) {
        List<ProductOptionForm> options = new ArrayList<>();
        if (names == null) return options;
        for (int i = 0; i < names.size(); i++) {
            options.add(new ProductOptionForm(
                names.get(i),
                itemAt(values, i),
                parseIntOrZero(itemAt(stocks, i))
            ));
        }
        return options;
    }

    private String itemAt(List<String> list, int index) {
        return (list != null && index < list.size()) ? list.get(index) : null;
    }

    private int parseIntOrZero(String value) {
        if (value == null || value.isBlank()) return 0;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
