//
//  CacheDataManager.h
//
//  Created by Kireto.
//  Copyright (c) Kireto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheDataManager : NSObject

+ (id)sharedManager;

#pragma mark - image cacheDirectoryPath
- (NSString*)cacheDirectoryPath;
- (NSString*)cacheDirectoryPathForAssetId:(NSUInteger)assetId;
- (NSString*)imageCachePathWithURL:(NSString*)imageURL assetId:(NSUInteger)assetId;

#pragma mark - set image
- (void)setImageForImageView:(UIImageView*)imageView
                     assetId:(NSUInteger)assetId
                     withURL:(NSString*)imageURL
            placeholderImage:(NSString*)placeholderImage;
- (void)setImageForButton:(UIButton*)button
                  assetId:(NSUInteger)assetId
                  withURL:(NSString*)imageURL
         placeholderImage:(NSString*)placeholderImage;
- (void)setButtonBackgroundImageForButton:(UIButton*)button
                                  assetId:(NSUInteger)assetId
                                  withURL:(NSString*)imageURL
                         placeholderImage:(NSString*)placeholderImage;

#pragma mark - set image in background
- (void)setImageInBackgroundForImageView:(UIImageView*)imageView
                                 assetId:(NSUInteger)assetId
                                 withURL:(NSString*)imageURL
                        placeholderImage:(NSString*)placeholderImage;
- (void)setImageInBackgroundForButton:(UIButton*)button
                              assetId:(NSUInteger)assetId
                              withURL:(NSString*)imageURL
                     placeholderImage:(NSString*)placeholderImage;
- (void)setButtonBackgroundImageInBackgroundForButton:(UIButton*)button
                                              assetId:(NSUInteger)assetId
                                              withURL:(NSString*)imageURL
                                     placeholderImage:(NSString*)placeholderImage;

#pragma mark - remove cache data
- (void)removeImageWithURL:(NSString*)imageURL assetId:(NSUInteger)assetId;
- (void)removeCachedDataForAssetId:(NSUInteger)assetId;
- (void)removeAllCachedData;

@end
