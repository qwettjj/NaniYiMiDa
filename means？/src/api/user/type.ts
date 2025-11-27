//登录发送的数据类型
export interface loginForm {
  username: string;
  password: string;
}
//登陆接受的数据类型
export interface userResponse {
  code: number;
  message?:string,
  data: {
    id: number;
    username: string;
    role: string;
    name: string;
    avatar: string;
    token: string;

  } | null;
}
