//
//  CacheDataManager.m
//
//  Created by Kireto.
//  Copyright (c) Kireto. All rights reserved.
//

#import "CacheDataManager.h"

#import "UIImageView+AFNetworking.h"
#import "UIButton+AFNetworking.h"

@implementation CacheDataManager

+ (id)sharedManager {
    static CacheDataManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    self = [super init];
    if (self) {
        [self createCacheDirectoryPath];
    }
    return self;
}

#pragma mark - image createCacheDirectoryPaths
- (void)createCacheDirectoryPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    BOOL isDir = NO;
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
}

#pragma mark - image cacheDirectoryPath
- (NSString*)cacheDirectoryPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    return cachePath;
}

- (NSString*)cacheDirectoryPathForAssetId:(NSUInteger)assetId {
    
    NSString *retPath = [self cacheDirectoryPath];
    NSString *idString = [NSString stringWithFormat:@"%i", assetId];
    retPath = [retPath stringByAppendingPathComponent:idString];
    
    BOOL isDir = NO;
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:retPath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:retPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    return retPath;
}

- (NSString*)imageCachePathWithURL:(NSString*)imageURL assetId:(NSUInteger)assetId {
    
    NSString *retPath = [self cacheDirectoryPathForAssetId:assetId];
    NSString *imageName = [imageURL lastPathComponent];
    retPath = [retPath stringByAppendingPathComponent:imageName];
    return retPath;
}

#pragma mark - set image
- (void)setImageForImageView:(UIImageView*)imageView
                     assetId:(NSUInteger)assetId
                     withURL:(NSString*)imageURL
            placeholderImage:(NSString*)placeholderImage {
    
    NSString *imageCachePath = [self imageCachePathWithURL:imageURL assetId:assetId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageCachePath isDirectory:NO]) {
        [imageView setImage:[UIImage imageWithContentsOfFile:imageCachePath]];
    }
    else {
        if ([placeholderImage length]) {
            [imageView setImage:[UIImage imageNamed:placeholderImage]];
        }
        imageView.tag = assetId;
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [UIImageJPEGRepresentation(responseObject, 1.0) writeToFile:imageCachePath atomically:YES];
            if (imageView && imageView.tag == assetId) {
                [imageView setImage:responseObject];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error downloading button image: %@", error);
        }];
        [requestOperation start];
    }
}

- (void)setImageForButton:(UIButton*)button
                  assetId:(NSUInteger)assetId
                  withURL:(NSString*)imageURL
         placeholderImage:(NSString*)placeholderImage {
    
    NSString *imageCachePath = [self imageCachePathWithURL:imageURL assetId:assetId];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageCachePath isDirectory:NO]) {
        [button setImage:[UIImage imageWithContentsOfFile:imageCachePath] forState:UIControlStateNormal];
    }
    else {
        [button setImage:[UIImage imageNamed:placeholderImage] forState:UIControlStateNormal];
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [UIImageJPEGRepresentation(responseObject, 1.0) writeToFile:imageCachePath atomically:YES];
            [button setImage:responseObject forState:UIControlStateNormal];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error downloading button image: %@", error);
        }];
        [requestOperation start];
    }
}

- (void)setButtonBackgroundImageForButton:(UIButton*)button
                                  assetId:(NSUInteger)assetId
                                  withURL:(NSString*)imageURL
                         placeholderImage:(NSString*)placeholderImage {
    
    NSString *imageCachePath = [self imageCachePathWithURL:imageURL assetId:assetId];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageCachePath isDirectory:NO]) {
        [button setBackgroundImage:[UIImage imageWithContentsOfFile:imageCachePath] forState:UIControlStateNormal];
    }
    else {
        [button setImage:[UIImage imageNamed:placeholderImage] forState:UIControlStateNormal];
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [UIImageJPEGRepresentation(responseObject, 1.0) writeToFile:imageCachePath atomically:YES];
            [button setBackgroundImage:responseObject forState:UIControlStateNormal];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error downloading button image: %@", error);
        }];
        [requestOperation start];
    }
}

#pragma mark - set image in background
- (void)setImageInBackgroundForImageView:(UIImageView*)imageView
                                 assetId:(NSUInteger)assetId
                                 withURL:(NSString*)imageURL
                        placeholderImage:(NSString*)placeholderImage {
    
    NSString *imageCachePath = [self imageCachePathWithURL:imageURL assetId:assetId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageCachePath isDirectory:NO]) {
        [imageView setImage:[UIImage imageWithContentsOfFile:imageCachePath]];
    }
    else {
        if ([placeholderImage length]) {
            [imageView setImage:[UIImage imageNamed:placeholderImage]];
        }
        imageView.tag = assetId;
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary * args = [NSDictionary dictionaryWithObjectsAndKeys:
                                   imageView, @"image_view",
                                   imageCachePath, @"image_path",
                                   responseObject, @"image",
                                   [NSNumber numberWithInteger:assetId] ,@"asset_id",
                                   nil];
            [self performSelectorInBackground:@selector(setImageForImageView:) withObject:args];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error downloading button image: %@", error);
        }];
        [requestOperation start];
    }
}

