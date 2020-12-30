//
//  ImageCache.swift
//  feuerlib
//
//  Created by Jannik Feuerhahn on 01.12.20.
//

import UIKit

/**
 ImageCache that lets you download an UIImage by url string and cache it in NSCache
 */
public class ImageCache {
    
    /**
     Singleton
     */
    public static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    public func getImage(from urlString:String, completionHandler: @escaping (CachableResult<String, UIImage, Error>) -> Void) {
        let cacheKey = urlString
        
        if let image = cache.object(forKey: NSString(string: cacheKey)) {
            completionHandler(CachableResult(.success(image), cacheKey))
            return
        }

        
        guard let url = URL(string: urlString) else {
            completionHandler(CachableResult(.failure(ServiceError.badUrl), cacheKey))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self,
                  let response = response as? HTTPURLResponse, response.statusCode == 200,
                  let data = data,
                  let image = UIImage(data: data) else {
                completionHandler(CachableResult(.failure(ServiceError.noData), cacheKey))
                return
            }
            
            self.cache.setObject(image, forKey: NSString(string: cacheKey))
            completionHandler(CachableResult(.success(image), cacheKey))
        }.resume()
    }
}
