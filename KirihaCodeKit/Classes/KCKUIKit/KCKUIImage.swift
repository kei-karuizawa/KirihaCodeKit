//
//  KCKUIImage.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2022/3/22.
//

import Foundation
import UIKit
import Photos

public extension UIImage {
    
    static func kiriha_image(name: String, in bundle: Bundle) -> UIImage? {
        let image: UIImage? = UIImage(named: name, in: bundle, compatibleWith: nil)
        image?.withRenderingMode(.alwaysOriginal)
        return image
    }
    
    static func kiriha_image(name: String, in bundle: Bundle, compatibleWith: UITraitCollection? = nil, with renderingMode: UIImage.RenderingMode = .alwaysOriginal) -> UIImage? {
        let image: UIImage? = UIImage(named: name, in: bundle, compatibleWith: compatibleWith)
        image?.withRenderingMode(renderingMode)
        return image
    }
}

extension UIImage {
    
    static func kiriha_imageInKirihaBundle(name: String) -> UIImage? {
        let image: UIImage? = UIImage.kiriha_image(name: name, in: Bundle.kirihaBundle())
        return image
    }
}

extension UIImage {
    
    public func kiriha_writeToSavedPhotosAlbum(completionHandler: ((_ success: Bool, _ error: Error?) -> Void)?) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: self)
        } completionHandler: { success, error in
            if success {
                completionHandler?(true, nil)
            } else {
                completionHandler?(false, error)
            }
        }
    }
}

extension UIImage {
    
    /// 将图片转为 base64 编码字符串。`suffix` 为图片后缀名，可以为：`png`、`jpg`、`jpeg`。
    public func kiriha_base64EncodedString(suffix: String) -> String? {
        if suffix == "png" {
            let imageData: Data? = self.pngData()
            if imageData != nil {
                return imageData!.base64EncodedString()
            } else {
                return nil
            }
        } else if suffix == "jpg" || suffix == "jpeg" {
            let imageData: Data? = self.jpegData(compressionQuality: 1.0)
            if imageData != nil {
                return imageData!.base64EncodedString()
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

extension UIImage {
    
    public func kiriha_convertSampleBufferToUIImage(sampleBuffer: CMSampleBuffer) -> UIImage? {
        let imageBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
        if imageBuffer != nil {
            let ciImage: CIImage = CIImage(cvPixelBuffer: imageBuffer!)
            if let resultImage = self.kiriha_convertCIImageToUIImage(ciImage: ciImage) {
                return resultImage
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    public func kiriha_convertCIImageToUIImage(ciImage: CIImage) -> UIImage? {
        let context: CIContext = CIContext(options: nil)
        let cgImage: CGImage? = context.createCGImage(ciImage, from: ciImage.extent)
        if cgImage != nil {
            let image: UIImage = UIImage(cgImage: cgImage!)
            return image
        } else {
            return nil
        }
    }
}
