package com.java.NaniYiMiDa.controller;

import com.java.NaniYiMiDa.enumx.IngredientEnum;
import com.java.NaniYiMiDa.po.recipe.Recipe;
import com.java.NaniYiMiDa.service.RecipeService;
import com.java.NaniYiMiDa.vo.recipe.RecipeIngredientVO;
import com.java.NaniYiMiDa.vo.recipe.RecipeStepVO;
import com.java.NaniYiMiDa.vo.recipe.RecipeVO;
import com.java.NaniYiMiDa.vo.ResultVO;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/recipes")
public class RecipeController {

	@Autowired
	private RecipeService recipeService;

	@PostMapping("/create")
	public ResultVO<Long> createRecipeDraft(@RequestParam String title) {
		return ResultVO.buildSuccess(recipeService.createRecipeDraft(title));
	}

	@PutMapping("/{recipeId}/title")
	public ResultVO<Void> modifyRecipeTitle(@PathVariable Long recipeId, @RequestParam String title) {
		return ResultVO.buildSuccess(recipeService.modifyRecipeTitle(recipeId, title));
	}

	@PutMapping("/{recipeId}/description")
	public ResultVO<Void> modifyRecipeDescription(@PathVariable Long recipeId, @RequestParam String description) {
		return ResultVO.buildSuccess(recipeService.modifyRecipeDescription(recipeId, description));
	}

	@PostMapping("/{recipeId}/publish")
	public ResultVO<Void> publishRecipe(@PathVariable Long recipeId) {
		return ResultVO.buildSuccess(recipeService.publishRecipeDraft(recipeId));
	}

	@PostMapping("/{recipeId}/hide")
	public ResultVO<Void> hideRecipe(@PathVariable Long recipeId) {
		return ResultVO.buildSuccess(recipeService.hideRecipe(recipeId));
	}

	@DeleteMapping("/{recipeId}")
	public ResultVO<Void> deleteRecipe(@PathVariable Long recipeId) {
		return ResultVO.buildSuccess(recipeService.deleteRecipe(recipeId));
	}

	@PostMapping("/{recipeId}/steps")
	public ResultVO<RecipeVO> addRecipeStep(@PathVariable Long recipeId,
											@RequestParam(value = "index", required = false) Integer index,
											@RequestBody RecipeStepVO stepVO) {
		return ResultVO.buildSuccess(recipeService.addRecipeStep(recipeId, index, stepVO));
	}

	@PutMapping("/{recipeId}/steps/{stepId}")
	public ResultVO<RecipeVO> modifyRecipeStep(@PathVariable Long recipeId,
											   @PathVariable Long stepId,
											   @RequestBody RecipeStepVO stepVO) {
		return ResultVO.buildSuccess(recipeService.modifyRecipeStep(recipeId, stepId, stepVO));
	}

	@DeleteMapping("/{recipeId}/steps/{stepId}")
	public ResultVO<RecipeVO> deleteRecipeStep(@PathVariable Long recipeId, @PathVariable Long stepId) {
		return ResultVO.buildSuccess(recipeService.deleteRecipeStep(recipeId, stepId));
	}

	@PostMapping("/{recipeId}/steps/swap")
	public ResultVO<RecipeVO> swapRecipeSteps(@PathVariable Long recipeId,
											  @RequestParam("firstIndex") Integer firstIndex,
											  @RequestParam("secondIndex") Integer secondIndex) {
		return ResultVO.buildSuccess(recipeService.swapRecipeSteps(recipeId, firstIndex, secondIndex));
	}

	@GetMapping("/search")
	public ResultVO<org.springframework.data.domain.Page<RecipeVO>> searchRecipes(
			@RequestParam(required = false) String keyword,
			@RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") Date startDate,
			@RequestParam(required = false) IngredientEnum tag,
			@org.springframework.data.web.PageableDefault(page = 0, size = 10, sort = "createTime", direction = org.springframework.data.domain.Sort.Direction.DESC) org.springframework.data.domain.Pageable pageable
	) {
		return ResultVO.buildSuccess(recipeService.searchRecipes(keyword, startDate, tag, pageable));
	}

	@PutMapping("/{recipeId}/ingredient/description")
	public ResultVO<RecipeIngredientVO> modifyRecipeIngredient(@PathVariable Long recipeId, @RequestBody String description) {
		return ResultVO.buildSuccess(recipeService.modifyRecipeIngredient(recipeId, description));
	}

	@PutMapping("/{recipeId}/ingredient/tag")
	public ResultVO<RecipeIngredientVO> setRecipeIngredientTag(@PathVariable Long recipeId,
												   @RequestParam IngredientEnum ingredient) {
		return ResultVO.buildSuccess(recipeService.setRecipeIngredientTag(recipeId, ingredient));
	}

	@GetMapping("/getRecentRecipe")
	public ResultVO<Page<RecipeVO>> getRecentRecipe(
			@RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") Date startDate,
			@PageableDefault(page = 0, size = 10, sort = "createTime", direction = Sort.Direction.DESC) Pageable pageable
	) {
		return ResultVO.buildSuccess(recipeService.getRecentRecipes(startDate, pageable));
	}

	@GetMapping("/recipe/{userId}")
	public ResultVO<Page<RecipeVO>> getUserRecipe(
			@PathVariable Long userId,
			@RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") Date startDate,
			@PageableDefault(page = 0, size = 10, sort = "createTime", direction = Sort.Direction.DESC) Pageable pageable
	) {
		return ResultVO.buildSuccess(recipeService.getUserRecipesById(userId, startDate, pageable));
	}

	@GetMapping("getCurrentUserDraft")
	public ResultVO<List<RecipeVO>> getCurrentUserDraft() {
		return ResultVO.buildSuccess(recipeService.getCurrentUserDraft());
	}
}

