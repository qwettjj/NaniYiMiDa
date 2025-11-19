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

    public User toPO(){
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
        return user;
    }
}
