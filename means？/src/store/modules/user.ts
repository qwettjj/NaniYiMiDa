import { defineStore } from "pinia";
import { ref } from "vue";
import { reqLogin, reqUserInfo } from "../../api/user/index";
import { useRouter } from "vue-router";
import { type loginForm, type userResponse } from "../../api/user/type";
import { ElMessage, ElNotification } from "element-plus";

export const useUserStore = defineStore("user", () => {
  const router = useRouter();
  const token = ref<string | null>(localStorage.getItem("token"));
  const userInfo = ref<userResponse | null>(null);

  const login = async (form: loginForm) => {
    const res: userResponse = await reqLogin(form);
    if (res.code == 200 && res.data) {
      token.value = res.data.token;
      localStorage.setItem("token", token.value);
      return "登录成功";
    } else {
      return Promise.reject(new Error(res.message));
    }
  };
  const check = () => {
    console.log("进来了");

    if (token.value === null) {
      ElNotification({
        type: "error",
        message: "还没有登录，请先登录",
      });router.push("/login");
     
    }
  };
  return { token, userInfo, login, check };
});
