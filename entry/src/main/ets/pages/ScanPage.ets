import { customScan, scanBarcode, scanCore } from '@kit.ScanKit';
import { router, promptAction } from '@kit.ArkUI';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MOCK_PRODUCTS, Product } from '../model/ProductModel';

@CustomDialog
struct ProductDetailDialog {
  controller?: CustomDialogController
  product: Product | null = null
  onClose: () => void = () => {}

  build() {
    Column() {
      if (this.product) {
        Image(this.product.imageUrl)
          .width(100)
          .height(100)
          .margin({ top: 20, bottom: 10 })
        
        Text(this.product.name)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 10 })
        
        Text('配料表：')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Start)
          .margin({ left: 20, top: 10 })
        
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.product.ingredients, (item: string) => {
            Text(item)
              .fontSize(14)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#F5F5F5')
              .margin(4)
              .borderRadius(4)
              .fontColor(this.product?.allergens.includes(item) ? Color.Red : Color.Black)
          })
        }
        .padding({ left: 16, right: 16 })

        if (this.product.allergens.length > 0) {
           Text('⚠️ 过敏源提示：' + this.product.allergens.join('、'))
            .fontSize(14)
            .fontColor(Color.Red)
            .margin({ top: 10, bottom: 20 })
        }
      }

      Button('关闭')
        .onClick(() => {
          if (this.controller) {
            this.controller.close()
          }
          this.onClose()
        })
        .margin({ bottom: 20, top: 10 })
    }
    .backgroundColor(Color.White)
    .borderRadius(16)
    .width('90%')
  }
}

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
  
  dialogController: CustomDialogController | null = null
  @State currentProduct: Product | null = null
  isScanning: boolean = true

  async aboutToAppear() {
    await this.requestCameraPermission();
  }

  async aboutToDisappear() {
    this.stopScan();
  }

  stopScan() {
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
    if (!this.userGrant || !this.surfaceId) {
      return;
    }
    try {
      this.viewControl.surfaceId = this.surfaceId;
      let options: scanBarcode.ScanOptions = {
        scanTypes: [scanCore.ScanType.ALL],
        enableMultiMode: true,
        enableAlbum: true
      };
      
      customScan.init(options);
      customScan.start(this.viewControl, (error: BusinessError, result: Array<scanBarcode.ScanResult>) => {
        if (error) {
          console.error('Scan start failed', JSON.stringify(error));
          return;
        }
        if (result && result.length > 0 && this.isScanning) {
          const code = result[0].originalValue;
          console.info('Scanned code:', code);
          this.handleScanResult(code);
        }
      });
    } catch (error) {
      console.error('initScan failed', JSON.stringify(error));
    }
  }

  handleScanResult(code: string) {
    if (MOCK_PRODUCTS[code]) {
      this.isScanning = false;
      this.currentProduct = MOCK_PRODUCTS[code];
      this.showDialog();
    } else {
       // promptAction.showToast({ message: '未找到该商品信息: ' + code });
    }
  }

  showDialog() {
    if (this.dialogController) {
      this.dialogController.close();
      this.dialogController = null;
    }
    this.dialogController = new CustomDialogController({
      builder: ProductDetailDialog({
        product: this.currentProduct,
        onClose: () => {
          this.restartScan();
        }
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
      customStyle: true,
      cancel: () => {
        this.restartScan();
      }
    });
    this.dialogController.open();
  }

  restartScan() {
    this.isScanning = true;
    this.currentProduct = null;
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
        Text('需要相机权限')
          .fontSize(20)
          .fontColor(Color.White)
      }

      // Overlay UI
      Column() {
        Row() {
          // Back Button
          Text('< 返回')
            .fontColor(Color.White)
            .fontSize(18)
            .onClick(() => {
              router.back();
            })
            .margin({ left: 20, top: 40 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        
        Blank()

        Text('将二维码/条形码放入框内，自动扫描')
          .fontSize(16)
          .fontColor(Color.White)
          .margin({ bottom: 100 })
          
        // Debug buttons for simulator
        Row() {
          Button('模拟 NANI_001')
            .onClick(() => this.handleScanResult('NANI_001'))
            .margin(5)
            .backgroundColor('rgba(255,255,255,0.3)')
          Button('模拟 NANI_002')
            .onClick(() => this.handleScanResult('NANI_002'))
            .margin(5)
            .backgroundColor('rgba(255,255,255,0.3)')
        }
        .margin({ bottom: 50 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}
