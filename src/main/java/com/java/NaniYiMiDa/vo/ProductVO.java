package com.java.NaniYiMiDa.vo;

import com.java.NaniYiMiDa.enumx.IngredientEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProductVO {

    private int productId;

    private String productName;

    private IngredientEnum ingredient;

    private String producer;

    private String description;

    private IngredientEnum allergen;

    private IngredientEnum nutrition;
}