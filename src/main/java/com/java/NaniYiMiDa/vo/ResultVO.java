package com.java.NaniYiMiDa.vo;

import com.java.NaniYiMiDa.enumx.ErrorCode;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.io.Serializable;

@Getter
@AllArgsConstructor
public class ResultVO<T> implements Serializable {

	private final int code;

	private final String message;

	private final T data;

	public static <T> ResultVO<T> buildSuccess(T data) {
		return new ResultVO<>(Integer.parseInt(ErrorCode.SUCCESS.getCode()), null, data);
	}

	public static <T> ResultVO<T> buildFailure(String message) {
		return new ResultVO<>(Integer.parseInt(ErrorCode.BAD_REQUEST.getCode()), message, null);
	}

	public static <T> ResultVO<T> buildFailure(ErrorCode errorCode, String message) {
		return new ResultVO<>(Integer.parseInt(errorCode.getCode()), message != null ? message : errorCode.getDefaultMessage(), null);
	}
}
