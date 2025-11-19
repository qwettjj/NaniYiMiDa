package com.java.NaniYiMiDa.repository;

import com.java.NaniYiMiDa.po.recipe.RecipeStep;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RecipeStepRepository extends JpaRepository<RecipeStep, Long> {
}

