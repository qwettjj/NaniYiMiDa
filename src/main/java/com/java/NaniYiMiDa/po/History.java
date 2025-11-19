package com.java.NaniYiMiDa.po;

import com.java.NaniYiMiDa.vo.HistoryVO;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Entity
@Table(name = "history")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class History {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long historyId;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "recipe_id")
    private Long recipeId;

    @Column(name = "created_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTime = new Date();

    public HistoryVO ToVO(){
        HistoryVO vo = new HistoryVO();
        vo.setHistoryId(historyId);
        vo.setUserId(userId);
        vo.setRecipeId(recipeId);
        vo.setCreateTime(createTime);
        return vo;
    }


}
