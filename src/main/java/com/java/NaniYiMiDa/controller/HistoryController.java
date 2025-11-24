package com.java.NaniYiMiDa.controller;

import com.java.NaniYiMiDa.service.HistoryService;
import com.java.NaniYiMiDa.vo.HistoryVO;
import com.java.NaniYiMiDa.vo.ResultVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;

@RestController
@RequestMapping("/api/histories")
public class HistoryController {

    @Autowired
    private HistoryService historyService;

    @PostMapping("/{recipeId}")
    public ResultVO<Void> addHistory(@PathVariable Long recipeId) {
        return ResultVO.buildSuccess(historyService.addHistory(recipeId));
    }

    @DeleteMapping("/{historyId}")
    public ResultVO<Void> deleteHistory(@PathVariable Long historyId) {
        return ResultVO.buildSuccess(historyService.deleteHistory(historyId));
    }

    @GetMapping("/getCurrentUserHistory")
    public ResultVO<List<HistoryVO>> getCurrentUserHistory(@RequestParam Date startTime) {
        return ResultVO.buildSuccess(historyService.getCurrentUserHistory(startTime));
    }
}
