import { HomePage } from './HomePage';
import { ProfilePage } from './ProfilePage';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  private controller: TabsController = new TabsController();

  @Builder
  TabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 24, height: 24 })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#1698CE' : '#6B6B6B')
        .fontSize(10)
        .margin({ top: 4 })
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
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
      .tabBar(this.TabBuilder('首页', 0, $r('app.media.startIcon'), $r('app.media.startIcon')))

      TabContent() {
        // 占位，点击跳转
      }
      .tabBar(this.TabBuilder('扫描', 99, $r('app.media.startIcon'), $r('app.media.startIcon')))

      TabContent() {
        ProfilePage()
      }
      .tabBar(this.TabBuilder('我的', 2, $r('app.media.startIcon'), $r('app.media.startIcon')))
    }
    .onChange((index: number) => {
      if (index !== 1) {
        this.currentIndex = index;
      }
    })
    .scrollable(false)
  }
}