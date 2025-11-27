import request from "../../utils/request";
import { type loginForm, type userResponse } from "./type";
const apis = {
  LOGIN_URL: "/user/login",
  USERINFO_URL: "/user/info",
};
//登录接口方法
export const reqLogin = (data: loginForm) =>
  request.post<any, userResponse>(apis.LOGIN_URL, data);
//获取用户信息接口方法
export const reqUserInfo = () => request.get<any, userResponse>(apis.USERINFO_URL);
