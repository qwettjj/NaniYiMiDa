package com.java.NaniYiMiDa.service.ingredient.impl;

import com.java.NaniYiMiDa.enumx.IngredientEnum;
import com.java.NaniYiMiDa.service.ingredient.IngredientResolver;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;

@Component
public class SimpleIngredientResolver implements IngredientResolver {

	@Override
	public IngredientEnum resolve(String description) {
		String origin = description == null ? "" : description;
		String upper = origin.toUpperCase();
		String upperNoSpace = upper.replaceAll("\\s+", "");
		for (IngredientEnum item : IngredientEnum.values()) {
			String displayName = item.getDisplayName();
			if (displayName != null && !displayName.isBlank() && origin.contains(displayName)) {
				return item;
			}
			String enumName = item.name();
			String enumNameWithSpace = enumName.replace('_', ' ');
			if (upper.contains(enumName) || upper.contains(enumNameWithSpace) || upperNoSpace.contains(enumName.replace("_",""))) {
				return item;
			}
		}
		return null;
	}
}

