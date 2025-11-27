import { createApp } from 'vue'
import App from './App.vue'
import components from './components'
import './styles/index.scss'
import router from "./router"; // 导入路由配置
import pinia from './store/index';
import "element-plus/dist/index.css";
const app = createApp(App);

//用来获取当前环境
// console.log(import.meta.env);
app.use(router);
app.use(components);
app.use(pinia)
app.mount("#app");