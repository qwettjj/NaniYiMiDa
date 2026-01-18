import { router, promptAction } from '@kit.ArkUI';
import { RecipeService } from '../service/RecipeService';
import { RecipeVO, RecipeStepVO, IngredientEnum } from '../model/RecipeModel';
import { HttpUtil } from '../service/HttpUtil';

@Entry
@Component
struct RecipePublishPage {
  @State title: string = '';
  @State description: string = '';
  @State ingredients: string = '';
  @State steps: RecipeStepVO[] = [];
  @State recipeId: number | null = null;
  @State isSubmitting: boolean = false;

  // 对应 draft.html 的八色体系
  // readonly COLORS = {
  //   // TEXT: '#602F27',         // --c100
  //   // MUTED: 'rgba(96,47,39,0.55)', // --muted
  //   // STROKE: 'rgba(96,47,39,0.10)', // --stroke
  //   // CHIP_BG: 'rgba(242,229,211,0.55)', // --chip-bg
  //   // PRIMARY: '#CB8E54',      // --c50
  //   // PRIMARY_DARK: '#A85835'  // --c70
  // };

  async aboutToAppear() {
    HttpUtil.init(getContext(this));
  }

  addStep() {
    this.steps.push({
      stepId: null,
      stepNumber: this.steps.length + 1,
      description: '',
      imageUrls: []
    });
  }

  deleteStep(index: number) {
    this.steps.splice(index, 1);
    this.steps.forEach((step, idx) => {
      step.stepNumber = idx + 1;
    });
  }

  async publishRecipe() {
    if (!this.title.trim()) { promptAction.showToast({ message: '请输入食谱标题' }); return; }
    if (!this.description.trim()) { promptAction.showToast({ message: '请输入食谱描述' }); return; }
    if (this.steps.length === 0) { promptAction.showToast({ message: '请至少添加一个步骤' }); return; }

    this.isSubmitting = true;
    try {
      const createRes = await RecipeService.createRecipeDraft(this.title);
      if (createRes.code !== 0 || !createRes.data) throw new Error(createRes.message || '创建草稿失败');
      this.recipeId = createRes.data;

      await RecipeService.modifyRecipeDescription(this.recipeId, this.description);

      if (this.ingredients.trim()) {
        await RecipeService.modifyRecipeIngredient(this.recipeId, this.ingredients);
      }

      for (let i = 0; i < this.steps.length; i++) {
        const desc = this.steps[i].description || '';
        if (desc.trim()) {
          await RecipeService.addRecipeStep(this.recipeId, {
            stepId: null,
            stepNumber: i + 1,
            description: desc,
            imageUrls: []
          });
        }
      }

      const publishRes = await RecipeService.publishRecipe(this.recipeId);
      if (publishRes.code === 0) {
        promptAction.showToast({ message: '发布成功！' });
        setTimeout(() => router.back(), 1500);
      } else {
        throw new Error(publishRes.message || '发布失败');
      }
    } catch (e) {
      promptAction.showToast({ message: e instanceof Error ? e.message : '发布失败' });
    } finally {
      this.isSubmitting = false;
    }
  }

  // 辅助组件：食材标签
  @Builder IngredientChip(label: string) {
    Text(label)
      .fontSize(13)
      .fontColor('rgba(96,47,39,0.72)')
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor('rgba(242,229,211,0.55)')
      .borderRadius(999)
      .margin({ right: 10, bottom: 10 })
      .onClick(() => {
        this.ingredients += (this.ingredients ? '、' : '') + label;
      })
  }

