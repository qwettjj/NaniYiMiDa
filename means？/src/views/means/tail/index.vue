<template>
  <footer class="footer">
    <div class="footer-container">
      <div class="footer-content">
        <div class="logo-section">
          <img src="../../../assets/image/logo.png" alt="Logo" class="footer-logo" />
          <span class="app-name">何宜胃</span>
        </div>
        <p class="copyright">© 2025 何宜胃 版权所有</p>
        <p class="declaration">本网站所有内容均属虚构，何意味？？？</p>
        <div class="links">
          <a href="#">隐私政策</a>
          <a href="#">用户协议</a>
          <a href="#">联系方式</a>
        </div>

      </div>
    </div>
  </footer>
</template>

<script setup lang="ts" name="Footer"></script>

<style scoped lang="scss">
.footer {
  width: 100%;
  position: relative;

  
  &::before {
    content: '';
    position: absolute;
    width: 100%;
    height: 100%;
    background-image: url('../../../assets/image/tail.png');
    background-size: cover;
    background-position: left center;
    opacity: 0.5; 
    z-index: -1;
  }
}

.footer-container {
  display: flex;
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
}

.footer-content {
  flex: 1;
  color: #333;
  
  .logo-section {
    display: flex;
    align-items: center;
    margin-bottom: 20px;
    
    .footer-logo {
      height: 40px;
      width: auto;
      margin-right: 12px;
    }
    
    .app-name {
      font-size: 18px;
      font-weight: bold;
    }
  }
  
  .copyright {
    font-size: 14px;
    margin-bottom: 8px;
  }
  
  .declaration {
    font-size: 12px;
    color: #666;
    margin-bottom: 16px;
    max-width: 60%;
  }
  
  .links {
    display: flex;
    gap: 20px;
    
    a {
      font-size: 14px;
      color: #1890ff;
      text-decoration: none;
      
      &:hover {
        text-decoration: underline;
      }
    }
  }
}

</style>