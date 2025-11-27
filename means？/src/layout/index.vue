<template>
  <div class="layout-container" :class="currentTheme">
    <!-- 头部菜单 -->
    <header class="header">
      <div class="header-content">
        <h2>番茄管理系统</h2>
        <div class="header-actions">
          <el-button type="primary">操作1</el-button>
          <el-button @click="toggleTheme">
            <el-icon><Refresh /></el-icon>
            切换主题
          </el-button>
          <el-button>退出</el-button>
        </div>
      </div>
    </header>

    <div class="main-content">
      <!-- 左侧菜单 -->
      <aside class="sidebar">
        <el-menu class="sidebar-menu" default-active="2" :class="currentTheme">
          <el-sub-menu index="1">
            <template #title>
              <el-icon><location /></el-icon>
              <span>Navigator One</span>
            </template>
            <el-menu-item-group title="Group One">
              <el-menu-item index="1-1">item one</el-menu-item>
              <el-menu-item index="1-2">item two</el-menu-item>
            </el-menu-item-group>
            <el-menu-item-group title="Group Two">
              <el-menu-item index="1-3">item three</el-menu-item>
            </el-menu-item-group>
            <el-sub-menu index="1-4">
              <template #title>item four</template>
              <el-menu-item index="1-4-1">item one</el-menu-item>
            </el-sub-menu>
          </el-sub-menu>
          <el-menu-item index="2">
            <el-icon><Menu /></el-icon>
            <span>Navigator Two</span>
          </el-menu-item>
          <el-menu-item index="3" disabled>
            <el-icon><document /></el-icon>
            <span>Navigator Three</span>
          </el-menu-item>
          <el-menu-item index="4">
            <el-icon><setting /></el-icon>
            <span>Navigator Four</span>
          </el-menu-item>
        </el-menu>
      </aside>

      <!-- 右侧内容区域 -->
      <main class="content-area">
        <div class="content">
          <p>这里是主要内容区域</p>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed } from "vue";
  import {
    Location,
    Menu,
    Document,
    Setting,
    Refresh,
  } from "@element-plus/icons-vue";
  import { useUserStore } from "../store/modules/user";
  import { useRouter } from "vue-router";
  import { ElButton } from "element-plus";
  import { onMounted } from "vue";

  // 切换背景
  const isDark = ref(false);
  const initTheme = () => {
    const savedTheme = localStorage.getItem("theme");
    if (savedTheme === "light") {
      isDark.value = false;
    } else if (savedTheme === "dark") {
      isDark.value = true;
    }
  };
  onMounted(() => {
    initTheme();
  });
  const currentTheme = computed(() => (isDark.value ? "dark" : "light"));
  const toggleTheme = () => {
    isDark.value = !isDark.value;
    localStorage.setItem("theme", isDark.value ? "dark" : "light");
  };

  
  let useStore = useUserStore();
  const router = useRouter();
  useStore.check();
</script>

<style scoped lang="scss">
  @use "../styles/index.scss" as *;

  .layout-container {
    height: 100vh;
    display: flex;
    flex-direction: column;
    transition: all 0.3s ease;
  }

  .header {
    height: 60px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    z-index: 1000;
    transition: all 0.3s ease;

    .header-content {
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 20px;

      h2 {
        margin: 0;
        font-size: 20px;
      }

      .header-actions {
        display: flex;
        gap: 10px;
      }
    }
  }

  .main-content {
    flex: 1;
    display: flex;
    overflow: hidden;
  }

  .sidebar {
    width: 250px;
    display: flex;
    flex-direction: column;
    transition: all 0.3s ease;
  }

  .sidebar-menu {
    flex: 1;
    border-right: none;
    transition: all 0.3s ease;
  }

  .content-area {
    flex: 1;
    padding: 20px;
    overflow-y: auto;
    transition: all 0.3s ease;

    .content {
      padding: 20px;
      border-radius: 4px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      transition: all 0.3s ease;
    }
  }

  /* 深色主题样式 */
  .layout-container.dark {
    .header {
      background-color: #{$head-dark};
      color: white;
    }

    .sidebar {
      background-color: #{$left-background-dark};
    }

    .content-area {
      background-color: #{$content-area-background-color-dark};

      .content {
        background: #{$content-background-dark};
        color: #{$content-color-dark};
      }
    }

    :deep(.sidebar-menu.dark) {
      --el-menu-active-color: #{$active-text-color-dark};
      --el-menu-bg-color: #{$left-background-dark};
      --el-menu-text-color: #{$text-color-dark};
      --el-menu-hover-bg-color: #{$active-left-background-dark};
    }
  }

  /* 浅色主题样式 */
  .layout-container.light {
    .header {
      background-color: #{$head-light};
      color: #{$text-color-light};
      border-bottom: 1px solid #e4e7ed;
    }

    .sidebar {
      background-color: #{$left-background-light};
      border-right: 1px solid #e4e7ed;
    }

    .content-area {
      background-color: #{$content-area-background-color-light};

      .content {
        background: #{$content-background-light};
        color: #{$content-color-light};
      }
    }

    :deep(.sidebar-menu.light) {
      --el-menu-active-color: #{$active-text-color-light};
      --el-menu-bg-color: #{$left-background-light};
      --el-menu-text-color: #{$text-color-light};
      --el-menu-hover-bg-color: #{$active-left-background-light};
    }
  }

  // 响应式设计
  @media (max-width: 768px) {
    .sidebar {
      width: 200px;
    }
  }
</style>
