import UIKit

class ImageHelper {
    static let expectedAvatarWidthAndHeight: CGFloat = 240
    static let expectedAvatarMaxSizeInKiBs: Int = 128

    static func resizeSquareImageForAvatarUsage(image: UIImage) -> UIImage {
        // expected avatar image : 120 x 120 in JPEG with less than 64 KiB
        let size = image.size
        var contextImage = image
        if size.height != size.width {
            // crop image to square.
            contextImage = ImageHelper.cropImageToSquare(image: contextImage)
        }

        // now resize it to 240 * 240 (pixels)
        contextImage = ImageHelper.scaleImageTo(image: contextImage, width: expectedAvatarWidthAndHeight, height: expectedAvatarWidthAndHeight)
        return contextImage
    }

    static func getAvatarRawData(image: UIImage) -> Data {
        if let data = ImageHelper.compressImageToJpeg(image: image, maxSize: expectedAvatarMaxSizeInKiBs) {
            return data
        } else {
            fatalError("Unexpected image - unable to compress to expected avatar file size.")
        }
    }

    static func compressImageToJpeg(image: UIImage, maxSize: Int) -> Data? {
        let maxCompression: CGFloat = 0.2
        let maxFileSize: Int = maxSize*1024
        var compression:CGFloat = 1.0
        while compression > maxCompression {
            var imageData = UIImageJPEGRepresentation(image, compression)!
            print("Get image data size : \(imageData.count)")
            if imageData.count > maxFileSize {
                compression -= 0.1
            } else {
                return imageData
            }
        }

        return nil
    }

    static func scaleImageTo(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        let imageSize = image.size
        if imageSize.width / imageSize.height != width / height {
            fatalError("warning: image ratio mismatch")
        }

        let newSize = CGSize(width: width / image.scale, height: height / image.scale)
        UIGraphicsBeginImageContextWithOptions(newSize, true, image.scale)
        image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    static func cropImageToSquare(image: UIImage) -> UIImage {
        let imageSize = image.size
        var cgPxWidth: CGFloat = imageSize.width * image.scale
        var cgPxHeight: CGFloat = imageSize.height * image.scale

        // See what size is longer and create the center off of that
        if cgPxWidth > cgPxHeight {
            cgPxWidth = cgPxHeight
        } else {
            cgPxHeight = cgPxWidth
        }

        let rect = CGRect(x: 0, y: 0, width: cgPxWidth, height: cgPxHeight)
        let imgRef = image.cgImage!.cropping(to: rect)!
        return UIImage(cgImage: imgRef, scale: image.scale, orientation: image.imageOrientation)
    }
}
