package com.java.NaniYiMiDa.service;

import com.java.NaniYiMiDa.vo.HistoryVO;

import java.util.Date;
import java.util.List;

public interface HistoryService {
    Void addHistory(Long recipeId);

    Void deleteHistory(Long recipeId);

    List<HistoryVO> getCurrentUserHistory(Date startDate);
}
