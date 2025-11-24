package com.java.NaniYiMiDa.service;

import com.java.NaniYiMiDa.vo.HistoryVO;

import java.util.Date;
import java.util.List;

public interface HistoryService {
    Void addHistory(Long recipeId);

    Void deleteHistory(Long recipeId);

    org.springframework.data.domain.Page<HistoryVO> getCurrentUserHistory(Date startDate, org.springframework.data.domain.Pageable pageable);
}
