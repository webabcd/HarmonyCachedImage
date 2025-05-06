import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { cachedImage } from '@webabcd/harmony-cachedimage';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);

    // 初始化
    await cachedImage.init({
      // 用于图片文件存放的沙箱目录
      cacheDirectory: this.context.getApplicationContext().filesDir + "/cache",
      // 图片在本地存储中的缓存时间，单位：秒
      // 每次加载图片都会更新其访问时间，当访问时间超过了缓存时间，则会删除
      cacheSeconds: 86400,
      // 是否启用日志记录
      enableLog: true
    })
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index');
  }
}