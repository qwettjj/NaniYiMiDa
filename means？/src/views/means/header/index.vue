<template>
  <header class="header">
    <div class="header-container">
      <!-- 左侧 Logo 和名称 -->
      <div class="logo-section">
        <img src="../../../assets/image/logo.png" alt="Logo" class="logo" />
        <span class="app-name">何宜胃</span>
      </div>

      <!-- 右侧导航菜单 -->
      <nav class="nav-menu">
        <router-link to="/" class="nav-item" active-class="active">首页</router-link>
        <router-link to="/home/team" class="nav-item">团队</router-link>
        <router-link to="/home/foods" class="nav-item">菜谱</router-link>
      </nav>
    </div>
  </header>
</template>

<script setup lang="ts" name="Header">
</script>

<style scoped lang="scss">
.header {
  width: 100%;
  height: 60px;
  background-color: #fff;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
}

.header-container {
  width: 100%;
  max-width: 1200px;
  margin: 0 10vw;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 12px;

  .logo {
    height: 60px;
    width: auto;
  }

  .app-name {
    font-size: 20px;
    font-weight: bold;
    color: #333;
  }
}

.nav-menu {
  display: flex;
  gap: 30px;

  .nav-item {
    font-size: 16px;
    color: #555;
    text-decoration: none;
    transition: color 0.3s ease;
    position: relative;
    padding: 4px 0;

    &:hover {
      color: #1890ff; /* 蓝色高亮 */
    }

    &.active {
      color: #1890ff;
      font-weight: 500;

      &::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        width: 100%;
        height: 2px;
        background-color: #1890ff;
        border-radius: 2px;
      }
    }
  }
}
</style>