- (void)setImageInBackgroundForButton:(UIButton*)button
                              assetId:(NSUInteger)assetId
                              withURL:(NSString*)imageURL
                     placeholderImage:(NSString*)placeholderImage {
    
    NSString *imageCachePath = [self imageCachePathWithURL:imageURL assetId:assetId];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageCachePath isDirectory:NO]) {
        [button setImage:[UIImage imageWithContentsOfFile:imageCachePath] forState:UIControlStateNormal];
    }
    else {
        [button setImage:[UIImage imageNamed:placeholderImage] forState:UIControlStateNormal];
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary * args = [NSDictionary dictionaryWithObjectsAndKeys:
                                   button, @"button",
                                   imageCachePath, @"image_path",
                                   responseObject, @"image",
                                   [NSNumber numberWithInteger:assetId] ,@"asset_id",
                                   nil];
            [self performSelectorInBackground:@selector(setImageForButton:) withObject:args];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error downloading button image: %@", error);
        }];
        [requestOperation start];
    }
}

- (void)setButtonBackgroundImageInBackgroundForButton:(UIButton*)button
                                              assetId:(NSUInteger)assetId
                                              withURL:(NSString*)imageURL
                                     placeholderImage:(NSString*)placeholderImage {
    
    NSString *imageCachePath = [self imageCachePathWithURL:imageURL assetId:assetId];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageCachePath isDirectory:NO]) {
        [button setImage:[UIImage imageWithContentsOfFile:imageCachePath] forState:UIControlStateNormal];
    }
    else {
        [button setImage:[UIImage imageNamed:placeholderImage] forState:UIControlStateNormal];
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary * args = [NSDictionary dictionaryWithObjectsAndKeys:
                                   button, @"button",
                                   imageCachePath, @"image_path",
                                   responseObject, @"image",
                                   [NSNumber numberWithInteger:assetId] ,@"asset_id",
                                   nil];
            [self performSelectorInBackground:@selector(setButtonBackgroundImage:) withObject:args];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error downloading button image: %@", error);
        }];
        [requestOperation start];
    }
}

#pragma mark - background methods
- (void)setImageForImageView:(NSDictionary *)args {
    
    UIImageView *imageView = [args valueForKey:@"image_view"];
    NSString *imagePath = [args valueForKey:@"image_path"];
    UIImage *image = [args valueForKey:@"image"];
    NSNumber *assetIdNumber = [args valueForKey:@"asset_id"];
    NSUInteger assetId = [assetIdNumber integerValue];
    
    if (imageView && imagePath && image && imageView.tag == assetId) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath atomically:YES];
        if (imageView.tag == assetId) {
            [imageView setImage:image];
        }
    }
}

- (void)setImageForButton:(NSDictionary *)args {
    
    UIButton *button = [args valueForKey:@"button"];
    NSString *imagePath = [args valueForKey:@"image_path"];
    UIImage *image = [args valueForKey:@"image"];
    NSNumber *assetIdNumber = [args valueForKey:@"asset_id"];
    NSUInteger assetId = [assetIdNumber integerValue];
    
    if (button && imagePath && image && button.tag == assetId) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath atomically:YES];
        [button setImage:image forState:UIControlStateNormal];
    }
}

- (void)setButtonBackgroundImage:(NSDictionary *)args {
    
    UIButton *button = [args valueForKey:@"button"];
    NSString *imagePath = [args valueForKey:@"image_path"];
    UIImage *image = [args valueForKey:@"image"];
    NSNumber *assetIdNumber = [args valueForKey:@"asset_id"];
    NSUInteger assetId = [assetIdNumber integerValue];
    
    if (button && imagePath && image && button.tag == assetId) {
        
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath atomically:YES];
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }
}

#pragma mark - remove cache data
- (void)removeImageWithURL:(NSString*)imageURL assetId:(NSUInteger)assetId {
    
    NSString *imageCachePath = [self imageCachePathWithURL:imageURL assetId:assetId];
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageCachePath isDirectory:NO]) {
        [[NSFileManager defaultManager] removeItemAtPath:imageCachePath error:&error];
    }
}

- (void)removeCachedDataForAssetId:(NSUInteger)assetId {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *assetImagesDir = [self cacheDirectoryPathForAssetId:assetId];
    NSString *assetFullSizeImagesDir = [self cacheDirectoryPathForAssetId:assetId];
    NSError *error;
    NSArray *files = [manager contentsOfDirectoryAtPath:assetImagesDir error:&error];
    NSArray *fullSizeFiles = [manager contentsOfDirectoryAtPath:assetFullSizeImagesDir error:&error];
    
    if(error) {
        //deal with error and bail.
    }
    error = nil;
    for (NSString *file in files) {
        [manager removeItemAtPath:[assetImagesDir stringByAppendingPathComponent:file] error:&error];
        if (error) {
            //an error occurred...
        }
    }
    error = nil;
    for (NSString *file in fullSizeFiles) {
        [manager removeItemAtPath:[assetFullSizeImagesDir stringByAppendingPathComponent:file] error:&error];
        if (error) {
            //an error occurred...
        }
    }
}

- (void)removeAllCachedData {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dirToEmpty = [self cacheDirectoryPath];
    NSError *error;
    NSArray *files = [manager contentsOfDirectoryAtPath:dirToEmpty error:&error];
    
    if(error) {
        //deal with error and bail.
    }
    
    for(NSString *file in files) {
        [manager removeItemAtPath:[dirToEmpty stringByAppendingPathComponent:file] error:&error];
        if (error) {
            //an error occurred...
        }
    }
}

@end
