/**
 * 草稿箱页面
 * 显示当前用户的所有草稿食谱
 */
import { router, promptAction } from '@kit.ArkUI';
import { RecipeService } from '../service/RecipeService';
import { RecipeVO } from '../model/RecipeModel';
import { HttpUtil } from '../service/HttpUtil';

@Entry
@Component
struct DraftPage {
  @State drafts: RecipeVO[] = [];
  @State isLoading: boolean = false;

  async aboutToAppear(): Promise<void> {
    HttpUtil.init(getContext(this));
    await this.loadDrafts();
  }

  /**
   * 加载草稿列表
   */
  async loadDrafts(): Promise<void> {
    this.isLoading = true;
    try {
      const result = await RecipeService.getCurrentUserDrafts();
      if (result.code === 0 && result.data) {
        this.drafts = result.data;
        console.info(`DraftPage: 成功加载 ${this.drafts.length} 个草稿`);
      } else {
        promptAction.showToast({ message: result.message || '获取草稿失败', duration: 2000 });
      }
    } catch (e) {
      console.error('DraftPage: 加载草稿失败', e instanceof Error ? e.message : JSON.stringify(e));
      promptAction.showToast({ message: '网络异常，请稍后重试', duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 跳转到草稿编辑页
   */
  goToEditDraft(recipeId: number | null): void {
    if (recipeId === null) {
      return;
    }
    // TODO: 创建 RecipeEditPage 后取消注释
    // router.pushUrl({
    //   url: 'pages/RecipeEditPage',
    //   params: { id: recipeId }
    // }).catch((error: Error) => {
    //   console.error('DraftPage: 跳转失败 -', error.message);
    // });
    promptAction.showToast({ message: `编辑草稿 ID: ${recipeId}（编辑页待实现）`, duration: 2000 });
  }

  /**
   * 删除草稿
   */
  async deleteDraft(recipeId: number | null): Promise<void> {
    if (recipeId === null) {
      return;
    }

    try {
      const result = await RecipeService.deleteRecipe(recipeId);
      if (result.code === 0) {
        promptAction.showToast({ message: '删除成功', duration: 2000 });
        // 刷新列表
        await this.loadDrafts();
      } else {
        promptAction.showToast({ message: result.message || '删除失败', duration: 2000 });
      }
    } catch (e) {
      console.error('DraftPage: 删除草稿失败', e instanceof Error ? e.message : JSON.stringify(e));
      promptAction.showToast({ message: '删除失败', duration: 2000 });
    }
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
        Text('我的草稿')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 10 })
      }
      .width('100%')
      .height(50)
      .padding({ left: 15, right: 15 })
      .backgroundColor(Color.White)
      .alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        // 加载中状态
        Column() {
          LoadingProgress().width(50).height(50)
          Text('加载中...').fontSize(14).fontColor('#999').margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else if (this.drafts.length === 0) {
        // 空状态
        Column() {
          Image($r('app.media.startIcon')) // TODO: Replace with empty icon
            .width(80)
            .height(80)
            .opacity(0.3)
          Text('暂无草稿')
            .fontSize(16)
            .fontColor('#999')
            .margin({ top: 20 })
          Text('创建食谱后会自动保存草稿')
            .fontSize(14)
            .fontColor('#CCC')
            .margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      } else {
        // 草稿列表
        List() {
          ForEach(this.drafts, (draft: RecipeVO) => {
            ListItem() {
              Row() {
                // 草稿封面
                if (draft.imageUrls && draft.imageUrls.length > 0) {
                  Image(draft.imageUrls[0])
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

                // 草稿信息
                Column() {
                  Text(draft.title || '未命名草稿')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')

                  Text(draft.description || '暂无描述')
                    .fontSize(14)
                    .fontColor('#666')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 5 })
                    .width('100%')

                  // 操作按钮
                  Row() {
                    Button('编辑')
                      .fontSize(12)
                      .height(28)
                      .backgroundColor('#1698CE')
                      .fontColor(Color.White)
                      .borderRadius(14)
                      .padding({ left: 16, right: 16 })
                      .onClick(() => {
                        this.goToEditDraft(draft.recipeId);
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
                        this.deleteDraft(draft.recipeId);
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
          }, (draft: RecipeVO, index: number) => `${draft.recipeId}_${index}`)
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
}
