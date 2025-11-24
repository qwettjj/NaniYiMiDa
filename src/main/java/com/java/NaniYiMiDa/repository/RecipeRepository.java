package com.java.NaniYiMiDa.repository;

import com.java.NaniYiMiDa.enumx.RecipeStatus;
import com.java.NaniYiMiDa.enumx.IngredientEnum;
import com.java.NaniYiMiDa.po.recipe.Recipe;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Date;
import java.util.List;

public interface RecipeRepository extends JpaRepository<Recipe, Long> {
    Page<Recipe> findByCreatorUserIdAndStatusNot(Long userId, RecipeStatus status, Pageable pageable);

    Page<Recipe> findByCreatorUserIdAndStatus(Long userId, RecipeStatus status, Pageable pageable);

    Page<Recipe> findByCreatorUserIdAndStatusNotAndCreateTimeAfter(
            Long userId, RecipeStatus status, Date startDate, Pageable pageable
    );

    Page<Recipe> findByCreatorUserIdAndStatusAndCreateTimeAfter(
            Long userId, RecipeStatus status, Date startDate, Pageable pageable
    );

    Page<Recipe> findByStatus(RecipeStatus recipeStatus, Pageable pageable);

    Page<Recipe> findByStatusAndCreateTimeAfter(RecipeStatus recipeStatus, Date startDate, Pageable pageable);

    @org.springframework.data.jpa.repository.Query(
            "SELECT r FROM Recipe r WHERE r.status = :status " +
                    "AND (:startDate IS NULL OR r.createTime > :startDate) " +
                    "AND (LOWER(r.title) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
                    "OR LOWER(r.description) LIKE LOWER(CONCAT('%', :keyword, '%')))"
    )
    Page<Recipe> searchByStatusAndStartDateAndKeyword(@org.springframework.data.repository.query.Param("status") RecipeStatus status,
                                                      @org.springframework.data.repository.query.Param("startDate") Date startDate,
                                                      @org.springframework.data.repository.query.Param("keyword") String keyword,
                                                      Pageable pageable);

    @org.springframework.data.jpa.repository.Query(
            "SELECT r FROM Recipe r WHERE r.status = :status " +
                    "AND (:startDate IS NULL OR r.createTime > :startDate) " +
                    "AND r.ingredient.ingredient = :ingredient"
    )
    Page<Recipe> searchByStatusAndStartDateAndIngredient(@org.springframework.data.repository.query.Param("status") RecipeStatus status,
                                                         @org.springframework.data.repository.query.Param("startDate") Date startDate,
                                                         @org.springframework.data.repository.query.Param("ingredient") IngredientEnum ingredient,
                                                         Pageable pageable);

    @org.springframework.data.jpa.repository.Query(
            "SELECT r FROM Recipe r WHERE r.status = :status " +
                    "AND (:startDate IS NULL OR r.createTime > :startDate) " +
                    "AND (LOWER(r.title) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
                    "OR LOWER(r.description) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
                    "AND r.ingredient.ingredient = :ingredient"
    )
    Page<Recipe> searchByStatusAndStartDateAndKeywordAndIngredient(@org.springframework.data.repository.query.Param("status") RecipeStatus status,
                                                                    @org.springframework.data.repository.query.Param("startDate") Date startDate,
                                                                    @org.springframework.data.repository.query.Param("keyword") String keyword,
                                                                    @org.springframework.data.repository.query.Param("ingredient") IngredientEnum ingredient,
                                                                    Pageable pageable);

    List<Recipe> findByCreatorUserId(Long userId);
}

