import { fileIo as fs } from '@kit.CoreFileKit';
import { Helper } from './Helper';
import { PathHelper, CryptoHelper, log, model, UrlHelper } from "@webabcd/harmony-utils";
import { HttpRequest, HttpResponse, httpServer } from "@webabcd/harmony-httpserver";
import { ArkTSUtils } from '@kit.ArkTS';

/**
 * 异步缓存图片
 * @param url 图片的 url
 * @returns 如果缓存成功或缓存命中成功则返 file:// 开头的缓存地址，否则返回原 url
 */
export async function aci(url: string): Promise<string> {
  return await CachedImage.getInstance().aci(url)
}

/**
 * 代理缓存图片
 * @param url 图片的 url
 * @returns 返回图片的代理地址
 */
export function pci(url: string): string {
  return CachedImage.getInstance().pci(url)
}

export interface Config {
  /**
   * 用于图片文件存放的沙箱目录
   */
  cacheDirectory: string
  /**
   * 图片在本地存储中的缓存时间，单位：秒
   * 每次加载图片都会更新其访问时间，当访问时间超过了缓存时间，则会删除
   * 默认值为 86400
   */
  cacheSeconds?: number
  /**
   * 是否启用日志记录（默认开启）
   */
  enableLog?: boolean
}

class CachedImage {
  private static cachedImage = new CachedImage();
  public static getInstance() {
    return CachedImage.cachedImage;
  }

  port: number = -1

  config: Config = {} as Config
  /**
   * 初始化
   * @param config
   */
  public async init(config: Config) {
    this.config = config

    if (!config.enableLog) {
      config.enableLog = true
    }
    log.LOGLEVEL = config.enableLog ? model.LogLevel.DEBUG : model.LogLevel.NONE

    if (!config.cacheSeconds) {
      config.cacheSeconds = 86400
    }
    await Helper.removeFiles(config.cacheDirectory, new Date().getTime() - config.cacheSeconds * 1000)

    this.initHttpServer()

    log.i(`初始化完成 cacheDirectory:${config.cacheDirectory}, cacheSeconds:${config.cacheSeconds}, enableLog:${config.enableLog}`)
  }

  private initHttpServer() {
    httpServer.start(8080, (err, port) => {
      this.port = port
    })
    httpServer.handleHttpRequestAsync((httpRequest:HttpRequest) => {
      // 如果目录不存在则创建
      fs.mkdir(this.config.cacheDirectory, true)

      let url = `http://127.0.0.1:${this.port}${httpRequest.url}`
      url = UrlHelper.query(url, "url")
      url = UrlHelper.decode(url)

      let urlMd5 = CryptoHelper.md5(url)
      let filePath = PathHelper.join(this.config.cacheDirectory, urlMd5)

      return new Promise(async (resolve, reject) => {
        let httpResponse = { } as HttpResponse

        // 如果缓存文件存在，则从缓存文件中读取数据
        let exist = await fs.access(filePath, fs.AccessModeType.EXIST)
        if (exist) {
          let fileInfo = await fs.stat(filePath)
          if (fileInfo.size > 0) {
            fs.utimes(filePath, new Date().getTime())

            let inputStream = await fs.createStream(filePath, 'r+');
            let buffer = new ArrayBuffer(fileInfo.size);
            let readLength = await inputStream.read(buffer, {
              offset: 0,
              length: buffer.byteLength
            });
            await inputStream.close();

            httpResponse.headers = {}
            httpResponse.headers["Content-Type"] = 'image/png'
            httpResponse.result = buffer

            log.i(`缓存命中 ${filePath}`)

            resolve(httpResponse)
          } else {
            exist = false // 如果文件大小为 0 则认为缓存文件不存在
          }
        }

        // 如果缓存文件不存在，则下载并缓存
        if (!exist) {
          log.i(`下载并缓存 ${url}`)
          Helper.request(url, async (err, result) => {
            let httpResponse = {} as HttpResponse
            if (err) {
              httpResponse.result = ''
              httpResponse.statusCode = 404

              log.w(`下载并缓存失败 ${filePath}, errCode:${err.code}, errMessage:${err.message}`)
              resolve(httpResponse)
            } else {
              httpResponse.headers = {}
              httpResponse.headers["Content-Type"] = httpRequest.headers["Content-Type"] ?? 'image/png'
              httpResponse.result = result

              let outputStream = await fs.createStream(filePath, "w+");
              let writeLength = await outputStream.write(result, {
                offset: 0,
                length: result.byteLength,
                encoding: "utf-8",
              })
              await outputStream.close();

              log.i(`下载并缓存成功 ${filePath}`)
              resolve(httpResponse)
            }
          })
        }
      });
    })
  }

  /**
   * 异步缓存图片
   * @param config 图片的 url
   * @returns 如果缓存成功或缓存命中成功则返 file:// 开头的缓存地址，否则返回原 url
   */
  public async aci(url: string): Promise<string> {

    let ok = await this.addDownloading(url)
    if (!ok) {
      log.i(`缓存任务已存在 ${url}`)
      return url
    }

    // 如果目录不存在则创建
    fs.mkdir(this.config.cacheDirectory, true)

    let urlMd5 = CryptoHelper.md5(url)
    let filePath = PathHelper.join(this.config.cacheDirectory, urlMd5)

    // 如果缓存文件存在，则从缓存文件中读取数据
    let exist = await fs.access(filePath, fs.AccessModeType.EXIST)
    if (exist) {
      let fileInfo = await fs.stat(filePath)
      if (fileInfo.size > 0) {
        fs.utimes(filePath, new Date().getTime())
        await this.removeDownloading(url)
        log.i(`缓存命中 ${filePath}`)
        return "file://" + filePath
      }
    }

    // 如果缓存文件不存在，则下载并缓存
    return new Promise((resolve, reject) => {
      log.i(`下载并缓存 ${url}`)
      Helper.download(url, filePath, async (error) => {
        await this.removeDownloading(url)
        if (error) {
          log.w(`下载并缓存失败 ${filePath}, errCode:${error.code}, errMessage:${error.message}`)
          resolve(url);
        } else {
          log.i(`下载并缓存成功 ${filePath}`)
          resolve("file://" + filePath);
        }
      })
    });
  }

  public pci(url: string): string {
    if (this.port == -1) {
      log.w(`本地 http server 未启动，无法通过代理的方式缓存图片`)
      return url
    }

    return `http://127.0.0.1:${this.port}/?url=${UrlHelper.encode(url)}`
  }

  // <editor-fold desc='管理当前正在下载的任务'>
  lock: ArkTSUtils.locks.AsyncLock = new ArkTSUtils.locks.AsyncLock();
  downloadingTasks: Set<string> = new Set<string>()
  async addDownloading(url: string): Promise<boolean> { // 返回值为 false 则添加失败，因为任务已存在
    return this.lock.lockAsync(() => {
      if (this.downloadingTasks.has(url)) {
        return false
      } else {
        this.downloadingTasks.add(url)
        return true
      }
    })
  }
  async removeDownloading(url: string) {
    await this.lock.lockAsync(() => {
      this.downloadingTasks.delete(url)
    })

  }
  // </editor-fold>
}

export let cachedImage = CachedImage.getInstance()