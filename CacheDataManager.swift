//The MIT License (MIT)
//
//Copyright (c) 2014 Kireto
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import Foundation

class CacheDataManager: NSObject {
    
    class var sharedInstance : CacheDataManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : CacheDataManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = CacheDataManager()
        }
        return Static.instance!
    }
    override init () {
        super.init()
        self.createCacheDirectoryPath()
    }
    // MARK: - image createCacheDirectoryPaths
    private func createCacheDirectoryPath() {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let cachePath = paths.first as String
        var isDir : ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(cachePath, isDirectory:&isDir) {
            if !isDir {
                NSFileManager.defaultManager().removeItemAtPath(cachePath, error: nil)
                NSFileManager.defaultManager().createDirectoryAtPath(cachePath, withIntermediateDirectories: false, attributes: nil, error: nil)
            }
        }
        else {
            NSFileManager.defaultManager().createDirectoryAtPath(cachePath, withIntermediateDirectories: false, attributes: nil, error: nil)
        }
    }
    // MARK: - image cacheDirectoryPath
    func cacheDirectoryPath() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let cachePath = paths.first as NSString
        return cachePath
    }
    func cacheDirectoryPath(assetId: Int) -> NSString {
        var retPath = self.cacheDirectoryPath()
        retPath = retPath.stringByAppendingString("\(assetId)")
        var isDir : ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(retPath, isDirectory:&isDir) {
            if !isDir {
                NSFileManager.defaultManager().removeItemAtPath(retPath, error: nil)
                NSFileManager.defaultManager().createDirectoryAtPath(retPath, withIntermediateDirectories: false, attributes: nil, error: nil)
            }
        }
        else {
            NSFileManager.defaultManager().createDirectoryAtPath(retPath, withIntermediateDirectories: false, attributes: nil, error: nil)
        }
        return retPath
    }
    func imageCachePath(imageURL: NSString, assetId: Int) -> NSString {
        var retPath = self.cacheDirectoryPath(assetId)
        let imageName = imageURL.lastPathComponent
        retPath = retPath.stringByAppendingString(imageName)
        return retPath
    }
    // MARK: - set image
    func setImage(imageView: UIImageView, assetId: Int, imageURL: NSString, placeholderImage: NSString) {
        if imageURL.lastPathComponent.isEmpty {
            //prevent getting folder instead of image path error
            return
        }
        let imageCachePath = self.imageCachePath(imageURL, assetId: assetId)
        if NSFileManager.defaultManager().fileExistsAtPath(imageCachePath) {
            imageView.image = UIImage(contentsOfFile: imageCachePath)
        }
        else {
            if placeholderImage.length > 0 {
                imageView.image = UIImage(named: placeholderImage)
            }
            imageView.tag = assetId
            var request = NSMutableURLRequest(URL: NSURL(string: imageURL)!)
            request.HTTPShouldHandleCookies = false
            var requestOperation = AFHTTPRequestOperation(request: request)
            requestOperation.responseSerializer = AFImageResponseSerializer() as AFHTTPResponseSerializer
            requestOperation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
                if let image = responseObject as? UIImage {
                    UIImagePNGRepresentation(image).writeToFile(imageCachePath, atomically: true)
                    if let imgView = imageView as UIImageView? {
                        if imageView.tag == assetId {
                            imageView.image = image
                        }
                    }
                }
            }, failure: { (operation, error) -> Void in
                println("error downloading button image: " + "\(error)")
            })
            requestOperation.start()
        }
    }
    func setImage(button: UIButton, assetId: Int, imageURL: NSString, placeholderImage: NSString) {
        if imageURL.lastPathComponent.isEmpty {
            //prevent getting folder instead of image path error
            return
        }
        let imageCachePath = self.imageCachePath(imageURL, assetId: assetId)
        if NSFileManager.defaultManager().fileExistsAtPath(imageCachePath) {
            button.setImage(UIImage(contentsOfFile: imageCachePath), forState: UIControlState.Normal)
        }
        else {
            if placeholderImage.length > 0 {
                button.setImage(UIImage(named: placeholderImage), forState: UIControlState.Normal)
            }
            button.tag = assetId
            var request = NSMutableURLRequest(URL: NSURL(string: imageURL)!)
            request.HTTPShouldHandleCookies = false
            var requestOperation = AFHTTPRequestOperation(request: request)
            requestOperation.responseSerializer = AFImageResponseSerializer() as AFHTTPResponseSerializer
            requestOperation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
                if let image = responseObject as? UIImage {
                    UIImagePNGRepresentation(image).writeToFile(imageCachePath, atomically: true)
                    if let btn = button as UIButton? {
                        if button.tag == assetId {
                            button.setImage(image, forState: UIControlState.Normal)
                        }
                    }
                }
                }, failure: { (operation, error) -> Void in
                    println("error downloading button image: " + "\(error)")
            })
            requestOperation.start()
        }
    }
    func setBackgroundImage(button: UIButton, assetId: Int, imageURL: NSString, placeholderImage: NSString) {
        if imageURL.lastPathComponent.isEmpty {
            //prevent getting folder instead of image path error
            return
        }
        let imageCachePath = self.imageCachePath(imageURL, assetId: assetId)
        if NSFileManager.defaultManager().fileExistsAtPath(imageCachePath) {
            button.setBackgroundImage(UIImage(contentsOfFile: imageCachePath), forState: UIControlState.Normal)
        }
        else {
            if placeholderImage.length > 0 {
                button.setBackgroundImage(UIImage(named: placeholderImage), forState: UIControlState.Normal)
            }
            button.tag = assetId
            var request = NSMutableURLRequest(URL: NSURL(string: imageURL)!)
            request.HTTPShouldHandleCookies = false
            var requestOperation = AFHTTPRequestOperation(request: request)
            requestOperation.responseSerializer = AFImageResponseSerializer() as AFHTTPResponseSerializer
            requestOperation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
                if let image = responseObject as? UIImage {
                    UIImagePNGRepresentation(image).writeToFile(imageCachePath, atomically: true)
                    if let btn = button as UIButton? {
                        if button.tag == assetId {
                            button.setBackgroundImage(image, forState: UIControlState.Normal)
                        }
                    }
                }
                }, failure: { (operation, error) -> Void in
                    println("error downloading button image: " + "\(error)")
            })
            requestOperation.start()
        }
    }
    // MARK: - set image in background
    func setImageInBackground(imageView: UIImageView, assetId: Int, imageURL: NSString, placeholderImage: NSString) {
        if imageURL.lastPathComponent.isEmpty {
            //prevent getting folder instead of image path error
            return
        }
        let imageCachePath = self.imageCachePath(imageURL, assetId: assetId)
        if NSFileManager.defaultManager().fileExistsAtPath(imageCachePath) {
            imageView.image = UIImage(contentsOfFile: imageCachePath)
        }
        else {
            if placeholderImage.length > 0 {
                imageView.image = UIImage(named: placeholderImage)
            }
            imageView.tag = assetId
            var request = NSMutableURLRequest(URL: NSURL(string: imageURL)!)
            request.HTTPShouldHandleCookies = false
            var requestOperation = AFHTTPRequestOperation(request: request)
            requestOperation.responseSerializer = AFImageResponseSerializer() as AFHTTPResponseSerializer
            requestOperation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
                if let image = responseObject as? UIImage {
                    var args = ["image_view":imageView,
                        "image_path":imageCachePath,
                        "image":image,
                        "asset_id": assetId] as NSDictionary
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                        self.setImageViewImage(args)
                        })
                }
                }, failure: { (operation, error) -> Void in
                    println("error downloading button image: " + "\(error)")
            })
            requestOperation.start()
        }
    }
    func setImageInBackground(button: UIButton, assetId: Int, imageURL: NSString, placeholderImage: NSString) {
        if imageURL.lastPathComponent.isEmpty {
            //prevent getting folder instead of image path error
            return
        }
        let imageCachePath = self.imageCachePath(imageURL, assetId: assetId)
        if NSFileManager.defaultManager().fileExistsAtPath(imageCachePath) {
            button.setImage(UIImage(contentsOfFile: imageCachePath), forState: UIControlState.Normal)
        }
        else {
            if placeholderImage.length > 0 {
                button.setImage(UIImage(named: placeholderImage), forState: UIControlState.Normal)
            }
            button.tag = assetId
            var request = NSMutableURLRequest(URL: NSURL(string: imageURL)!)
            request.HTTPShouldHandleCookies = false
            var requestOperation = AFHTTPRequestOperation(request: request)
            requestOperation.responseSerializer = AFImageResponseSerializer() as AFHTTPResponseSerializer
            requestOperation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
                if let image = responseObject as? UIImage {
                    var args = ["button":button,
                        "image_path":imageCachePath,
                        "image":image,
                        "asset_id": assetId] as NSDictionary
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                        self.setButtonImage(args)
                    })
                }
                }, failure: { (operation, error) -> Void in
                    println("error downloading button image: " + "\(error)")
            })
            requestOperation.start()
        }
    }
    func setBackgroundImageInBackground(button: UIButton, assetId: Int, imageURL: NSString, placeholderImage: NSString) {
        if imageURL.lastPathComponent.isEmpty {
            //prevent getting folder instead of image path error
            return
        }
        let imageCachePath = self.imageCachePath(imageURL, assetId: assetId)
        if NSFileManager.defaultManager().fileExistsAtPath(imageCachePath) {
            button.setBackgroundImage(UIImage(contentsOfFile: imageCachePath), forState: UIControlState.Normal)
        }
        else {
            if placeholderImage.length > 0 {
                button.setBackgroundImage(UIImage(named: placeholderImage), forState: UIControlState.Normal)
            }
            button.tag = assetId
            var request = NSMutableURLRequest(URL: NSURL(string: imageURL)!)
            request.HTTPShouldHandleCookies = false
            var requestOperation = AFHTTPRequestOperation(request: request)
            requestOperation.responseSerializer = AFImageResponseSerializer() as AFHTTPResponseSerializer
            requestOperation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
                if let image = responseObject as? UIImage {
                    var args = ["button":button,
                        "image_path":imageCachePath,
                        "image":image,
                        "asset_id": assetId] as NSDictionary
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                        self.setButtonBackgroundImage(args)
                    })
                }
                }, failure: { (operation, error) -> Void in
                    println("error downloading button image: " + "\(error)")
            })
            requestOperation.start()
        }
    }
    // MARK: - background methods
    private func setImageViewImage(args:NSDictionary) {
        var imageView = args.valueForKey("image_view") as? UIImageView
        var imageCachePath = args.valueForKey("image_path") as? NSString
        var image = args.valueForKey("image_view") as? UIImage
        var assetId = args.valueForKey("asset_id") as? Int
        if imageView != nil && imageCachePath != nil && image != nil && assetId != nil {
            if imageView!.tag == assetId! {
                UIImagePNGRepresentation(image!).writeToFile(imageCachePath!, atomically: true)
                if imageView != nil {
                    if imageView!.tag == assetId! {
                        //update GUI on main thread
                        dispatch_async(dispatch_get_main_queue(), {
                            imageView!.image = image!
                        })
                    }
                }
            }
        }
    }
    private func setButtonImage(args:NSDictionary) {
        var button = args.valueForKey("button") as? UIButton
        var imageCachePath = args.valueForKey("image_path") as? NSString
        var image = args.valueForKey("image_view") as? UIImage
        var assetId = args.valueForKey("asset_id") as? Int
        if button != nil && imageCachePath != nil && image != nil && assetId != nil {
            if button!.tag == assetId! {
                UIImagePNGRepresentation(image!).writeToFile(imageCachePath!, atomically: true)
                if button != nil {
                    if button!.tag == assetId! {
                        //update GUI on main thread
                        dispatch_async(dispatch_get_main_queue(), {
                            button!.setImage(image!, forState: UIControlState.Normal)
                        })
                    }
                }
            }
        }
    }
    private func setButtonBackgroundImage(args:NSDictionary) {
        var button = args.valueForKey("button") as? UIButton
        var imageCachePath = args.valueForKey("image_path") as? NSString
        var image = args.valueForKey("image_view") as? UIImage
        var assetId = args.valueForKey("asset_id") as? Int
        if button != nil && imageCachePath != nil && image != nil && assetId != nil {
            if button!.tag == assetId! {
                UIImagePNGRepresentation(image!).writeToFile(imageCachePath!, atomically: true)
                if button != nil {
                    if button!.tag == assetId! {
                        //update GUI on main thread
                        dispatch_async(dispatch_get_main_queue(), {
                            button!.setBackgroundImage(image!, forState: UIControlState.Normal)
                        })
                    }
                }
            }
        }
    }
    // MARK: - remove cache data
    func removeCachedData(imageURL: NSString, assetId: Int) {
        if imageURL.lastPathComponent.isEmpty {
            //prevent getting folder instead of image path error
            return
        }
        let path = self.imageCachePath(imageURL, assetId: assetId)
        var isDir : ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory:&isDir) {
            if !isDir {
                NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
            }
        }
    }
    func removeCachedData(assetId: Int) {
        let imagesDir = self.cacheDirectoryPath(assetId)
        self.emptyDirectory(imagesDir)
    }
    func removeAllCachedData() {
        let dirToEmpty = self.cacheDirectoryPath()
        self.emptyDirectory(dirToEmpty)
    }
    private func emptyDirectory(path: NSString) {
        if let files = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error: nil) as NSArray? {
            for file in files {
                let fileName = file as String
                let filePath = path.stringByAppendingPathComponent(fileName)
                var isDir : ObjCBool = false
                if NSFileManager.defaultManager().fileExistsAtPath(filePath, isDirectory:&isDir) {
                    if isDir {
                        self.emptyDirectory(filePath)
                    }
                    else {
                        NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
                    }
                }
            }
        }
    }
}
