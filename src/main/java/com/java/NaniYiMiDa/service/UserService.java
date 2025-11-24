package com.java.NaniYiMiDa.service;

import com.java.NaniYiMiDa.vo.UserVO;

import java.util.List;

public interface UserService {
	Boolean userRegister(UserVO userVO);

	String userLogin(String phone,String password);

	UserVO getCurrentUserInformation();

	Boolean updateUserInformation(UserVO userVO);

	Void followUser(Long targetUserId);

	Void unfollowUser(Long targetUserId);

	List<UserVO> listMyFollowings();

	UserVO findByUserName(String userName);
}
