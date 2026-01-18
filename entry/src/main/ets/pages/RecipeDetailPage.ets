import { router, promptAction } from '@kit.ArkUI';
import { RecipeService } from '../service/RecipeService';
import { RecipeVO, RecipeStepVO } from '../model/RecipeModel';
import { HttpUtil } from '../service/HttpUtil';
import { HistoryService } from '../service/HistoryService';
import { FavoriteService } from '../service/FavoriteService';
import { FavoriteVO } from '../model/FavoriteModel';
import { UserService} from '../service/UserService'
import { UserVO } from '../model/UserModel';

// 定义配色接口
interface ThemeColors {
  BG: string; TEXT: string; MUTED: string; MUTED2: string;
  LINE: string; CARD: string; PRIMARY: string; C90: string; C30: string;
}

@Entry
@Component
struct RecipeDetailPage {
  @State recipeId: number = 0;
  @State recipe: RecipeVO | null = null;
  @State isLoading: boolean = true;
  @State isFavorited: boolean = false;
  @State creatorUser: UserVO | null = null;

  // 还原 HTML 中的十色配色方案
  readonly C: ThemeColors = {
    BG: '#FAF6F0',
    TEXT: '#602F27',
    MUTED: 'rgba(96,47,39,.58)',
    MUTED2: 'rgba(96,47,39,.40)',
    LINE: 'rgba(96,47,39,.10)',
    CARD: 'rgba(250,246,240,.80)',
    PRIMARY: '#8E422F', // --c80
    C90: '#74362C',
    C30: '#E3C7A4'
  };

  async aboutToAppear(): Promise<void> {
    HttpUtil.init(getContext(this));
    const params = router.getParams() as Record<string, Object>;
    if (params && params['id']) {
      this.recipeId = params['id'] as number;
      await this.loadRecipeDetail();
      await this.addHistory();
    }
  }

  async addHistory(): Promise<void> {
    try {
      await HistoryService.addHistory(this.recipeId);
    } catch (e) {
      console.warn('History fail', e);
    }
  }

  async loadRecipeDetail(): Promise<void> {
    this.isLoading = true;
    try {
      const result = await RecipeService.getRecipeById(this.recipeId);
      if (result.code === 0 && result.data) {
        this.recipe = result.data;

        // // --- 修改点：解构 ResultVO 获取内部的 UserVO ---
        // const userRes = await UserService.findByUserId(this.recipe.creatorUserId);
        // if (userRes.code === 0 && userRes.data) {
        //   this.creatorUser = userRes.data; // 这里才是真正的 UserVO 类型
        // } else {
        //   console.error('获取用户信息失败:', userRes.message);
        // }
        // // --------------------------------------------

        await this.checkFavoriteStatus();
      }
    } catch (e) {
      console.error('加载详情失败', e);
    } finally {
      this.isLoading = false;
    }
  }

  async checkFavoriteStatus(): Promise<void> {
    const result = await FavoriteService.getCurrentUserFavorites();
    if (result.code === 0 && result.data) {
      this.isFavorited = result.data.some((f: FavoriteVO) => f.recipeId === this.recipeId);
    }
  }

