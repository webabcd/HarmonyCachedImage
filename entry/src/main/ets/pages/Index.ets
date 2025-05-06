/**
 * 用于演示如何使用 @webabcd/harmony-cachedimage
 */

import { router } from '@kit.ArkUI'

@Entry
@Component
struct Index {

  build() {
    Column({space:10}) {
      Button("异步缓存图片的示例").onClick(() => { router.pushUrl({ url: 'pages/AsyncDemo' }) })
      Button("代理缓存图片的示例").onClick(() => { router.pushUrl({ url: 'pages/ProxyDemo' }) })
    }
    .alignItems(HorizontalAlign.Start)
  }
}