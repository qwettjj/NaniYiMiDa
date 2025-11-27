<template>
  <div class="outer">
    <!-- 第一屏：标题和副标题 -->
    <div class="one">
      <div class="left"></div>
      <div class="right">
        <div class="title-group">
          <div class="main-title option-a">扫描食品，吃个明白。</div>
          <div class="main-title option-b">别再被配料表欺骗。</div>
          <div class="main-title option-c">扫一扫，解锁食物的真相。</div>
        </div>
        <div class="subtitle">
          “用【何宜胃】扫描条形码，即刻获取健康评分、成分解析和更优选择。为您的每一口负责。”
        </div>
      </div>
    </div>

    <!-- 第二屏：功能介绍 -->
    <div class="two">
      <div class="left">
        <div class="feature-card">
          <div class="feature-title">秒速扫描，深度解析</div>
          <div class="feature-list">
            <div class="feature-item">
              <span class="highlight">一扫即知：</span>
              对准商品条形码，1秒内获取全面分析报告。
            </div>
            <div class="feature-item">
              <span class="highlight">通俗易懂的评分系统：</span>
              红、黄、绿三色等级，好坏一眼便知。
            </div>
            <div class="feature-item">
              <span class="highlight">成分“翻译官”：</span>
              将复杂的化学名词（如“焦亚硫酸钠”）翻译成通俗易懂的健康影响说明（如“可能引起过敏”）。
            </div>
          </div>
        </div>
      </div>
      <div class="right"></div>
    </div>
    <!-- 第三屏：功能介绍 -->
    <div class="three">
      <div class="content">
        <div class="independent-project">
          <div class="project-title">独立项目声明</div>
          <div class="project-desc">
            本产品分析系统为<span class="highlight">100%独立项目</span
            >，所有推荐和分析结果均基于公开数据与算法模型生成。 <br /><br />
            我们<span class="highlight">不接受任何品牌或制造商的资助</span
            >，确保产品评价的客观性与透明度。 <br /><br />
            用户的健康选择，始终是我们的首要准则。
          </div>
        </div>
        <div class="team-link">
          <div class="team-button" @click="gototeam">
            去了解我们的团队 <el-icon><Right /></el-icon>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts" name="first">
  import { useRouter } from "vue-router";
  import { Right } from "@element-plus/icons-vue";
  const router = useRouter();
  const gototeam = () => {
    router.push("/home/team");
  };
</script>

<style scoped lang="scss">
  .one {
    width: 100%;
    height: 60vh;
    display: flex;
    position: relative;

    .left {
      flex: 1;
      margin: 10vh 10vw;
      position: absolute;
      width: 15vw;
      height: 40vh;
      background-image: url("../../../assets/image/phone.png");
      background-size: contain;
      background-position: left center;
      background-repeat: no-repeat;
      // opacity: 0.5;
      transform: rotate(-5deg);
    }

    .right {
      flex: 3;
      display: flex;
      flex-direction: column;
      justify-content: center;
      padding-left: 30vw;
      box-sizing: border-box;

      .title-group {
        margin-bottom: 2rem;

        .main-title {
          font-size: 1.8rem;
          font-weight: bold;
          margin-bottom: 1rem;
          line-height: 1.2;
          max-width: 70%;
          &.option-a {
            color: #2a7f62;
          }
          &.option-b {
            color: #d63031;
          }
          &.option-c {
            color: #0984e3;
          }
        }
      }

      .subtitle {
        font-size: 1.2rem;
        color: #555;
        line-height: 1.6;
        max-width: 60%;
        font-style: italic;
      }
    }
  }

  .two {
    width: 100%;
    height: 60vh;
    display: flex;
    position: relative;
    background-image: url("../../../assets/image/bg2.svg");
    background-size: cover;
    background-position: left center;
    display: flex;
    position: relative;

    .left {
      flex: 1;
      display: flex;
      align-items: center;
      padding-left: 10vw;

      .feature-card {
        background-color: rgba(255, 255, 255, 0.9);
        border-radius: 12px;
        padding: 2rem;
        width: 70%;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);

        .feature-title {
          font-size: 1.5rem;
          font-weight: bold;
          margin-bottom: 1.5rem;
          color: #333;
        }

        .feature-list {
          display: flex;
          flex-direction: column;
          gap: 1rem;

          .feature-item {
            background-color: rgba(255, 255, 255, 0.7);
            padding: 0.8rem 1.2rem;
            border-radius: 8px;
            font-size: 1rem;
            line-height: 1.5;
            color: #333;

            .highlight {
              font-weight: bold;
              color: #0984e3;
            }
          }
        }
      }
    }

    .right {
    flex: 1;
    background-image: url("@/assets/image/R-C.jpg"); 
    background-size: contain; 
    background-position: center;
    background-repeat: no-repeat;
  }
  }
   .three {
    width: 100%;
    height: 60vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    position: relative;
    background-image: url("../../../assets/image/three-bg.svg");
    background-size: cover;
    background-position: center;
    text-align: center;

    .content {
      width: 100%;
      max-width: 800px;
      margin: 0 auto;
      padding: 2rem;
    }

    .independent-project {
      margin-bottom: 3rem;

      .project-title {
        font-size: 2rem;
        font-weight: bold;
        margin-bottom: 1.5rem;
        color: #2a7f62;
      }

      .project-desc {
        font-size: 1.2rem;
        line-height: 1.8;
        color: #333;

        .highlight {
          font-weight: bold;
          color: #d63031;
        }
      }
    }

    .team-link {
      .team-button {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 12px 24px;
        text-decoration: none;
        border-radius: 8px;
        font-weight: bold;
        font-size: 1.1rem;
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: 0 4px 12px rgba(9, 132, 227, 0.3);

        &:hover {
          transform: translateY(-2px);
          box-shadow: 0 6px 16px rgba(9, 132, 227, 0.4);
        }
      }
    }
  }
</style>