  async toggleFavorite(): Promise<void> {
    try {
      const res = this.isFavorited ?
        await FavoriteService.removeFavorite(this.recipeId) :
        await FavoriteService.addFavorite(this.recipeId);

      if (res.code === 0) {
        this.isFavorited = !this.isFavorited;
        promptAction.showToast({ message: this.isFavorited ? '已收藏' : '已取消收藏' });
      }
    } catch (e) {
      promptAction.showToast({ message: '操作失败' });
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.isLoading) {
        LoadingProgress().width(60).color(this.C.PRIMARY)
      } else if (this.recipe) {
        Scroll() {
          Column() {
            // 1. Hero 封面图
            Stack({ alignContent: Alignment.Top }) {
              Image(this.recipe.imageUrls?.[0] || $r('app.media.startIcon'))
                .width('100%')
                .height(360)
                .objectFit(ImageFit.Cover)

              // 顶部悬浮按钮
              Row() {
                this.IconButton('←', () => router.back())
                Blank()
                this.IconButton(this.isFavorited ? '★' : '☆', () => this.toggleFavorite(), this.isFavorited)
              }
              .width('100%')
              .padding({ left: 14, right: 14, top: 14 })
            }
            .width('100%')

            // 2. 内容详情区
            Column() {
              // 标题
              Text(this.recipe.title || '未命名食谱')
                .fontSize(26)
                .fontWeight(950)
                .fontColor(this.C.TEXT)
                .margin({ top: 10, bottom: 14 })
                .width('100%')

              // 作者信息
              Row({ space: 10 }) {
                Image(this.creatorUser?.imageUrl || $r('app.media.startIcon'))
                  .width(40).height(40).borderRadius(20)
                  .border({ width: 1, color: this.C.LINE })
                Column() {
                  Text(this.creatorUser?.nickName || '用户').fontSize(15).fontWeight(900).fontColor(this.C.TEXT)
                  Text('2025-11-10').fontSize(12).fontColor(this.C.MUTED2)
                }.alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .margin({ bottom: 14 })

              // 描述
              Text(this.recipe.description)
                .fontSize(15)
                .lineHeight(26)
                .fontColor('rgba(96,47,39,.78)')
                .margin({ bottom: 18 })

              // 用料部分
              this.SectionTitle('用料')
              Column() {
                Text(this.recipe.ingredients?.join('；') || '暂无用料信息')
                  .fontSize(14)
                  .lineHeight(24)
                  .fontColor('rgba(96,47,39,.78)')
              }
              .padding(14)
              .width('100%')
              .backgroundColor('rgba(242,229,211,.45)')
              .border({ width: 1, color: 'rgba(96,47,39,.10)' })
              .borderRadius(22)
              .margin({ bottom: 18 })

              // 做法步骤
              this.SectionTitle('做法')
              Column({ space: 12 }) {
                ForEach(this.recipe.steps || [], (step: RecipeStepVO, index: number) => {
                  this.StepCard(index + 1, step)
                })
              }
              .width('100%')
            }
            .padding({ left: 18, right: 18, bottom: 30 })
            .backgroundColor(this.C.BG)
            .borderRadius({ topLeft: 28, topRight: 28 })
            .margin({ top: -30 }) // 向上重叠效果
          }
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.C.BG)
  }

  // 封装：顶部圆形按钮
  @Builder IconButton(icon: string, action: () => void, isActive: boolean = false) {
    Stack() {
      Text(icon)
        .fontSize(20)
        .fontWeight(900)
        .fontColor(isActive ? this.C.TEXT : this.C.C90)
    }
    .width(40)
    .height(40)
    .borderRadius(20)
    .backgroundColor(isActive ? 'rgba(203,142,84,.82)' : 'rgba(242,229,211,.72)')
    .border({ width: 1, color: 'rgba(96,47,39,.12)' })
    .onClick(action)
  }

  // 封装：小节标题
  @Builder SectionTitle(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(950)
      .fontColor(this.C.TEXT)
      .margin({ bottom: 10 })
      .width('100%')
      .padding({ top: 14 })
      .border({ width: { top: 1 }, color: 'rgba(96,47,39,.18)', style: BorderStyle.Dashed })
  }

  // 封装：步骤卡片
  @Builder StepCard(no: number, step: RecipeStepVO) {
    Column() {
      Row({ space: 8 }) {
        Text(`${no}`)
          .width(22).height(22).borderRadius(6)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.C.C30)
          .fontSize(12).fontWeight(950).fontColor(this.C.C90)
        Text('步骤 ' + no).fontSize(13).fontWeight(950).fontColor(this.C.PRIMARY)
      }
      .margin({ bottom: 8 })

      Text(step.description)
        .fontSize(14)
        .lineHeight(24)
        .fontColor('rgba(96,47,39,.80)')

      if (step.imageUrls?.[0]) {
        Image(step.imageUrls[0])
          .width('100%')
          .height(200)
          .borderRadius(12)
          .margin({ top: 10 })
          .objectFit(ImageFit.Cover)
      }
    }
    .padding(14)
    .width('100%')
    .backgroundColor(this.C.CARD)
    .borderRadius(22)
    .border({ width: 1, color: 'rgba(96,47,39,.10)' })
    .shadow({ radius: 30, color: 'rgba(96,47,39,.08)', offsetY: 12 })
  }
}