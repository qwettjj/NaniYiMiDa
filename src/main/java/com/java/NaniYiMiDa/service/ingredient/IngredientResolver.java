package com.java.NaniYiMiDa.service.ingredient;

import com.java.NaniYiMiDa.enumx.IngredientEnum;

/**
 * 食材识别解析器接口
 * 用于从描述文本中识别出对应的食材枚举
 */
public interface IngredientResolver {
	IngredientEnum resolve(String description);
}

