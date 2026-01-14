import { HomePage } from './HomePage';
import { ProfilePage } from './ProfilePage';
import { router } from '@kit.ArkUI';
import { HttpUtil } from '../service/HttpUtil';
import { AppColors, AppFonts, AppDurations, AppRadius } from '../common/theme';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State tabScaleIndex: number = -1; // 用于按钮点击动画
  private controller: TabsController = new TabsController();

  /**
   * 页面初始化时重新设置 Context
   * 解决 Previewer 环境下 Context 动态获取失败的问题
   */
  aboutToAppear(): void {
    try {
      HttpUtil.init(getContext(this));
    } catch (e) {
      console.warn('Index: 初始化 HttpUtil 失败 -', JSON.stringify(e));
    }
  }

  @Builder
  TabBuilder(title: string, targetIndex: number, icon: string, iconActive: string) {
    Column({ space: 4 }) {
      // 图标容器
      Stack() {
        Text(this.currentIndex === targetIndex ? iconActive : icon)
          .fontSize(24)
          .fontColor(this.currentIndex === targetIndex ? AppColors.PRIMARY : AppColors.TEXT_TERTIARY)
          .animation({
            duration: AppDurations.FAST,
            curve: Curve.EaseInOut
          })
      }
      .width(40)
      .height(40)
      .borderRadius(AppRadius.LG)
      .backgroundColor(this.currentIndex === targetIndex ? 
        `${AppColors.PRIMARY}15` : 'transparent')
      .scale({ 
        x: this.tabScaleIndex === targetIndex ? 0.9 : 1.0, 
        y: this.tabScaleIndex === targetIndex ? 0.9 : 1.0 
      })
      .animation({
        duration: AppDurations.FAST,
        curve: Curve.Sharp
      })

      // 标题
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? AppColors.PRIMARY : AppColors.TEXT_TERTIARY)
        .fontSize(AppFonts.CAPTION)
        .fontWeight(this.currentIndex === targetIndex ? AppFonts.WEIGHT_MEDIUM : AppFonts.WEIGHT_REGULAR)
        .animation({
          duration: AppDurations.FAST,
          curve: Curve.EaseInOut
        })
    }
    .width('100%')
    .height(60)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // 点击动画
      this.tabScaleIndex = targetIndex;
      setTimeout(() => {
        this.tabScaleIndex = -1;
      }, AppDurations.FAST);

      if (targetIndex === 99) {
        router.pushUrl({ url: 'pages/ScanPage' });
      } else {
        this.currentIndex = targetIndex;
        this.controller.changeIndex(this.currentIndex);
      }
    })
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
      TabContent() {
        HomePage()
      }
      .tabBar(this.TabBuilder('首页', 0, '🏠', '🏠'))

      TabContent() {
        // 占位，点击跳转
      }
      .tabBar(this.TabBuilder('扫描', 99, '📷', '📷'))

      TabContent() {
        ProfilePage()
      }
      .tabBar(this.TabBuilder('我的', 2, '👤', '👤'))
    }
    .onChange((index: number) => {
      if (index !== 1) {
        this.currentIndex = index;
      }
    })
    .scrollable(false)
    .barBackgroundColor(AppColors.BG_PRIMARY)
    .barMode(BarMode.Fixed)
  }
}