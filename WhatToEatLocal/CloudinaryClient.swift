//
//  CloudinaryClient.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 5.09.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import Foundation
import Cloudinary
import ImageRow

class CloudinaryClient {
    
    static func setImageViewImageAsync(imageView: UIImageView, imageUrl: String) {
        CloudinaryClient.cloudinary.createDownloader().fetchImage(
            imageUrl, // image url
            nil, // progress handler
            completionHandler: { // completion handler
                (responseImage, error) in
                if let error = error {
                    print("Error downloading image %@", error)
                }
                else {
                    print("Image downloaded from Cloudinary successfully " + imageUrl)
                    do{
                        DispatchQueue.main.async {
                            imageView.image = responseImage
                        }
                    }
                }
        })
    }
    
    static func setImageRowImageAsync(imageRow: ImageRow?, imageUrl: String) {
        CloudinaryClient.cloudinary.createDownloader().fetchImage(
            imageUrl, // image url
            nil, // progress handler
            completionHandler: { // completion handler
                (responseImage, error) in
                if let error = error {
                    print("Error downloading image %@", error)
                }
                else {
                    print("Image downloaded from Cloudinary successfully " + imageUrl)
                    do{
                        DispatchQueue.main.async {
                            imageRow!.value = responseImage
                            imageRow!.reload()
                        }
                    }
                }
        })
    }
    
    public static let cloudinary:CLDCloudinary = CLDCloudinary(configuration: config)
    
    private static let config = CLDConfiguration(cloudName: "dv0qmj6vt", apiKey: "752346693282248")
    
}
