package com.java.NaniYiMiDa.service.impl;

import com.java.NaniYiMiDa.enumx.ErrorCode;
import com.java.NaniYiMiDa.exception.BusinessException;
import com.java.NaniYiMiDa.po.History;
import com.java.NaniYiMiDa.po.User;
import com.java.NaniYiMiDa.repository.RecipeRepository;
import com.java.NaniYiMiDa.repository.HistoryRepository;
import com.java.NaniYiMiDa.service.HistoryService;
import com.java.NaniYiMiDa.tool.SecurityUtil;
import com.java.NaniYiMiDa.vo.HistoryVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Service
public class HistoryServiceImpl implements HistoryService {

    @Autowired
    private SecurityUtil securityUtil;

    @Autowired
    private HistoryRepository historyRepository;

    @Autowired
    private RecipeRepository recipeRepository;

    @Override
    @Transactional
    public Void addHistory(Long recipeId){
        if(recipeId == null || !recipeRepository.existsById(recipeId)){
            throw new BusinessException(ErrorCode.BAD_REQUEST,"菜谱不存在");
        }

        User user = requireCurrentUser();
        Long userId = user.getUserId();

        Date currentDate = new Date();
        if(historyRepository.existsByUserIdAndRecipeId(userId, recipeId)){
            History history = historyRepository.findByUserIdAndRecipeId(userId, recipeId);
            history.setCreateTime(currentDate);
            historyRepository.save(history);
        }
        else{
            History history = new History();
            history.setCreateTime(currentDate);
            history.setUserId(userId);
            history.setRecipeId(recipeId);
            historyRepository.save(history);
        }

        return null;
    }

    @Override
    @Transactional
    public Void deleteHistory(Long historyId){
        if(historyId == null){
            throw new BusinessException(ErrorCode.BAD_REQUEST,"历史不存在");
        }

        History history = historyRepository.findById(historyId)
                .orElseThrow(() -> new BusinessException(ErrorCode.BAD_REQUEST, "历史不存在"));

        User currentUser = requireCurrentUser();
        if(history.getUserId() == null || !history.getUserId().equals(currentUser.getUserId())){
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "无法删除他人历史");
        }

        historyRepository.deleteById(historyId);
        return null;
    }

    @Override
    public List<HistoryVO> getCurrentUserHistory(Date startTime){
        User user = requireCurrentUser();
        Long userId = user.getUserId();

        PageRequest pageRequest = PageRequest.of(
                0,
                10,
            Sort.by(Sort.Direction.DESC, "createTime")
        );


        List<History> histories = historyRepository.findByUserIdAndCreateTimeAfter(userId, startTime ,pageRequest);

        List<HistoryVO> historyVOList = new ArrayList<>();
        for(History history : histories){
            historyVOList.add(history.ToVO());
        }

        return historyVOList;
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
