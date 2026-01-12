package com.java.NaniYiMiDa.repository;

import com.java.NaniYiMiDa.po.product;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductRepository extends JpaRepository<product, Integer> {
}