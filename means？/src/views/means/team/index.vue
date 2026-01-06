<template>
  <div class="team-page">
    <!-- 第一屏：标题 -->
    <div class="section hero">
      <div class="container">
        <h1>我们的团队</h1>
        <p class="subtitle">一个充满激情的团队，致力于改变您的饮食方式</p>
      </div>
    </div>

    <!-- 第二屏：团队成员 -->
    <div class="section team-members">
      <div class="container">
        <div class="member-grid">
          <div class="member-card" v-for="(member, index) in teamMembers" :key="index">
            <div class="avatar-container">
              <img :src="member.avatar" :alt="member.name" class="avatar" />
            </div>
            <div class="member-info">
              <h3 class="member-name">{{ member.name }}</h3>
              <p class="member-title">{{ member.title }}</p>
              <p class="member-desc">{{ member.description }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 第三屏：独立声明 -->
    <div class="section independence">
      <div class="container">
        <h2>独立项目声明</h2>
        <p>
          本产品分析系统为<span class="highlight">100%独立项目</span>，所有推荐和分析结果均基于公开数据与算法模型生成。
          <br /><br />
          我们<span class="highlight">不接受任何品牌或制造商的资助</span>，确保产品评价的客观性与透明度。
          <br /><br />
          用户的健康选择，始终是我们的首要准则。
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// 假数据 - 团队成员
const teamMembers = [
  {
    name: "ZEROandLIFE",
    title: "前端开发",
    description: "负责web页面结构、样式与交互实现。",
    avatar: "https://avatars.githubusercontent.com/u/147062184?v=4"
  },
  {
    name: "qwettjj",
    title: "后端开发",
    description: "负责接口设计与数据库操作，保证数据安全与性能。",
    avatar: "https://avatars.githubusercontent.com/u/144441049?v=4"
  },
  {
    name: "apophisi",
    title: "后端开发",
    description: "负责业务逻辑实现。",
    avatar: "https://avatars.githubusercontent.com/u/166116681?v=4"
  },
  {
    name: "Craig-Akutagawa",
    title: "移动端开发",
    description: "负责鸿蒙端功能开发与性能优化。",
    avatar: "https://avatars.githubusercontent.com/u/200924220?v=4"
  },
  {
    name: "Shelia-YX",
    title: "设计师",
    description: "负责界面原型与视觉稿输出。",
    avatar: "https://avatars.githubusercontent.com/u/140523267?v=4"
  },
  {
    name: "DRAGONDIVINIT",
    title: "产品经理",
    description: "负责需求收集与原型文档，跟进开发进度并验收功能。",
    avatar: "https://avatars.githubusercontent.com/u/156163962?s=400&v=4"
  }
];
</script>

<style scoped lang="scss">
.team-page {
  font-family: 'Open Sans', sans-serif;
  color: #333;
  line-height: 1.6;
}

.section {
  padding: 80px 0;
}

.container {
  width: 90%;
  max-width: 1200px;
  margin: 0 auto;
}

/* 英雄区域 */
.hero {
  background-color: #f8f9fa;
  text-align: center;
  
  h1 {
    font-size: 2.5rem;
    margin-bottom: 20px;
    color: #2a7f62;
  }
  
  .subtitle {
    font-size: 1.2rem;
    color: #666;
  }
}

/* 团队成员网格 */
.team-members {
  background-color: #fff;
}

.member-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 40px;
  margin-top: 40px;
}

.member-card {
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  transition: transform 0.3s ease;
  
  &:hover {
    transform: translateY(-5px);
  }
}

.avatar-container {
  width: 100%;
  height: 200px;
  overflow: hidden;
  
  .avatar {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.member-info {
  padding: 20px;
  
  .member-name {
    font-size: 1.2rem;
    margin-bottom: 8px;
    color: #2a7f62;
  }
  
  .member-title {
    font-size: 1rem;
    color: #666;
    margin-bottom: 12px;
    font-style: italic;
  }
  
  .member-desc {
    font-size: 0.95rem;
    color: #555;
  }
}

/* 独立声明 */
.independence {
  background-color: #f8f9fa;
  
  h2 {
    font-size: 1.8rem;
    margin-bottom: 20px;
    color: #2a7f62;
  }
  
  p {
    font-size: 1.1rem;
    
    .highlight {
      font-weight: bold;
      color: #d63031;
    }
  }
}

/* 响应式调整 */
@media (max-width: 768px) {
  .section {
    padding: 50px 0;
  }
  
  .member-grid {
    grid-template-columns: 1fr;
  }
}
</style>