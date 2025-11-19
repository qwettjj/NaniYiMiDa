package com.java.NaniYiMiDa.repository;

import com.java.NaniYiMiDa.po.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

	boolean existsByUserIdAndRecipeId(Long userId, Long recipeId);

	List<Favorite> findByUserId(Long userId);

	void deleteByUserIdAndRecipeId(Long userId, Long recipeId);
}

