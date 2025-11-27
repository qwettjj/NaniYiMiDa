import { createRouter, createWebHashHistory } from "vue-router";
import NotFound from "../views/404/index.vue";
import Login from "../views/login/index.vue";
// import Layout from "../layout/index.vue"
import Home from "../views/means/homeLayout/index.vue"
import { layoutChildren } from "./layout";
const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    {
      path: "/",
      redirect: "/home/first",
    },
    {
      path: "/login",
      name: "login",
      component: Login,
      meta: { title: "登录界面" },
    },
    {
      path: "/home",
      name: "home",
      component: Home,
      meta: { title: "首页" },
      children: layoutChildren,
    },
    {
      path: "/404",
      name: "notfound",
      component: NotFound,
      meta: { title: "404NotFound" },
    },
    {
      path: "/:pathMatch(.*)*",
      name: "NotFound",
      component: NotFound,
      meta: { title: "404NotFound" },
    },
  ],
  scrollBehavior() {
    return {
      left: 0,
      top: 0,
    };
  },
});
export default router;
