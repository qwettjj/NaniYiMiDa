package com.java.NaniYiMiDa.po;


import com.java.NaniYiMiDa.enumx.Role;
import com.java.NaniYiMiDa.vo.UserVO;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long userId;

    @Basic
    @Column(name = "user_name")
    private String userName;

    @Basic
    @Column(name = "password")
    private String password;

    @Basic
    @Column(name = "phone_number")
    private String phoneNumber;

    @Basic
    @Column(name = "create_time")
    private Date createTime;

	@Basic
	@Column(name = "follower_count")
	private Long followerCount;

    @Basic
    @Column(name = "following_count")
    private Long followingCount;

    @Basic
    @Column(name = "favourite_count")
    private Long favouriteCount;

    @Basic
    @Column(name = "image")
    private String imageUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "role")
    private Role role;

    public UserVO toVO(){
        UserVO userVO = new UserVO();
        userVO.setUserId(userId);
        userVO.setUserName(userName);
        userVO.setPassword(password);
        userVO.setPhoneNumber(phoneNumber);
        userVO.setCreateTime(createTime);
		userVO.setFollowerCount(followerCount);
        userVO.setFollowingCount(followingCount);
        userVO.setFavouriteCount(favouriteCount);
        userVO.setImageUrl(imageUrl);
        userVO.setRole(role);

        return userVO;
    }
}
