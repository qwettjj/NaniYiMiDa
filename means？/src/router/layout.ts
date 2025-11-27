import First from "../views/means/firstpage/index.vue";
import Team from "../views/means/team/index.vue";
import Foods from "../views/means/foods/index.vue";
export const layoutChildren = [
  {
    path: "first",
    name: "first",
    component: First,
    meta: { title: "主界面" },
  },
  {
    path: "team",
    name: "team",
    component: Team,
    meta: { title: "团队" },
  },
  {
    path: "foods",
    name: "foods",
    component: Foods,
    meta: { title: "菜谱" },
  },
];
