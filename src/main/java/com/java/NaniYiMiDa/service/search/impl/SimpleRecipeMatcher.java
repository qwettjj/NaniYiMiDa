package com.java.NaniYiMiDa.service.search.impl;

import com.java.NaniYiMiDa.po.recipe.Recipe;
import com.java.NaniYiMiDa.service.search.RecipeMatcher;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;


@Component
@Primary
public class SimpleRecipeMatcher implements RecipeMatcher {

	@Override
	public boolean matches(Recipe recipe, String keyword) {
		if (keyword == null || keyword.isBlank()) {
			return false;
		}
		if (recipe == null) {
			return false;
		}
		
		String searchKeyword = keyword.trim().toLowerCase();

		if (recipe.getTitle() != null) {
			if (recipe.getTitle().toLowerCase().contains(searchKeyword)) {
				return true;
			}
		}

		if (recipe.getDescription() != null) {
			if (recipe.getDescription().toLowerCase().contains(searchKeyword)) {
				return true;
			}
		}
		
		return false;
	}
}

