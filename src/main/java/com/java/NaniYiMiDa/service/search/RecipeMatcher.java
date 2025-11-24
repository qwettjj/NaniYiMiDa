package com.java.NaniYiMiDa.service.search;

import com.java.NaniYiMiDa.po.recipe.Recipe;

/**
 * 食谱匹配器接口
 * 用于判断食谱是否匹配搜索关键词
 */
public interface RecipeMatcher {
	boolean matches(Recipe recipe, String keyword);
}

