# @webabcd/harmony-cachedimage
为 Image 组件提供 http 或 https 地址的图片缓存能力

## 简介
[harmony-cachedimage](https://ohpm.openharmony.cn/#/cn/detail/@webabcd%2Fharmony-cachedimage)
为 Image 组件提供 http 或 https 地址的图片缓存能力
模式一：将 http 或 https 地址的图片缓存到沙箱存储（可以指定图片的缓存时间），然后返回图片的沙箱存储的地址，用于 Image 组件显示

## 下载安装
`ohpm i @webabcd/harmony-cachedimage`

## API详解
| 方法 | 介绍 |
|---|---|
| init | 初始化 | 
| aci | 异步缓存图片 |

## 示例代码
```
/**
 * 用于演示如何使用 @webabcd/harmony-cachedimage
 */

import { aci, cachedImage } from '@webabcd/harmony-cachedimage'

@Entry
@Component
struct Index {

  @State message: string = ''

  @State imageUrl1: string = ""
  @State imageUrl2: string = ""
  @State imageUrl3: string = ""

  async aboutToAppear() {

    // 初始化
    await cachedImage.init({
      // 用于图片文件存放的沙箱目录
      cacheDirectory: getContext().getApplicationContext().filesDir + "/cache",
      // 图片在本地存储中的缓存时间，单位：秒
      // 每次加载图片都会更新其访问时间，当访问时间超过了缓存时间，则会删除
      cacheSeconds: 86400,
      // 是否启用日志记录
      enableLog: true
    })

    // 异步缓存图片，如果缓存成功或缓存命中成功则返 file:// 开头的缓存地址，否则返回原 url
    this.imageUrl1 = await aci('https://www-file.huawei.com/-/media/corporate/images/home/logo/huawei_logo.png')
    this.imageUrl2 = await aci('https://cdn.deepseek.com/logo.png')
    this.imageUrl3 = await aci('https://xxx.xxx.xxx/logo.png')

    this.message += `imageUrl1:${this.imageUrl1}\n`
    this.message += `imageUrl2:${this.imageUrl2}\n`
    this.message += `imageUrl3:${this.imageUrl3}\n`
  }

  build() {
    Column({space:10}) {

      Image(this.imageUrl1).width('100%').height(100).objectFit(ImageFit.Fill)
      Image(this.imageUrl2).width('100%').height(100).objectFit(ImageFit.Fill)
      Image(this.imageUrl3).width('100%').height(100).objectFit(ImageFit.Fill)

      Text(this.message)
    }
  }
}
```

## Demo
Demo 的下载地址 [harmony-cachedimage-demo](https://gitee.com/webabcd/HarmonyCachedImage)