package com.java.NaniYiMiDa.po;

import com.java.NaniYiMiDa.enumx.IngredientEnum;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "products")
public class product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_id")
    private int productId;

    @Basic
    @Column(name = "product_name")
    private String productName;

    @Enumerated(EnumType.STRING)
    @Column(name = "ingredient")
    private IngredientEnum ingredient;

    @Basic
    @Column(name = "producer")
    private String producer;

    @Basic
    @Column(name = "description")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "allergen")
    private IngredientEnum allergen;

    @Enumerated(EnumType.STRING)
    @Column(name = "nutrition")
    private IngredientEnum nutrition;
}
