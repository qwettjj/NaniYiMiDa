package com.java.NaniYiMiDa.service.impl;

import com.java.NaniYiMiDa.enumx.ErrorCode;
import com.java.NaniYiMiDa.enumx.Role;
import com.java.NaniYiMiDa.exception.BusinessException;
import com.java.NaniYiMiDa.po.User;
import com.java.NaniYiMiDa.po.Follow;
import com.java.NaniYiMiDa.repository.UserRepository;
import com.java.NaniYiMiDa.repository.FollowRepository;
import com.java.NaniYiMiDa.service.UserService;
import com.java.NaniYiMiDa.tool.SecurityUtil;
import com.java.NaniYiMiDa.tool.TokenUtil;
import com.java.NaniYiMiDa.vo.UserVO;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.lang.NonNull;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserServiceImpl implements UserService {

	@Autowired
	UserRepository userRepository;

	@Autowired
	TokenUtil tokenUtil;

	@Autowired
	SecurityUtil securityUtil;

	@Autowired
	FollowRepository followRepository;

	@Autowired
	private HttpServletRequest httpServletRequest;

	@Override
	public Boolean userRegister(UserVO userVO) {
		if (userVO == null || userVO.getPhoneNumber() == null || userVO.getPhoneNumber().isBlank()) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "手机号不能为空");
		}

		User existing = userRepository.findByPhoneNumber(userVO.getPhoneNumber());
		if (existing != null) {
			throw new BusinessException(ErrorCode.CONFLICT, "手机号已经存在!");
		}

		User newUser = userVO.toPO();
		newUser.setRole(Role.USER);
		newUser.setCreateTime(new Date());
		if (newUser.getFollowerCount() == null) {
			newUser.setFollowerCount(0L);
		}
		if (newUser.getFollowingCount() == null) {
			newUser.setFollowingCount(0L);
		}
		if (newUser.getFavouriteCount() == null) {
			newUser.setFavouriteCount(0L);
		}

		userRepository.save(newUser);
		return true;
	}

	@Override
	public String userLogin(String phone, String password) {
		User user = userRepository.findByPhoneNumberAndPassword(phone, password);
		if (user == null) {
			throw new BusinessException(ErrorCode.UNAUTHORIZED, "手机号或者密码有误");
		}
		return tokenUtil.getToken(user);
	}

	@Override
	public UserVO getCurrentUserInformation() {
		User user = requireCurrentUser();
		return user.toVO();
	}

	@Override
	public Boolean updateUserInformation(UserVO userVO) {
		if (userVO == null) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "更新内容不能为空");
		}

		User user = requireCurrentUser();
		if (userVO.getPassword() != null) {
			user.setPassword(userVO.getPassword());
		}
		if (userVO.getUserName() != null) {
			user.setUserName(userVO.getUserName());
		}
		if (userVO.getImageUrl() != null) {
			user.setImageUrl(userVO.getImageUrl());
		}
		if (userVO.getNickName() != null) {
			user.setNickName(userVO.getNickName());
		}
		if (userVO.getSignature() != null) {
			user.setSignature(userVO.getSignature());
		}
		if (userVO.getBirthday() != null) {
			user.setBirthday(userVO.getBirthday());
		}
		if (userVO.getAllergens() != null) {
			user.setAllergens(userVO.getAllergens());
		}
		userRepository.save(user);

		httpServletRequest.getSession().setAttribute("currentUser", user);

		return true;
	}

	@Override
	@Transactional
	public Void followUser(Long targetUserId) {
		User currentUser = requireCurrentUser();

		if (targetUserId == null) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "目标用户ID不能为空");
		}
		if (currentUser.getUserId().equals(targetUserId)) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "不能关注自己");
		}

		if (followRepository.existsByFollowerUserIdAndFolloweeUserId(currentUser.getUserId(), targetUserId)) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "已经关注了这个用户");
		}

		long following = currentUser.getFollowingCount() == null ? 0L : currentUser.getFollowingCount();
		if (following >= 500) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "关注用户已达上限");
		}

		currentUser.setFollowingCount(following + 1);
		userRepository.save(currentUser);

		findUserById(targetUserId);
		Follow follow = new Follow();
		follow.setFollowerUserId(currentUser.getUserId());
		follow.setFolloweeUserId(targetUserId);
		followRepository.save(follow);
		increaseFollowerCount(targetUserId);

		return null;
	}

	@Override
	@Transactional
	public Void unfollowUser(Long targetUserId) {
		User currentUser = requireCurrentUser();

		if (targetUserId == null) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "目标用户ID不能为空");
		}

		if (!followRepository.existsByFollowerUserIdAndFolloweeUserId(currentUser.getUserId(), targetUserId)) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "没有关注这个用户");
		}

		long followingCount = currentUser.getFollowingCount() == null ? 0L : currentUser.getFollowingCount();
		currentUser.setFollowingCount(Math.max(0L, followingCount - 1));
		userRepository.save(currentUser);

		followRepository.deleteByFollowerUserIdAndFolloweeUserId(currentUser.getUserId(), targetUserId);
		decreaseFollowerCount(targetUserId);
		return null;
	}

	@Override
	public List<UserVO> listMyFollowings() {
		User currentUser = requireCurrentUser();
		return followRepository.findByFollowerUserId(currentUser.getUserId()).stream()
				.map(f -> findUserById(f.getFolloweeUserId()).toVO())
				.collect(Collectors.toList());
	}

	@Override
	public UserVO findByUserName(String userName) {
		if (userName == null || userName.isBlank()) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "用户名不能为空");
		}
		User user = userRepository.findByUserName(userName);
		if (user == null) {
			throw new BusinessException(ErrorCode.NOT_FOUND, "用户不存在");
		}
		return user.toVO();
	}

	private Void increaseFollowerCount(Long userId) {
		User user = findUserById(userId);

		long current = user.getFollowerCount() == null ? 0L : user.getFollowerCount();

		user.setFollowerCount(current + 1);
		userRepository.save(user);
		return null;
	}

	private Void decreaseFollowerCount(Long userId) {
		User user = findUserById(userId);
		long current = user.getFollowerCount() == null ? 0L : user.getFollowerCount();
		user.setFollowerCount(Math.max(0L, current - 1));
		userRepository.save(user);
		return null;
	}

	private User findUserById(Long userId) {
		if (userId == null) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "用户ID不能为空");
		}
		return userRepository.findById(userId)
				.orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "用户不存在"));
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
