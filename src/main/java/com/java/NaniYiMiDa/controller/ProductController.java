package com.java.NaniYiMiDa.controller;

import com.java.NaniYiMiDa.service.ProductService;
import com.java.NaniYiMiDa.vo.ProductVO;
import com.java.NaniYiMiDa.vo.ResultVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    @Autowired
    private ProductService productService;

    @GetMapping("/{id}")
    public ResultVO<ProductVO> getProduct(@PathVariable int id) {
        ProductVO product = productService.getProductById(id);
        if (product == null) {
            return ResultVO.buildFailure("Product not found");
        }
        return ResultVO.buildSuccess(product);
    }
}