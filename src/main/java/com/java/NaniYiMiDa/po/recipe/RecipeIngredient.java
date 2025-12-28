package com.java.NaniYiMiDa.po.recipe;

import com.java.NaniYiMiDa.enumx.IngredientEnum;
import com.java.NaniYiMiDa.vo.recipe.RecipeIngredientVO;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class RecipeIngredient {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long ingredientId;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "recipe_id")
	private Recipe recipe;

	@Enumerated(EnumType.STRING)
	@Column(name = "ingredient", nullable = false)
	private IngredientEnum ingredient;

	@Column(name = "description", length = 1000)
	private String description;

	public RecipeIngredientVO toVO() {
		RecipeIngredientVO vo = new RecipeIngredientVO();
		vo.setIngredientId(ingredientId);
		vo.setIngredient(ingredient);
		vo.setDescription(description);
		return vo;
	}
}
