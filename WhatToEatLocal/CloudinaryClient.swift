//
//  CloudinaryClient.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 5.09.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import Foundation
import Cloudinary

class CloudinaryClient {
    
    static func setImageAsync(imageView: UIImageView, imageURL: String) {
        do {
            CloudinaryClient.cloudinary.createDownloader().fetchImage(
                imageURL, // image url
                nil, // progress handler
                completionHandler: { // completion handler
                    (responseImage, error) in
                    if let error = error {
                        print("Error downloading image %@", error)
                    }
                    else {
                        print("Image downloaded from Cloudinary successfully " + imageURL)
                        do{
                            DispatchQueue.main.async {
                                imageView.image = responseImage
                            }
                        }
                    }
            })
        }
    }
    
    public static let cloudinary:CLDCloudinary = CLDCloudinary(configuration: config)
    
    private static let config = CLDConfiguration(cloudName: "dv0qmj6vt", apiKey: "752346693282248")
    
}
