package com.java.NaniYiMiDa.vo;

import com.java.NaniYiMiDa.enumx.Role;
import com.java.NaniYiMiDa.po.User;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserVO {

    private Long userId;

    private String userName;

    private String password;

    private String phoneNumber;

    private Date createTime;

    private Long followerCount;

    private Long followingCount;

    private Long favouriteCount;

    private String imageUrl;

    private Role role;

    private String nickName;

    private String signature;

    private String birthday;

    private String allergens;

    public User toPO() {
        User user = new User();
        user.setUserId(userId);
        user.setUserName(userName);
        user.setPassword(password);
        user.setPhoneNumber(phoneNumber);
        user.setCreateTime(createTime);
        user.setFollowerCount(followerCount);
        user.setFollowingCount(followingCount);
        user.setFavouriteCount(favouriteCount);
        user.setImageUrl(imageUrl);
        user.setRole(role);
        user.setNickName(nickName);
        user.setSignature(signature);
        user.setBirthday(birthday);
        user.setAllergens(allergens);
        return user;
    }
}
