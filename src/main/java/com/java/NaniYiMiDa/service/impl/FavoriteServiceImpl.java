package com.java.NaniYiMiDa.service.impl;

import com.java.NaniYiMiDa.enumx.ErrorCode;
import com.java.NaniYiMiDa.exception.BusinessException;
import com.java.NaniYiMiDa.po.Favorite;
import com.java.NaniYiMiDa.po.User;
import com.java.NaniYiMiDa.po.recipe.Recipe;
import com.java.NaniYiMiDa.repository.FavoriteRepository;
import com.java.NaniYiMiDa.repository.RecipeRepository;
import com.java.NaniYiMiDa.repository.UserRepository;
import com.java.NaniYiMiDa.service.FavoriteService;
import com.java.NaniYiMiDa.tool.SecurityUtil;
import com.java.NaniYiMiDa.vo.FavoriteVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Currency;
import java.util.List;

@Service
public class FavoriteServiceImpl implements FavoriteService {

	@Autowired
	private FavoriteRepository favoriteRepository;

	@Autowired
	private RecipeRepository recipeRepository;

	@Autowired
	private SecurityUtil securityUtil;

    @Autowired
    private UserRepository userRepository;

	@Override
	@Transactional
	public FavoriteVO addFavorite(Long recipeId) {
		User currentUser = requireCurrentUser();

		if(currentUser.getFavouriteCount() >= 1000) {
			throw new BusinessException(ErrorCode.BAD_REQUEST,"收藏的菜谱达到上限");
		}

		if (favoriteRepository.existsByUserIdAndRecipeId(currentUser.getUserId(), recipeId)) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "已经收藏过该食谱");
		}

		currentUser.setFavouriteCount(currentUser.getFavouriteCount() + 1);
		userRepository.save(currentUser);

		Recipe recipe = findRecipeById(recipeId);
		Favorite favorite = new Favorite();
		favorite.setUserId(currentUser.getUserId());
		favorite.setRecipeId(recipeId);
		favoriteRepository.save(favorite);
		recipe.setFavouriteNumber(recipe.getFavouriteNumber() + 1);
		recipeRepository.save(recipe);
		
		return favorite.toVO();
	}

	@Override
	@Transactional
	public Void removeFavorite(Long recipeId) {
		User currentUser = requireCurrentUser();

		if (!favoriteRepository.existsByUserIdAndRecipeId(currentUser.getUserId(), recipeId)) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "未收藏该食谱");
		}

		currentUser.setFavouriteCount(currentUser.getFavouriteCount()-1);
		userRepository.save(currentUser);

		Recipe recipe = findRecipeById(recipeId);
		favoriteRepository.deleteByUserIdAndRecipeId(currentUser.getUserId(), recipeId);
		recipe.setFavouriteNumber(recipe.getFavouriteNumber() - 1);
		recipeRepository.save(recipe);

		return null;
	}

	@Override
	@Transactional
	public List<FavoriteVO> getCurrentUserFavorites(){
		User currentUser = requireCurrentUser();
		List<Favorite> favorites = favoriteRepository.findByUserId(currentUser.getUserId());
		List<FavoriteVO> favoriteVOList = new ArrayList<>();
		for (Favorite favorite : favorites) {
			favoriteVOList.add(favorite.toVO());
		}
		return favoriteVOList;
	}

	private Recipe findRecipeById(Long recipeId) {
		if (recipeId == null) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "食谱ID不能为空");
		}
		return recipeRepository.findById(recipeId)
				.orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "食谱不存在"));
	}

	@NonNull
	private User requireCurrentUser() {
		User user = securityUtil.getCurrentUser();
		if (user == null) {
			throw new BusinessException(ErrorCode.UNAUTHORIZED, "未登录");
		}
		return user;
	}
}

