//
//  UIImage+ImageMask.m
//
//  Created by Vidhi on 04/07/16.
//  Copyright © 2016 Vidhi. All rights reserved.
//

#import "UIImage+ImageMask.h"

@implementation UIImage (ImageMask)

//Return mask image on passing image
+ (UIImage *)createImageFromMask:(UIImage *)imageToMask withFillColor:(UIColor *)fillColor
{
    CGRect rect = CGRectMake(0, 0, imageToMask.size.width, imageToMask.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, imageToMask.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [imageToMask drawInRect:rect];
    CGContextSetFillColorWithColor(c, [fillColor CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return maskImage;
}

+ (UIImage *)createImageFromMask:(UIImage *)imageToMask withFillColor:(UIColor *)fillColor needCache:(BOOL)saveValue
{
    UIImage* maskImage = [UIImage createImageFromMask:imageToMask withFillColor:fillColor];
    if(saveValue)
    {
        NSFileManager* lFManager = [NSFileManager defaultManager];
        NSArray* lDocDirUrls = [lFManager URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask];
        NSURL* documentsDirectoryUrl = [lDocDirUrls objectAtIndex:0];
        NSURL* imgPath = [documentsDirectoryUrl URLByAppendingPathComponent:@"cachedMaskImage"];
        NSData *lImageData = UIImageJPEGRepresentation(maskImage, 1.0);
        [lImageData writeToURL: imgPath atomically:YES];
    }
    return maskImage;
}

//Return mask image on passing image name
+ (UIImage *)createImageFromMaskWithImageName:(NSString *)imageName withFillColor:(UIColor *)fillColor
{
    UIImage* imageToMask = [UIImage imageNamed:imageName];
    UIImage* maskImage = [UIImage createImageFromMask:imageToMask withFillColor:fillColor];
    return maskImage;
}

+ (UIImage *)createImageFromMaskOfImageName:(NSString *)imageName withFillColor:(UIColor *)fillColor needCache:(BOOL)saveValue
{
    UIImage* imageToMask = [UIImage imageNamed:imageName];
    UIImage* maskImage = [UIImage createImageFromMask:imageToMask withFillColor:fillColor needCache:FALSE];
    if(saveValue)
    {
        NSFileManager* lFManager = [NSFileManager defaultManager];
        NSArray* lDocDirUrls = [lFManager URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask];
        NSURL* documentsDirectoryUrl = [lDocDirUrls objectAtIndex:0];
        NSURL* imgPath = [documentsDirectoryUrl URLByAppendingPathComponent:@"cachedMaskImage"];
        BOOL lIsDir = FALSE;
        if (![lFManager fileExistsAtPath: imgPath.absoluteString isDirectory: &lIsDir])
        {
            NSError* lError = nil;
            [lFManager createDirectoryAtURL: imgPath withIntermediateDirectories: TRUE attributes: nil error: &lError];
        }
        imgPath = [imgPath URLByAppendingPathComponent: imageName];
        NSData *lImageData = UIImagePNGRepresentation(maskImage);
        [lImageData writeToURL: imgPath atomically:YES];
    }
    return maskImage;
}

//Return mask image on passing image path
+ (UIImage *)createImageFromMaskWithImagePath:(NSString *)imagePath withFillColor:(UIColor *)fillColor
{
    UIImage* imgToMask = [UIImage imageWithContentsOfFile:imagePath];
    UIImage* maskImg = [UIImage createImageFromMask:imgToMask withFillColor:fillColor];
    return maskImg;
}

+ (UIImage *)createImageFromMaskWithImagePath:(NSString *)imagePath withFillColor:(UIColor *)fillColor needCache:(BOOL)saveValue
{
    UIImage* imgToMask = [UIImage imageWithContentsOfFile:imagePath];
    UIImage* maskImg = [UIImage createImageFromMask:imgToMask withFillColor:fillColor needCache:saveValue];
    return maskImg;
}

+ (UIImage*)imageWithName: (NSString*)imageName
{
    NSFileManager* lFManager = [NSFileManager defaultManager];
    NSArray* lDocDirUrls = [lFManager URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask];
    NSURL* documentsDirectoryUrl = [lDocDirUrls objectAtIndex:0];
    NSURL* imgPath = [documentsDirectoryUrl URLByAppendingPathComponent:@"cachedMaskImage"];
    imgPath = [imgPath URLByAppendingPathComponent: imageName];

    NSData* lData = [NSData dataWithContentsOfURL: imgPath];
    UIImage* lImage = [UIImage imageWithData: lData];
    return lImage;
}

@end
