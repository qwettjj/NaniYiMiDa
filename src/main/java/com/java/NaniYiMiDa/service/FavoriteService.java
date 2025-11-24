package com.java.NaniYiMiDa.service;

import com.java.NaniYiMiDa.vo.FavoriteVO;

import java.util.List;

public interface FavoriteService {

	FavoriteVO addFavorite(Long recipeId);

	Void removeFavorite(Long recipeId);

	List<FavoriteVO> getCurrentUserFavorites();
}

