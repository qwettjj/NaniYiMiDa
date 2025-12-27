package com.java.NaniYiMiDa.service;

import com.java.NaniYiMiDa.enumx.IngredientEnum;
import com.java.NaniYiMiDa.vo.recipe.RecipeIngredientVO;
import com.java.NaniYiMiDa.vo.recipe.RecipeStepVO;
import com.java.NaniYiMiDa.vo.recipe.RecipeVO;

import java.util.Date;
import java.util.List;

public interface RecipeService {

	Long createRecipeDraft(String title);

	Void modifyRecipeTitle(Long recipeId, String title);

	Void modifyRecipeDescription(Long recipeId, String description);

	Void publishRecipeDraft(Long recipeId);

	Void deleteRecipe(Long recipeId);

	Void hideRecipe(Long recipeId);

	RecipeVO addRecipeStep(Long recipeId, Integer index, RecipeStepVO stepVO);

	RecipeVO modifyRecipeStep(Long recipeId, Long stepId, RecipeStepVO stepVO);

	RecipeVO deleteRecipeStep(Long recipeId, Long stepId);

	RecipeVO swapRecipeSteps(Long recipeId, Integer firstIndex, Integer secondIndex);

	RecipeIngredientVO modifyRecipeIngredient(Long recipeId, String description);

	RecipeIngredientVO setRecipeIngredientTag(Long recipeId, IngredientEnum ingredient);

	org.springframework.data.domain.Page<RecipeVO> searchRecipes(String keyword, Date startDate,
			com.java.NaniYiMiDa.enumx.IngredientEnum tag, org.springframework.data.domain.Pageable pageable);

	org.springframework.data.domain.Page<RecipeVO> getRecentRecipes(Date startDate,
			org.springframework.data.domain.Pageable pageable);

	org.springframework.data.domain.Page<RecipeVO> getUserRecipesById(Long userId, Date startDate,
			org.springframework.data.domain.Pageable pageable);

	List<RecipeVO> getCurrentUserDraft();

	RecipeVO getRecipeById(Long recipeId);
}
