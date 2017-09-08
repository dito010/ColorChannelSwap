//
//  BLColorChannelSwapTool.h
//  JPQRCodeTool
//
//  Created by NewPan on 2017/9/6.
//  Copyright © 2017年 尹久盼. All rights reserved.
//

/*
 * 这个类可以将一张图片的颜色 RGB 颜色通道进行对调.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BLColorChannelType) {
    BLColorChannelTypeRed = 0, // 红色通道.
    BLColorChannelTypeGreen, // 绿色通道.
    BLColorChannelTypeBlue // 蓝色通道.
};

typedef NS_ENUM(NSUInteger, BLColorChannelSwapHardwareType) {
    BLColorChannelSwapHardwareTypeGPU = 0, // 使用 GPU.
    BLColorChannelSwapHardwareTypeCPU // 使用 CPU.
};

@interface BLColorChannelSwapTool : NSObject

/**
 * 将一张图片的颜色 RGB 颜色通道进行对调.
 * 颜色类别不区分循序.
 *
 * @param leftColorChannel  要对调的颜色通道类别.
 * @param rightColorChannel 要对调的颜色通道类别.
 * @param image             要对调颜色通道的图片.
 * @param hardwareType      使用的硬件类型.
 *
 * @return 对调过颜色通道的图片.
 */
+ (UIImage *_Nullable)swapColorChannel:(BLColorChannelType)leftColorChannel andColorChannel:(BLColorChannelType)rightColorChannel forImage:(UIImage *)image useHardwareType:(BLColorChannelSwapHardwareType)hardwareType;

/**
 * 将一张图片的颜色 RGB 颜色通道进行对调(使用 GPU).
 * 颜色类别不区分循序.
 *
 * @param leftColorChannel  要对调的颜色通道类别.
 * @param rightColorChannel 要对调的颜色通道类别.
 * @param image             要对调颜色通道的图片.
 *
 * @return 对调过颜色通道的图片.
 */
+ (UIImage *_Nullable)swapColorChannel:(BLColorChannelType)leftColorChannel andColorChannel:(BLColorChannelType)rightColorChannel forImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
