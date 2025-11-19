package com.java.NaniYiMiDa.vo.recipe;

import com.java.NaniYiMiDa.enumx.IngredientEnum;
import com.java.NaniYiMiDa.enumx.RecipeStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RecipeVO {
	private Long recipeId;
	private String title;
	private String description;
	private Integer stepCount;
	private Date createTime;
	private Integer favouriteNumber;
	private RecipeStatus status;
	private List<String> imageUrls;
	private List<RecipeStepVO> steps;
	private List<IngredientEnum> ingredients;
}

