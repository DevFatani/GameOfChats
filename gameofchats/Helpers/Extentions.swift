//
//  Extentions.swift
//  gameofchats
//
//  Created by Muhammad Fatani on 28/02/2019.
//  Copyright © 2019 Muhammad Fatani. All rights reserved.
//

import UIKit
let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageWithCashe(url: String) {
        
        if let cachImage = imageCache.object(forKey: NSString(string: url)){
            image = cachImage
            return
        }
        
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, err) in
            if err != nil {
                return
            }
            
            DispatchQueue.main.async {
                if  let downloadImage = UIImage(data: data!){
                    imageCache.setObject(downloadImage, forKey: NSString(string: url))
                    self.image = downloadImage
                }
                
            }
            }.resume()
    }
}
