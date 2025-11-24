package com.java.NaniYiMiDa.repository;

import com.java.NaniYiMiDa.enumx.RecipeStatus;
import com.java.NaniYiMiDa.po.recipe.Recipe;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Date;
import java.util.List;

public interface RecipeRepository extends JpaRepository<Recipe, Long> {
    Page<Recipe> findByCreatorUserIdAndStatusNot(Long userId, RecipeStatus status, PageRequest pageRequest);

    Page<Recipe> findByCreatorUserIdAndStatus(Long userId, RecipeStatus status, PageRequest pageRequest);

    Page<Recipe> findByCreatorUserIdAndStatusNotAndCreateTimeAfter(
            Long userId, RecipeStatus status, Date startDate, PageRequest pageRequest
    );

    Page<Recipe> findByCreatorUserIdAndStatusAndCreateTimeAfter(
            Long userId, RecipeStatus status, Date startDate, PageRequest pageRequest
    );

    Page<Recipe> findByStatus(RecipeStatus recipeStatus, PageRequest pageRequest);

    Page<Recipe> findByStatusAndCreateTimeAfter(RecipeStatus recipeStatus, Date startDate, PageRequest pageRequest);

    List<Recipe> findByCreatorUserId(Long userId);
}

