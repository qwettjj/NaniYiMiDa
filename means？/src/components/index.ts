import MyButton from "./MyButton.vue";

// 定义需要全局注册的组件列表
const components = [
  { name: "MyButton", component: MyButton },
  // 可以继续添加其他组件...
];

export default {
  install(app: import("vue").App) {
    components.forEach(({ name, component }) => {
      app.component(name, component); 
    });
  },
};