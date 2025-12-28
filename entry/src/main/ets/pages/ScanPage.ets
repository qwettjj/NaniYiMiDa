import { customScan, scanBarcode, scanCore } from '@kit.ScanKit';
import { router, promptAction } from '@kit.ArkUI';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct ScanPage {
  @State userGrant: boolean = false
  @State surfaceId: string = ''
  private mXComponentController: XComponentController = new XComponentController()
  private viewControl: customScan.ViewControl = {
    width: 1920,
    height: 1080,
    surfaceId: ''
  }

  async aboutToAppear() {
    await this.requestCameraPermission();
  }

  async aboutToDisappear() {
    try {
      customScan.stop();
      customScan.release();
    } catch (error) {
      console.error('ScanPage stop/release failed', JSON.stringify(error));
    }
  }

  async requestCameraPermission() {
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      let context = getContext(this) as common.UIAbilityContext;
      let grantStatus = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA']);
      if (grantStatus.authResults[0] === 0) {
        this.userGrant = true;
      } else {
        promptAction.showToast({ message: '请授予相机权限以使用扫码功能' });
      }
    } catch (error) {
      console.error('requestPermissionsFromUser failed', JSON.stringify(error));
    }
  }

  initScan() {
    if (!this.userGrant) {
      return;
    }
    try {
      this.viewControl.surfaceId = this.surfaceId;
      // 初始化扫码
      let scanOptions: scanBarcode.ScanOptions = {
        scanTypes: [scanCore.ScanType.ALL],
        enableMultiMode: true,
        enableAlbum: true
      };
      customScan.init(scanOptions);
      // 开启扫码
      customScan.start(this.viewControl, (error: BusinessError, result: Array<scanBarcode.ScanResult>) => {
        if (error) {
          console.error('Scan failed', JSON.stringify(error));
          return;
        }
        if (result && result.length > 0) {
          // 停止扫描，防止多次触发
          customScan.stop();
          
          let scanResult = result[0];
          let content = scanResult.originalValue;
          
          console.info('Scan result:', content);
          promptAction.showToast({ message: `扫描成功: ${content}` });
          
          // 模拟处理延迟，然后返回
          setTimeout(() => {
             router.back();
          }, 1500);
        }
      });
    } catch (error) {
      console.error('initScan failed', JSON.stringify(error));
    }
  }

  build() {
    Stack() {
      if (this.userGrant) {
        XComponent({
          id: 'componentId',
          type: 'surface',
          controller: this.mXComponentController
        })
          .onLoad(() => {
            this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
            this.initScan();
          })
          .width('100%')
          .height('100%')
      } else {
        Column() {
          Text('需要相机权限')
            .fontColor(Color.White)
            .onClick(() => {
              this.requestCameraPermission();
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('100%')
      }

      // 遮罩层和UI
      Column() {
        // 顶部栏
        Row() {
          Text('< 返回')
            .fontSize(18)
            .fontColor(Color.White)
            .onClick(() => {
              router.back();
            })
          Text('扫描食材')
            .fontSize(18)
            .fontColor(Color.White)
            .margin({ left: 16 })
        }
        .width('100%')
        .padding({ top: 40, left: 20 })
        .alignItems(VerticalAlign.Center)

        // 扫描框示意
        Column()
          .width(250)
          .height(250)
          .border({ width: 2, color: Color.White, radius: 4 })
          .margin({ top: 150 })

        Text('将二维码/条形码放入框内，自动扫描')
          .fontSize(14)
          .fontColor(Color.White)
          .margin({ top: 20 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .hitTestBehavior(HitTestMode.Transparent) // 确保点击事件能穿透到下层（如果有交互的话），但这里主要是覆盖层
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}
