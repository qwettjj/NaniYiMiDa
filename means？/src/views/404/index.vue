<template>
  <div class="not-found-container">
    <img src="../../assets/image/404.png" alt="404 Not Found" class="bg-image" />
    <el-button 
      type="primary" 
      class="floating-btn"
      @click="goHome"
    >
      回到首页
    </el-button>
  </div>
</template>

<script setup lang="ts" name="page404">
import { useRouter } from "vue-router";

const router = useRouter();

const goHome = () => {
  router.push("/");
};
</script>

<style scoped lang="scss">
.not-found-container {
  position: relative;
  width: 100%;
  height: 100vh;
  overflow: hidden;

  .bg-image {
    width: 100%;
    height: 100%;

  }

  .floating-btn {
    position: absolute;
    bottom: 30%; 
    left: 50%;
    transform: translateX(-80%); 
    padding: 12px 24px;
    font-size: 30px;
    background-color: rgba(255, 255, 255, 0.2); 
    color: rgb(48, 98, 236);
    border: none; 
    border-radius: 50px;
    backdrop-filter: blur(5px); 
    transition: all 0.3s ease; 

    &:hover {
      background-color: rgba(200, 200, 200, 0.3); 
    }
  }
}
</style>