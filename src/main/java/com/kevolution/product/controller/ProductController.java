package com.kevolution.product.controller;

import com.kevolution.product.entity.Category;
import com.kevolution.product.entity.Product;
import com.kevolution.product.repository.CategoryRepository;
import com.kevolution.product.service.ProductService;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@Controller
@RequiredArgsConstructor
public class ProductController {

    private static final int ADMIN_PAGE_SIZE = 20;

    private final ProductService productService;
    private final CategoryRepository categoryRepository;

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

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
        RedirectAttributes ra
    ) {
        try {
            String imageUrl = saveImageFile(imageFile);
            productService.createProduct(categoryId, name, price, stock, description, imageUrl);
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
        @RequestParam(required = false) String existingImageUrl,
        RedirectAttributes ra
    ) {
        try {
            String imageUrl = (imageFile != null && !imageFile.isEmpty())
                ? saveImageFile(imageFile)
                : existingImageUrl;
            productService.updateProduct(productId, categoryId, name, price, stock, description, imageUrl);
            ra.addFlashAttribute("successMsg", "상품이 수정되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMsg", "수정 중 오류가 발생했습니다: " + e.getMessage());
        }
        return "redirect:/admin/products";
    }

    @PostMapping("/admin/products/{productId}/delete")
    public String delete(@PathVariable Long productId, RedirectAttributes ra) {
        productService.deleteProduct(productId);
        ra.addFlashAttribute("successMsg", "상품이 삭제되었습니다.");
        return "redirect:/admin/products";
    }

    private String saveImageFile(MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) return null;
        String ext = StringUtils.getFilenameExtension(file.getOriginalFilename());
        String filename = UUID.randomUUID() + (ext != null ? "." + ext : "");
        Path dir = Paths.get(uploadDir, "products");
        Files.createDirectories(dir);
        Files.copy(file.getInputStream(), dir.resolve(filename));
        return "/uploads/products/" + filename;
    }
}
