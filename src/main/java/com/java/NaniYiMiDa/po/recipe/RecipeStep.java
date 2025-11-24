package com.java.NaniYiMiDa.po.recipe;

import com.java.NaniYiMiDa.vo.recipe.RecipeStepVO;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class RecipeStep {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "recipe_id")
	private Recipe recipe;

	@Column(name = "step_number")
	private Integer stepNumber;

	@Column(name = "description", nullable = false, length = 1000)
	private String description;

	@ElementCollection(fetch = FetchType.LAZY)
	@CollectionTable(name = "recipe_step_images", joinColumns = @JoinColumn(name = "step_id"))
	@Column(name = "image_url", length = 10)
	private List<String> imageUrls = new ArrayList<>();

	public RecipeStepVO toVO() {
		RecipeStepVO vo = new RecipeStepVO();
		vo.setStepId(id);
		vo.setStepNumber(stepNumber);
		vo.setDescription(description);
		vo.setImageUrls(new ArrayList<>(imageUrls));
		return vo;
	}
}

