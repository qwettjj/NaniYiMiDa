package com.java.NaniYiMiDa.repository;

import com.java.NaniYiMiDa.po.recipe.RecipeIngredient;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RecipeIngredientRepository extends JpaRepository<RecipeIngredient, Long> {
	Optional<RecipeIngredient> findByRecipe_RecipeId(Long recipeId);
}