  build() {
    Column() {
      // 顶部导航 (简易版)
      Row() {
        Text('←')
          .fontSize(20)
          .fontColor('#602F27')
          .onClick(() => router.back())
        Blank()
      }
      .width('100%')
      .height(44)
      .padding({ left: 18, right: 18 })

      Scroll() {
        Column() {
          // 1. 标题输入 (匹配 HTML .title-input)
          TextInput({ placeholder: '添加菜谱标题', text: this.title })
            .placeholderColor('rgba(96,47,39,0.32)')
            .fontSize(26)
            .fontWeight(900)
            .fontColor('#602F27')
            .backgroundColor(Color.Transparent)
            .padding({ left: 2, bottom: 10 })
            .onChange(v => this.title = v)

          // 2. 描述输入 (匹配 HTML .desc-input)
          TextArea({ placeholder: '输入这道美食背后的故事', text: this.description })
            .placeholderColor('rgba(96,47,39,0.35)')
            .fontSize(15)
            .fontColor('#74362C')
            .backgroundColor(Color.Transparent)
            .padding({ top: 12, bottom: 14 })
            .border({ width: { bottom: 1 }, color: 'rgba(96,47,39,0.10)' })
            .onChange(v => this.description = v)

          // 3. 菜谱封面占位
          Column() {
            Column() {
              Text('＋').fontSize(40).fontColor('rgba(96,47,39,0.45)')
            }
            .width('100%')
            .height(180)
            .backgroundColor('rgba(242,229,211,0.55)')
            .borderRadius(18)
            .border({ width: 1.5, color: 'rgba(96,47,39,0.25)', style: BorderStyle.Dashed })
            .justifyContent(FlexAlign.Center)

            Text('添加菜谱封面')
              .fontSize(13)
              .fontColor('rgba(96,47,39,0.55)')
              .margin({ top: 8 })
          }
          .margin({ top: 20, bottom: 20 })

          // 4. 用料部分
          Column() {
            Row() {
              Text('用料').fontSize(16).fontWeight(900).fontColor('#602F27')
              Text(' i ').fontSize(12).fontColor('rgba(96,47,39,0.55)')
                .margin({ left: 8 })
                .border({ width: 1, color: 'rgba(96,47,39,0.22)' })
                .borderRadius(9)
            }.width('100%').margin({ bottom: 10 })

            Text('猜你可能会用到：').fontSize(12).fontColor('rgba(96,47,39,0.55)').margin({ bottom: 10 }).width('100%')

            Flex({ wrap: FlexWrap.Wrap }) {
              this.IngredientChip('油')
              this.IngredientChip('水')
              this.IngredientChip('面粉')
              this.IngredientChip('细砂糖')
            }

            TextArea({ placeholder: '食材：例如 鸡蛋 2 个，葱 1 根...', text: this.ingredients })
              .fontSize(14)
              .placeholderColor('rgba(96,47,39,0.32)')
              .fontColor('#602F27')
              .backgroundColor('rgba(242,229,211,0.45)')
              .borderRadius(16)
              .padding(12)
              .onChange(v => this.ingredients = v)
          }.margin({ top: 10 })

          // 5. 做法部分
          Column() {
            Row() {
              Text('做法').fontSize(16).fontWeight(900).fontColor('#602F27')
              Blank()
              Button('再增加一步')
                .fontSize(13)
                .fontWeight(900)
                .fontColor('rgba(96,47,39,0.72)')
                .backgroundColor('rgba(242,229,211,0.55)')
                .borderRadius(999)
                .height(38)
                .padding({ left: 14, right: 14 })
                .onClick(() => this.addStep())
            }.width('100%').margin({ top: 25, bottom: 12 })

            ForEach(this.steps, (step: RecipeStepVO, index: number) => {
              Column() {
                Row() {
                  Text(`步骤 ${index + 1}`).fontSize(14).fontWeight(900).fontColor('#602F27')
                  Blank()
                  Text('删除').fontSize(12).fontColor(Color.Red).onClick(() => this.deleteStep(index))
                }.width('100%').margin({ bottom: 8 })

                TextArea({ placeholder: `请在这里填写具体做法……`, text: step.description || '' })
                  .fontSize(13)
                  .fontColor('rgba(96,47,39,0.68)')
                  .backgroundColor('rgba(242,229,211,0.55)')
                  .borderRadius(16)
                  .padding(12)
                  .onChange(v => this.steps[index].description = v)
              }.margin({ bottom: 15 })
            })
          }

          // 6. 发布按钮 (匹配 HTML .publish-btn)
          Button(this.isSubmitting ? '正在发布...' : '发布这个菜谱')
            .width('100%')
            .height(52)
            .margin({ top: 30, bottom: 80 })
            .borderRadius(18)
            .fontSize(16)
            .fontWeight(900)
            .fontColor('#FAF6F0')
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [['#CB8E54', 0.0], ['#A85835', 1.0]]
            })
            .shadow({ radius: 26, color: 'rgba(168,88,53,0.22)', offsetY: 14 })
            .onClick(() => this.publishRecipe())
        }
        .padding({ left: 18, right: 18 })
        .width('100%') // 确保内部 Column 宽度撑满
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Auto) // 显示滚动条
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAF6F0')
  }
}