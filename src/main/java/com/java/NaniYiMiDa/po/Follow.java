package com.java.NaniYiMiDa.po;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class Follow {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(name = "follower_user_id", nullable = false)
	private Long followerUserId;

	@Column(name = "followee_user_id", nullable = false)
	private Long followeeUserId;

	@Column(name = "created_at")
	@Temporal(TemporalType.TIMESTAMP)
	private Date createTime = new Date();
}


