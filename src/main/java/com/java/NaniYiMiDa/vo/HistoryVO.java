package com.java.NaniYiMiDa.vo;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class HistoryVO {
    private Long historyId;
    private Long userId;
    private Long recipeId;
    private Date createTime;
}
