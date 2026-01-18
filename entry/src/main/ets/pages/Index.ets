import { HomePage } from './HomePage';
import { ProfilePage } from './ProfilePage';
import { router } from '@kit.ArkUI';
import { HttpUtil } from '../service/HttpUtil';
import { AppColors, AppFonts, AppDurations, AppRadius } from '../common/theme';
import { FavoritesPage } from './FavoritesPage';

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
  TabBuilder(title: string, targetIndex: number, icon: string, iconActive: string, isScanButton: boolean = false, isMiddleButton: boolean = false) {
    Column({ space: 4 }) {
      // 中间加号按钮特殊样式
      if (isMiddleButton) {
        // 加号按钮 - 改为Text组件
        Stack() {
          Text('+')
            .fontSize(28) // 稍微加大字体
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .animation({
              duration: AppDurations.FAST,
              curve: Curve.EaseInOut
            })
        }
        .width(56)    // 圆形按钮直径
        .height(56)   // 圆形按钮直径
        .backgroundColor(AppColors.PRIMARY_ACCENT) // 使用主色调
        .borderRadius(28) // 设置为宽度的一半，形成圆形
        .shadow({
          radius: 8, // 增加阴影半径
          color: AppColors.getPrimaryWithAlpha(0.3), // 30%透明度
          offsetX: 0,
          offsetY: 4
        })
        .scale({
          x: this.tabScaleIndex === targetIndex ? 0.9 : 1.0,
          y: this.tabScaleIndex === targetIndex ? 0.9 : 1.0
        })
        .animation({
          duration: AppDurations.FAST,
          curve: Curve.Sharp
        })
      } else {
        // 普通标签按钮 - 使用 HTML 配色
        Stack() {
          Text(this.currentIndex === targetIndex ? iconActive : icon)
            .fontSize(24)
            .fontColor(this.currentIndex === targetIndex ? AppColors.TEXT_PRIMARY : AppColors.TEXT_SECONDARY)
            .animation({
              duration: AppDurations.FAST,
              curve: Curve.EaseInOut
            })
        }
        .width(40)
        .height(40)
        .borderRadius(AppRadius.LG)
        // HTML 中没有选中状态的背景色，所以去掉背景色
        .backgroundColor('transparent')
        .scale({
          x: this.tabScaleIndex === targetIndex ? 0.9 : 1.0,
          y: this.tabScaleIndex === targetIndex ? 0.9 : 1.0
        })
        .animation({
          duration: AppDurations.FAST,
          curve: Curve.Sharp
        })

        // 普通按钮的标题
        Text(title)
          .fontColor(this.currentIndex === targetIndex ? AppColors.TEXT_PRIMARY : AppColors.TEXT_SECONDARY)
          .fontSize(AppFonts.CAPTION)
          .fontWeight(this.currentIndex === targetIndex ? FontWeight.Medium : FontWeight.Normal)
          .animation({
            duration: AppDurations.FAST,
            curve: Curve.EaseInOut
          })
      }
    }
    .width('100%')
    .height(isMiddleButton ? 70 : 60) // 中间按钮更高
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // 点击动画
      this.tabScaleIndex = targetIndex;
      setTimeout(() => {
        this.tabScaleIndex = -1;
      }, AppDurations.FAST);

      if (isMiddleButton) {
        // 中间加号按钮点击事件 - 跳转到扫描页面
        router.pushUrl({ url: 'pages/RecipePublishPage' });
      }
      else if(isScanButton){
        router.pushUrl({ url: 'pages/ScanPage' });
      }
      else {
        this.currentIndex = targetIndex;
        this.controller.changeIndex(this.currentIndex);
      }
    })
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
      // 第一个标签页
      TabContent() {
        HomePage()
      }
      .tabBar(this.TabBuilder('首页', 0, '🏠', '🏠'))

      // 第二个标签页
      TabContent() {
      }
      .tabBar(this.TabBuilder('扫描', 1, '🔍', '🔍',true))

      // 第三个标签页 - 中间加号按钮（不关联实际页面）
      TabContent() {
        // 空内容，只用于占位
      }
      .tabBar(this.TabBuilder('', 2, '', '', false, true))

      // 第四个标签页
      TabContent() {
        FavoritesPage()
      }
      .tabBar(this.TabBuilder('收藏', 3, '💬', '💬'))

      // 第五个标签页
      TabContent() {
        ProfilePage()
      }
      .tabBar(this.TabBuilder('我的', 4, '👤', '👤'))
    }
    .onChange((index: number) => {
      // 跳过中间按钮的索引（2），不切换页面
      if (index !== 2) {
        this.currentIndex = index;
      }
    })
    .scrollable(false)
    .barBackgroundColor(AppColors.BG_PRIMARY)
    .barMode(BarMode.Fixed)
    .barHeight(80) // 增加底部栏高度以容纳中间按钮
  }
}