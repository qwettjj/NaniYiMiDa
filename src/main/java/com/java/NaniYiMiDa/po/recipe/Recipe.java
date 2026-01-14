package com.java.NaniYiMiDa.po.recipe;

import com.java.NaniYiMiDa.enumx.IngredientEnum;
import com.java.NaniYiMiDa.enumx.RecipeStatus;
import com.java.NaniYiMiDa.vo.recipe.RecipeStepVO;
import com.java.NaniYiMiDa.vo.recipe.RecipeVO;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class Recipe {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "recipe_id")
	private Long recipeId;

	@Column(name = "title", nullable = false)
	private String title;

	@Column(name = "description", length = 2000)
	private String description;

	@Column(name = "step_count")
	private Integer stepCount;

	@Column(name = "creator_user_id", nullable = false)
	private Long creatorUserId;

	@Column(name = "favourite_number", nullable = false)
	private Integer favouriteNumber = 0;

	@Column(name = "create_time")
	@Temporal(TemporalType.TIMESTAMP)
	private Date createTime;

	@Enumerated(EnumType.STRING)
	@Column(name = "status", nullable = false)
	private RecipeStatus status = RecipeStatus.DRAFT;

	@ElementCollection(fetch = FetchType.LAZY)
	@CollectionTable(name = "recipe_images", joinColumns = @JoinColumn(name = "recipe_id"))
	@Column(name = "image_url", length = 10)
	private List<String> imageUrls = new ArrayList<>();

	@OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
	private List<RecipeStep> steps = new ArrayList<>();

	@OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
	private List<RecipeIngredient> ingredients = new ArrayList<>();

	public void setSteps(List<RecipeStep> steps) {
		this.steps.clear();
		if (steps != null) {
			for (RecipeStep step : steps) {
				step.setRecipe(this);
				this.steps.add(step);
			}
		}
	}

	public RecipeVO toVO() {
		RecipeVO recipeVO = new RecipeVO();
		recipeVO.setRecipeId(recipeId);
		recipeVO.setTitle(title);
		recipeVO.setDescription(description);
		recipeVO.setStepCount(stepCount);
		recipeVO.setCreateTime(createTime);
		recipeVO.setFavouriteNumber(favouriteNumber);
		recipeVO.setStatus(status);
		recipeVO.setImageUrls(new ArrayList<>(imageUrls));
		List<RecipeStepVO> stepVOS = steps.stream()
				.sorted((a, b) -> {
					int aNum = a.getStepNumber() == null ? 0 : a.getStepNumber();
					int bNum = b.getStepNumber() == null ? 0 : b.getStepNumber();
					return Integer.compare(aNum, bNum);
				})
				.map(RecipeStep::toVO)
				.collect(Collectors.toList());
		recipeVO.setSteps(stepVOS);
		List<IngredientEnum> ingredientEnums = ingredients != null
				? ingredients.stream().map(RecipeIngredient::getIngredient).collect(Collectors.toList())
				: Collections.emptyList();
		recipeVO.setIngredients(ingredientEnums);
		return recipeVO;
	}

}
