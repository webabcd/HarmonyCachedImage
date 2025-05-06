# @webabcd/harmony-cachedimage
为 Image 组件提供 http 或 https 地址的图片缓存能力

## 简介
[harmony-cachedimage](https://ohpm.openharmony.cn/#/cn/detail/@webabcd%2Fharmony-cachedimage)
为 Image 组件提供 http 或 https 地址的图片缓存能力
异步缓存方式：如果下载并缓存成功或缓存命中成功则返 file:// 开头的缓存地址，否则返回原 url，用于 Image 组件显示
代理缓存方式：通过本地 http server 代理图片请求，如果有缓存则从缓存中返回数据，如果无缓存则下载后缓存并返回数据，用于 Image 组件显示

## 下载安装
`ohpm i @webabcd/harmony-cachedimage`

## API详解
| 方法   | 介绍                  |
|------|---------------------|
| init | 初始化（传入一个 Config 对象） | 
| aci  | 异步缓存图片              |
| pci  | 代理缓存图片              |

## Config对象说明
| 属性             | 介绍                 |
|----------------|--------------------|
| cacheDirectory | 用于图片文件存放的沙箱目录      | 
| cacheSeconds   | 图片在本地存储中的缓存时间，单位：秒 |
| enableLog      | 是否启用日志记录           |


## 示例代码（异步缓存方式）
```
/**
 * 异步缓存图片的示例
 */

import { aci } from '@webabcd/harmony-cachedimage'

@Entry
@Component
struct AsyncDemo {

  @State message: string = ''

  @State imageUrl1: string = ""
  @State imageUrl2: string = ""
  @State imageUrl3: string = ""

  async aboutToAppear() {

    // 需要先要初始化，请参见 /entryability/EntryAbility.ets 中相关的初始化代码

    // 异步缓存图片，如果下载并缓存成功或缓存命中成功则返 file:// 开头的缓存地址，否则返回原 url
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

## 示例代码（代理缓存方式）
```
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
```

## Demo
Demo 的下载地址 [harmony-cachedimage-demo](https://gitee.com/webabcd/HarmonyCachedImage)