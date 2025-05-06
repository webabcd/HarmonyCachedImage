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