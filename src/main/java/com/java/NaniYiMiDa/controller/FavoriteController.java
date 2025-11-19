package com.java.NaniYiMiDa.controller;

import com.java.NaniYiMiDa.service.FavoriteService;
import com.java.NaniYiMiDa.vo.FavoriteVO;
import com.java.NaniYiMiDa.vo.ResultVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/favorites")
public class FavoriteController {

	@Autowired
	private FavoriteService favoriteService;

	@PostMapping("/{recipeId}")
	public ResultVO<FavoriteVO> addFavorite(@PathVariable Long recipeId) {
		return ResultVO.buildSuccess(favoriteService.addFavorite(recipeId));
	}

	@DeleteMapping("/{recipeId}")
	public ResultVO<Void> removeFavorite(@PathVariable Long recipeId) {
		return ResultVO.buildSuccess(favoriteService.removeFavorite(recipeId));
	}

	@GetMapping("/getCurrentUserFavourites")
	public ResultVO<List<FavoriteVO>> getCurrentUserFavorites() {
		return ResultVO.buildSuccess(favoriteService.getCurrentUserFavorites());
	}
}

