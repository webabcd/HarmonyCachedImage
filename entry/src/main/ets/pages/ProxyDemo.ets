/**
 * 代理缓存图片的示例
 */

import { pci } from '@webabcd/harmony-cachedimage'

@Entry
@Component
struct ProxyDemo {

  build() {
    Column({space:10}) {

      // 需要先要初始化，请参见 /entryability/EntryAbility.ets 中相关的初始化代码

      // 代理缓存图片，通过本地 http server 代理图片请求，如果有缓存则从缓存中返回数据，如果无缓存则下载后缓存并返回数据
      Image(pci('https://www-file.huawei.com/-/media/corporate/images/home/logo/huawei_logo.png')).width('100%').height(100).objectFit(ImageFit.Fill)
      Image(pci('https://cdn.deepseek.com/logo.png')).width('100%').height(100).objectFit(ImageFit.Fill)
    }
  }
}