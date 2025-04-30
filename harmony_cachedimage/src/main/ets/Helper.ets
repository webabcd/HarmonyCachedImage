import { fileIo as fs } from '@kit.CoreFileKit';
import { http } from '@kit.NetworkKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { PathHelper } from '@webabcd/harmony-utils';

export class Helper {

  static async removeFiles(dir: string, minTime: number) {
    try {
      let fileNames = await fs.listFile(dir)
      for (let i = 0; i < fileNames.length; i++) {
        let fileName = fileNames[i]
        let filePath = PathHelper.join(dir, fileName)
        let fileInfo = await fs.stat(filePath)
        if (fileInfo.mtime * 1000 < minTime) {
          await fs.unlink(filePath)
        }
      }
    }
    catch (error) {

    }
  }

  static download(url: string, filePath: string, callback: AsyncCallback<void>) {

    let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC | fs.OpenMode.APPEND)
    let fileOffset = 0

    let httpRequest = http.createHttp()

    httpRequest.requestInStream(
      url,
      {
        method: http.RequestMethod.GET,
      },
      (err: BusinessError, responseCode: number) => {
        if (!err) {
          if (responseCode < 400) {
            callback(undefined)
          } else {
            callback({
              code: responseCode,
              message: '下载失败',
              name: ''
            })
          }
        } else {
          callback(err)
        }
      }
    )

    httpRequest.on("dataReceiveProgress", (data: http.DataReceiveProgressInfo) => {

    })

    httpRequest.on('dataReceive', async (data: ArrayBuffer) => {
      let writeLength = await fs.write(file.fd, data, {
        offset: fileOffset,
        length: data.byteLength,
      })
      fileOffset += writeLength
    })

    httpRequest.on('dataEnd', () => {
      httpRequest.off('dataReceiveProgress')
      httpRequest.off('dataReceive')
      httpRequest.off('dataEnd')
      httpRequest.destroy()

      fs.closeSync(file)
    })
  }
}