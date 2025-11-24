package com.java.NaniYiMiDa.vo;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class FavoriteVO {
	private Long favouriteId;
	private Long recipeId;
	private Long userId;
}

