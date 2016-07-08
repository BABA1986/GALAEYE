//
//  UIImage+ImageMask.h
//
//  Created by Vidhi on 04/07/16.
//  Copyright © 2016 Vidhi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageMask)

+ (UIImage *)createImageFromMask:(UIImage *)imageToMask withFillColor:(UIColor *)fillColor;
+ (UIImage *)createImageFromMask:(UIImage *)imageToMask withFillColor:(UIColor *)fillColor needCache:(BOOL)saveValue;
+ (UIImage *)createImageFromMaskWithImageName:(NSString *)imageName withFillColor:(UIColor *)fillColor;
+ (UIImage *)createImageFromMaskWithImagePath:(NSString *)imagePath withFillColor:(UIColor *)fillColor;
+ (UIImage *)createImageFromMaskOfImageName:(NSString *)imageName withFillColor:(UIColor *)fillColor needCache:(BOOL)saveValue;
+ (UIImage *)createImageFromMaskWithImagePath:(NSString *)imagePath withFillColor:(UIColor *)fillColor needCache:(BOOL)saveValue;
+ (UIImage*)imageWithName: (NSString*)imageName;
@end
