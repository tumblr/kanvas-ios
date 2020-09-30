//
//  ExperimentalStickerProvider.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 24/11/2019.
//

import Foundation
import UIKit
import KanvasCamera

/// Constants for ExperimentalStickerProvider
private struct Constants {
    static let resourceName: String = "stickers"
    static let resourceExtension: String = "json"
    static let twoDigitsFormat: String = "%02d"
    static let imageExtension: String = "png"
}

extension URLSessionTask: KanvasCancelable {

}

class ImageLoader: KanvasStickerLoader {

    lazy var session: URLSession = {
        var configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(memoryCapacity: 500*1024*1024, diskCapacity: 1000*1024*1024, diskPath: nil)
        return URLSession(configuration: configuration)
    }()

    func loadSticker(at imageURL: URL, imageView: UIImageView?, completion: @escaping (UIImage?, Error?) -> Void) -> KanvasCancelable {
        let request = URLRequest(url: imageURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        let task = session.dataTask(with: request) { [weak imageView, weak session] (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView?.image = image
                }
                if let response = response {
                    let cachedResponse = CachedURLResponse(response: response, data: data)
                    session?.configuration.urlCache?.storeCachedResponse(cachedResponse, for: request)
                }
                completion(image, nil)
            }
            else {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
}

/// Class that obtains the stickers from the stickers file in the example app
public final class ExperimentalStickerProvider: StickerProvider {
    
    public func loader() -> KanvasStickerLoader? {
        return ImageLoader()
    }

    private weak var delegate: StickerProviderDelegate?
    
    // MARK: - StickerProvider Protocol
    
    public init() {

    }
    
    public func setDelegate(delegate: StickerProviderDelegate) {
        self.delegate = delegate
    }
    
    /// Gets the collection of stickers types
    public func getStickerTypes() {
        let data = getData()
        
        guard let providers = data["providers"] as? NSArray,
            let kanvasProvider = providers.firstObject as? Dictionary<String, Any>,
            let baseUrl = kanvasProvider["base_url"] as? String,
            let stickerList = data["stickers"] as? NSArray else {
                delegate?.didLoadStickerTypes([])
                return
        }
        
        var stickerTypes: [StickerType] = []
        
        stickerList.forEach { element in
            if let stickerItem = element as? Dictionary<String, Any>,
                let keyword = stickerItem["keyword"] as? String,
                let thumbUrl = stickerItem["thumb_url"] as? String,
                let count = stickerItem["count"] as? Int {
                
                var stickers: [Sticker] = []
                for number in 1...count {
                    let id = "\(keyword)_\(number)"
                    let imageUrl =  "\(baseUrl)\(keyword)/\(String(format: Constants.twoDigitsFormat, number)).\(Constants.imageExtension)"
                    stickers.append(Sticker(id: id, imageUrl: imageUrl))
                }
                
                let imageUrl = "\(baseUrl)\(keyword)/\(thumbUrl)"
                let stickerType = StickerType(id: keyword, imageUrl: imageUrl, stickers: stickers)
                
                stickerTypes.append(stickerType)
            }
        }
        
        delegate?.didLoadStickerTypes(stickerTypes)
    }
    
    // MARK: - Private utilities
    
    /// Creates a dictionary from the stickers JSON file
    private func getData() -> Dictionary<String, AnyObject> {
        if let path = Bundle(for: ExperimentalStickerProvider.self).path(forResource: "\(Constants.resourceName)", ofType: Constants.resourceExtension) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    return jsonResult
                }
            }
            catch {
                print("Error loading \(Constants.resourceName).\(Constants.resourceExtension)")
            }
        }
        
        return Dictionary<String, AnyObject>()
    }
}
