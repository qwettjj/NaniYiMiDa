<template>
  <div>
    <Header class="fixed-header" />
    <div class="content-container">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </div>
    <Tail />
  </div>
</template>

<script setup lang="ts">
  import Header from "../header/index.vue";
  import Tail from "../tail/index.vue";
</script>

<style scoped>
  .fixed-header {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    z-index: 1000;
  }

  .content-container {
    margin-top: 60px;
  }

  .fade-enter-active,
  .fade-leave-active {
    transition: all 0.3s;
  }

  .fade-enter-from {
    opacity: 0;
  }
  .fade-leave-to {
    opacity: 0;
  }
</style>
