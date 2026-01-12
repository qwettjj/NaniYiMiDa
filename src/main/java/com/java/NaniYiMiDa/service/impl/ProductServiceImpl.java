package com.java.NaniYiMiDa.service.impl;

import com.java.NaniYiMiDa.po.product;
import com.java.NaniYiMiDa.repository.ProductRepository;
import com.java.NaniYiMiDa.service.ProductService;
import com.java.NaniYiMiDa.vo.ProductVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ProductServiceImpl implements ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Override
    public ProductVO getProductById(int id) {
        product p = productRepository.findById(id).orElse(null);
        if (p == null) {
            return null;
        }
        ProductVO vo = new ProductVO();
        vo.setProductId(p.getProductId());
        vo.setProductName(p.getProductName());
        vo.setIngredient(p.getIngredient());
        vo.setProducer(p.getProducer());
        vo.setDescription(p.getDescription());
        vo.setAllergen(p.getAllergen());
        vo.setNutrition(p.getNutrition());
        return vo;
    }
}