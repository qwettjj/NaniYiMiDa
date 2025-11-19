package com.java.NaniYiMiDa.repository;

import com.java.NaniYiMiDa.po.Follow;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FollowRepository extends JpaRepository<Follow, Long> {
	boolean existsByFollowerUserIdAndFolloweeUserId(Long followerUserId, Long followeeUserId);
	void deleteByFollowerUserIdAndFolloweeUserId(Long followerUserId, Long followeeUserId);
	List<Follow> findByFollowerUserId(Long followerUserId);
}


