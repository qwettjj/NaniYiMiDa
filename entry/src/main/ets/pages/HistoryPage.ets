/**
 * 浏览历史页面
 * 显示当前用户的浏览历史记录
 */
import { router, promptAction } from '@kit.ArkUI';
import { HistoryService } from '../service/HistoryService';
import { RecipeService } from '../service/RecipeService';
import { HistoryVO } from '../model/HistoryModel';
import { RecipeVO } from '../model/RecipeModel';
import { HttpUtil } from '../service/HttpUtil';

@Entry
@Component
struct HistoryPage {
  @State historyList: HistoryVO[] = [];
  @State recipeMap: Map<number, RecipeVO> = new Map();
  @State isLoading: boolean = false;
  @State currentPage: number = 0;
  private pageSize: number = 20;
  @State hasMore: boolean = true;

  async aboutToAppear(): Promise<void> {
    HttpUtil.init(getContext(this));
    await this.loadHistory(true);
  }

  /**
   * 加载浏览历史
   * @param isRefresh 是否是刷新操作
   */
  async loadHistory(isRefresh: boolean = true): Promise<void> {
    if (isRefresh) {
      this.isLoading = true;
      this.currentPage = 0;
    }

    try {
      const result = await HistoryService.getCurrentUserHistory(
        undefined,
        this.currentPage,
        this.pageSize
      );

      if (result.code === 0 && result.data) {
        const pageData = result.data;

        if (isRefresh) {
          this.historyList = pageData.content;
        } else {
          this.historyList = [...this.historyList, ...pageData.content];
        }

        this.hasMore = !pageData.last;
        this.currentPage = pageData.number;

        // 并行加载所有食谱详情
        await this.loadRecipeDetails(pageData.content);

        console.info(`HistoryPage: 成功加载 ${this.historyList.length} 条历史记录`);
      } else {
        promptAction.showToast({ message: result.message || '获取历史失败', duration: 2000 });
      }
    } catch (e) {
      console.error('HistoryPage: 加载历史失败', e instanceof Error ? e.message : JSON.stringify(e));
      promptAction.showToast({ message: '网络异常，请稍后重试', duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 并行加载食谱详情
   */
  async loadRecipeDetails(histories: HistoryVO[]): Promise<void> {
    const recipeIds = histories
      .filter(h => h.recipeId !== null && !this.recipeMap.has(h.recipeId!))
      .map(h => h.recipeId!);

    if (recipeIds.length === 0) {
      return;
    }

    const promises = recipeIds.map(id => RecipeService.getRecipeById(id));
    const results = await Promise.all(promises);

    results.forEach((result, index) => {
      if (result.code === 0 && result.data) {
        this.recipeMap.set(recipeIds[index], result.data);
      }
    });

    // 触发 UI 更新
    this.recipeMap = new Map(this.recipeMap);
  }

  /**
   * 加载更多
   */
  async loadMore(): Promise<void> {
    if (this.isLoading || !this.hasMore) {
      return;
    }
    this.currentPage++;
    await this.loadHistory(false);
  }

  /**
   * 删除历史记录
   */
  async deleteHistory(historyId: number | null): Promise<void> {
    if (historyId === null) {
      return;
    }

    try {
      const result = await HistoryService.deleteHistory(historyId);
      if (result.code === 0) {
        promptAction.showToast({ message: '删除成功', duration: 2000 });
        // 从列表中移除
        this.historyList = this.historyList.filter(h => h.historyId !== historyId);
      } else {
        promptAction.showToast({ message: result.message || '删除失败', duration: 2000 });
      }
    } catch (e) {
      console.error('HistoryPage: 删除历史失败', e instanceof Error ? e.message : JSON.stringify(e));
      promptAction.showToast({ message: '删除失败', duration: 2000 });
    }
  }

  /**
   * 跳转到食谱详情
   */
  goToRecipeDetail(recipeId: number | null): void {
    if (recipeId === null) {
      return;
    }
    router.pushUrl({
      url: 'pages/RecipeDetailPage',
      params: { id: recipeId }
    }).catch((error: Error) => {
      console.error('HistoryPage: 跳转失败 -', error.message);
    });
  }

  /**
   * 格式化时间
   */
  formatTime(timestamp: string | null): string {
    if (!timestamp) {
      return '未知时间';
    }
    // 简单格式化，实际项目中可使用更完善的时间库
    return timestamp.substring(0, 19).replace('T', ' ');
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.startIcon')) // TODO: Replace with back icon
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })
        Text('浏览历史')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 10 })
      }
      .width('100%')
      .height(50)
      .padding({ left: 15, right: 15 })
      .backgroundColor(Color.White)
      .alignItems(VerticalAlign.Center)

