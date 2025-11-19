package com.java.NaniYiMiDa.vo.recipe;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RecipeStepVO {
	// NOTE: 新增 stepId 便于前端在修改/删除操作中定位具体步骤
	private Long stepId;
	private Integer stepNumber;
	private String description;
	private List<String> imageUrls;
}

