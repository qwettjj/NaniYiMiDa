package com.java.NaniYiMiDa.vo;

import com.java.NaniYiMiDa.enumx.ErrorCode;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.io.Serializable;

@Getter
@AllArgsConstructor
public class ResultVO<T> implements Serializable {

	private final String code;

	private final String msg;

	private final T result;

	public static <T> ResultVO<T> buildSuccess(T result) {
		return new ResultVO<>("000", null, result);
	}

	public static <T> ResultVO<T> buildFailure(String msg) {
		return new ResultVO<>("400", msg, null);
	}

	public static <T> ResultVO<T> buildFailure(ErrorCode errorCode, String msg) {
		return new ResultVO<>(errorCode.getCode(), msg != null ? msg : errorCode.getDefaultMessage(), null);
	}
}
