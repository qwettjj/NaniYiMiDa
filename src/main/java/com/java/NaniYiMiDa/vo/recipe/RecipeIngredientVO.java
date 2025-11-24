package com.java.NaniYiMiDa.vo.recipe;

import com.java.NaniYiMiDa.enumx.IngredientEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RecipeIngredientVO {
	private Long ingredientId;
	private IngredientEnum ingredient;
	private String description;
}

