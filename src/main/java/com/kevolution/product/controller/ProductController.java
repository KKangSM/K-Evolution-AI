package com.kevolution.product.controller;

import com.kevolution.product.entity.Category;
import com.kevolution.product.entity.Product;
import com.kevolution.product.repository.CategoryRepository;
import com.kevolution.product.service.ProductService;
import com.kevolution.storage.SupabaseStorageService;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
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

    private static final int ADMIN_PAGE_SIZE = 20;
    private static final String IMAGE_FOLDER = "product";  // Supabase Storage 내 폴더

    private final ProductService productService;
    private final CategoryRepository categoryRepository;
    private final SupabaseStorageService storageService;

    // ── 공개 조회 ─────────────────────────────────
    @GetMapping("/products")
    public String list(
        @RequestParam(required = false) String keyword,
        @RequestParam(required = false) Long categoryId,
        @RequestParam(defaultValue = "0") int page,
        Model model
    ) {
        Page<Product> products = productService.getProducts(keyword, categoryId, PageRequest.of(page, 12));
        List<Category> categories = categoryRepository.findAll();

        model.addAttribute("products", products);
        model.addAttribute("categories", categories);
        model.addAttribute("keyword", keyword);
        model.addAttribute("categoryId", categoryId);
        model.addAttribute("currentPage", page);
        return "products/list";
    }

    @GetMapping("/products/{productId}")
    public String detail(@PathVariable Long productId, Model model) {
        model.addAttribute("product", productService.getProduct(productId));
        model.addAttribute("images", productService.getProductImages(productId));
        return "products/detail";
    }

    // ── 관리자 관리 (/admin/** = ROLE_ADMIN) ──────────
    @GetMapping("/admin/products")
    public String adminList(
        @RequestParam(required = false) String keyword,
        @RequestParam(defaultValue = "0") int page,
        Model model
    ) {
        Page<Product> products = productService.getProducts(keyword, null, PageRequest.of(page, ADMIN_PAGE_SIZE));
        model.addAttribute("activeMenu", "products");
        model.addAttribute("products", products);
        model.addAttribute("keyword", keyword);
        model.addAttribute("currentPage", page);
        return "admin/products/list";
    }

    @GetMapping("/admin/products/register")
    public String registerForm(Model model) {
        model.addAttribute("activeMenu", "products");
        model.addAttribute("categories", categoryRepository.findAll());
        return "admin/products/form";
    }

    @PostMapping("/admin/products/register")
    public String register(
        @RequestParam(required = false) Long categoryId,
        @RequestParam String name,
        @RequestParam int price,
        @RequestParam int stock,
        @RequestParam(required = false) String description,
        @RequestParam(required = false) MultipartFile imageFile,
        @RequestParam(required = false) List<MultipartFile> detailImages,
        RedirectAttributes ra
    ) {
        try {
            String imageUrl = uploadImage(imageFile);
            List<String> detailUrls = uploadImages(detailImages);
            productService.createProduct(categoryId, name, price, stock, description, imageUrl, detailUrls);
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
        model.addAttribute("categories", categoryRepository.findAll());
        return "admin/products/form";
    }

    @PostMapping("/admin/products/{productId}/edit")
    public String edit(
        @PathVariable Long productId,
        @RequestParam(required = false) Long categoryId,
        @RequestParam String name,
        @RequestParam int price,
        @RequestParam int stock,
        @RequestParam(required = false) String description,
        @RequestParam(required = false) MultipartFile imageFile,
        @RequestParam(required = false) List<MultipartFile> detailImages,
        @RequestParam(required = false) String existingImageUrl,
        RedirectAttributes ra
    ) {
        try {
            boolean replaceThumbnail = (imageFile != null && !imageFile.isEmpty());
            String imageUrl = replaceThumbnail ? uploadImage(imageFile) : existingImageUrl;
            List<String> detailUrls = uploadImages(detailImages);
            productService.updateProduct(productId, categoryId, name, price, stock, description, imageUrl, detailUrls);
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
        return storageService.upload(file, IMAGE_FOLDER);
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
}