      if (this.isLoading && this.currentPage === 0) {
        // 首次加载中状态
        Column() {
          LoadingProgress().width(50).height(50)
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else if (this.historyList.length === 0) {
        // 空状态
        Column() {
          Image($r('app.media.startIcon')) // TODO: Replace with empty icon
            .width(80)
            .height(80)
            .opacity(0.3)
          Text('暂无浏览历史')
            .fontSize(16)
            .fontColor('#999')
            .margin({ top: 20 })
          Text('浏览食谱后会自动记录')
            .fontSize(14)
            .fontColor('#CCC')
            .margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else {
        // 历史列表
        List() {
          ForEach(this.historyList, (history: HistoryVO) => {
            ListItem() {
              this.buildHistoryItem(history)
            }
            .onClick(() => this.goToRecipeDetail(history.recipeId))
          }, (history: HistoryVO) => history.historyId?.toString() || '')

          // 加载更多提示
          if (this.hasMore) {
            ListItem() {
              Row() {
                if (this.isLoading) {
                  LoadingProgress().width(30).height(30)
                  Text('加载中...').fontSize(14).fontColor('#999').margin({ left: 8 })
                } else {
                  Text('下拉加载更多').fontSize(14).fontColor('#999')
                }
              }
              .width('100%')
              .height(50)
              .justifyContent(FlexAlign.Center)
            }
            .onClick(() => {
              this.loadMore();
            })
          } else {
            ListItem() {
              Text('没有更多了')
                .fontSize(14)
                .fontColor('#999')
                .width('100%')
                .height(50)
                .textAlign(TextAlign.Center)
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
        .divider({ strokeWidth: 1, color: '#F0F0F0' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildHistoryItem(history: HistoryVO) {
    Row() {
      // 食谱封面
      if (this.recipeMap.get(history.recipeId!) && 
          this.recipeMap.get(history.recipeId!)!.imageUrls && 
          this.recipeMap.get(history.recipeId!)!.imageUrls.length > 0) {
        Image(this.recipeMap.get(history.recipeId!)!.imageUrls[0])
          .width(100)
          .height(100)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
      } else {
        Column()
          .width(100)
          .height(100)
          .backgroundColor('#F0F0F0')
          .borderRadius(8)
      }

      // 食谱信息
      Column() {
        Text(this.recipeMap.get(history.recipeId!) && this.recipeMap.get(history.recipeId!)!.title ? 
             this.recipeMap.get(history.recipeId!)!.title : '未知食谱')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(`浏览时间: ${this.formatTime(history.createTime)}`)
          .fontSize(12)
          .fontColor('#999')
          .margin({ top: 5 })
          .width('100%')

        // 操作按钮
        Row() {
          Button('查看')
            .fontSize(12)
            .height(28)
            .backgroundColor('#1698CE')
            .fontColor(Color.White)
            .borderRadius(14)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.goToRecipeDetail(history.recipeId);
            })

          Button('删除')
            .fontSize(12)
            .height(28)
            .backgroundColor('#FF6B6B')
            .fontColor(Color.White)
            .borderRadius(14)
            .padding({ left: 16, right: 16 })
            .margin({ left: 10 })
            .onClick(() => {
              this.deleteHistory(history.historyId);
            })
        }
        .margin({ top: 8 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
  }
}
