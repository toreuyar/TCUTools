//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Töre Çağrı Uyar
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  TCUDataManager.m
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 01/01/15.
//  E-mail: mail@toreuyar.net
//  Copyright (c) 2015 Töre Çağrı Uyar. All rights reserved.
//

#import "TCUDataManager.h"
#import "UIImage+ResizeAndCrop.h"
#import "TCUTools.h"

@interface TCUDataManager()

@property(nonatomic, strong) NSMutableDictionary *cachedImagesOnPath;
@property(nonatomic, strong) NSMutableDictionary *cachedImagesOnName;
@property(nonatomic, strong) NSMutableDictionary *cachedImagesOnNameForSize;
@property(nonatomic, strong) NSMutableDictionary *cachedResizableImagesOnName;

- (NSString *)createUUID;

@end

@implementation TCUDataManager

+ (TCUDataManager *)defaultManager {
    __strong static TCUDataManager *_defaultTCUDataManager = nil;
    static dispatch_once_t applicationTCUDataManagerOnceToken;
    dispatch_once(&applicationTCUDataManagerOnceToken, ^{
        _defaultTCUDataManager = [[self alloc] init];
    });
    return _defaultTCUDataManager;
}

- (NSMutableDictionary *)cachedImagesOnPath {
    if (!_cachedImagesOnPath) {
        [self willChangeValueForKey:@"cachedImagesOnPath"];
        _cachedImagesOnPath = [NSMutableDictionary dictionary];
        [self willChangeValueForKey:@"cachedImagesOnPath"];
    }
    return _cachedImagesOnPath;
}

- (NSMutableDictionary *)cachedImagesOnName {
    if (!_cachedImagesOnName) {
        [self willChangeValueForKey:@"cachedImagesOnName"];
        _cachedImagesOnName = [NSMutableDictionary dictionary];
        [self willChangeValueForKey:@"cachedImagesOnName"];
    }
    return _cachedImagesOnName;
}

- (NSMutableDictionary *)cachedImagesOnNameForSize {
    if (!_cachedImagesOnNameForSize) {
        [self willChangeValueForKey:@"cachedImagesOnNameForSize"];
        _cachedImagesOnNameForSize = [NSMutableDictionary dictionary];
        [self willChangeValueForKey:@"cachedImagesOnNameForSize"];
    }
    return _cachedImagesOnNameForSize;
}

- (NSMutableDictionary *)cachedResizableImagesOnName {
    if (!_cachedResizableImagesOnName) {
        [self willChangeValueForKey:@"cachedResizableImagesOnName"];
        _cachedResizableImagesOnName = [NSMutableDictionary dictionary];
        [self willChangeValueForKey:@"cachedResizableImagesOnName"];
    }
    return _cachedResizableImagesOnName;
}

- (id)init {
    self = [super init];
    if (self) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSNumber numberWithUnsignedInteger:1] forKey:@"DataManagerVersion"];
        [userDefaults synchronize];
        self.cachedImagesOnPath = [NSMutableDictionary dictionary];
        self.cachedImagesOnName = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    //    if ([fileManager fileExistsAtPath:[self cacheDirectoryPath]]) {
    //        [fileManager removeItemAtPath:[self cacheDirectoryPath] error:NULL];
    //    }
}

- (void)didReceiveMemoryWarning {
    @synchronized(self.cachedImagesOnPath) {
        self.cachedImagesOnPath = nil;
    }
    @synchronized(self.cachedImagesOnName) {
        self.cachedImagesOnName = nil;
    }
    @synchronized(self.cachedResizableImagesOnName) {
        self.cachedResizableImagesOnName = nil;
    }
}

- (NSString *)createUUID {
    NSString *_UUIDString = nil;
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    _UUIDString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return _UUIDString;
}

- (UIImage *)getCachedImageForPath:(NSString *)path {
    if (!path) {
        return nil;
    }
    if (![path isKindOfClass:[NSString class]]) {
        return nil;
    }
    UIImage *image = nil;
    @synchronized(self.cachedImagesOnPath) {
        image = [self.cachedImagesOnPath objectForKey:path];
        if (!image) {
            NSError *error = nil;
            image = [UIImage imageWithData:[NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&error]];
            if (error) {
                NSLogDebug(@"Image Reading Error: %@", error.localizedDescription);
            }
            if (image) {
                [self.cachedImagesOnPath setObject:image forKey:path];
            }
        }
    }
    return image;
}

