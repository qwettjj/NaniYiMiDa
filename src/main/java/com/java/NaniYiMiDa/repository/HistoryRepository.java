package com.java.NaniYiMiDa.repository;

import com.java.NaniYiMiDa.po.History;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Date;
import java.util.List;

public interface HistoryRepository extends JpaRepository<History, Long> {
    boolean existsByUserIdAndRecipeId(Long userId, Long recipeId);

    History findByUserIdAndRecipeId(Long userId, Long recipeId);

    List<History> findByUserIdAndCreateTimeAfter(Long userId, Date startTime, PageRequest pageRequest);
}