- (UIImage *)getCachedImageNamed:(NSString *)imageName {
    if (!imageName) {
        return nil;
    }
    if (![imageName isKindOfClass:[NSString class]]) {
        return nil;
    }
    UIImage *image = nil;
    @synchronized(self.cachedImagesOnName) {
        image = [self.cachedImagesOnName objectForKey:imageName];
        if (!image) {
            image = [UIImage imageNamed:imageName];
            if (image) {
                [self.cachedImagesOnName setObject:image forKey:imageName];
            }
        }
    }
    return image;
}

- (UIImage *)getCachedImageNamed:(NSString *)imageName forSize:(CGSize)imageSize {
    imageSize.height = floor(imageSize.height);
    imageSize.width = floor(imageSize.width);
    if ((!imageName) ||
        (imageSize.height < 1) ||
        (imageSize.width < 1)) {
        return nil;
    }
    if (![imageName isKindOfClass:[NSString class]]) {
        return nil;
    }
    UIImage *image = nil;
    @synchronized(self.cachedImagesOnNameForSize) {
        NSMutableDictionary *imageDictionary = [self.cachedImagesOnNameForSize objectForKey:imageName];
        if (!imageDictionary) {
            imageDictionary = [NSMutableDictionary dictionary];
            [self.cachedImagesOnNameForSize setObject:imageDictionary forKey:imageName];
        }
        NSString *encodedSize = NSStringFromCGSize(imageSize);
        image = [imageDictionary objectForKey:encodedSize];
        if (!image) {
            imageSize.height = imageSize.height * [UIScreen mainScreen].scale;
            imageSize.width = imageSize.width * [UIScreen mainScreen].scale;
            image = [[self getCachedImageNamed:imageName] imageByResizingAndCroppingForSize:imageSize];
            if (image) {
                [imageDictionary setObject:image forKey:encodedSize];
            }
        }
    }
    return image;
}

- (UIImage *)getCachedResizableImageNamed:(NSString *)imageName forSize:(CGSize)imageSize resizableImageWithCapInsets:(UIEdgeInsets)capInsets {
    return [self getCachedResizableImageNamed:imageName forSize:imageSize resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)getCachedResizableImageNamed:(NSString *)imageName forSize:(CGSize)imageSize resizableImageWithCapInsets:(UIEdgeInsets)capInsets resizingMode:(UIImageResizingMode)resizingMode {
    imageSize.height = floor(imageSize.height);
    imageSize.width = floor(imageSize.width);
    if ((!imageName) ||
        (imageSize.height < 1) ||
        (imageSize.width < 1)) {
        return nil;
    }
    if (![imageName isKindOfClass:[NSString class]]) {
        return nil;
    }
    UIImage *image = nil;
    @synchronized(self.cachedResizableImagesOnName) {
        NSMutableDictionary *imageDictionary = [self.cachedResizableImagesOnName objectForKey:imageName];
        if (!imageDictionary) {
            imageDictionary = [NSMutableDictionary dictionary];
            [self.cachedResizableImagesOnName setObject:imageDictionary forKey:imageName];
        }
        NSString *encodedSize = [NSString stringWithFormat:@"{\"imageSize\":\"%@\",\"capInsets\":\"%@\",\"resizingMode\":\"%@\"}",
                                 NSStringFromCGSize(imageSize), NSStringFromUIEdgeInsets(capInsets), ((resizingMode == UIImageResizingModeStretch) ? @"Stretch" : @"Tile")];
        image = [imageDictionary objectForKey:encodedSize];
        if (!image) {
            image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:capInsets resizingMode:resizingMode];
            UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
            [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            image = [image resizableImageWithCapInsets:capInsets resizingMode:resizingMode];
            if (image) {
                [imageDictionary setObject:image forKey:encodedSize];
            }
        }
    }
    return image;
}

@end
