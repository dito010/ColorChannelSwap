//
//  UIImage+ColorChannelSwap.h
//  JPQRCodeTool
//
//  Created by NewPan on 2017/9/6.
//  Copyright © 2017年 尹久盼. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLColorChannelSwapTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ColorChannelSwap)

/**
 * 将一张图片的颜色 RGB 颜色通道进行对调.
 * 颜色类别不区分循序.
 *
 * @param leftColorChannel  要对调的颜色通道类别.
 * @param rightColorChannel 要对调的颜色通道类别.
 *
 * @return 对调过颜色通道的图片.
 */
- (UIImage * _Nullable)bl_swapColorChannel:(BLColorChannelType)leftColorChannel andColorChannel:(BLColorChannelType)rightColorChannel;

@end

NS_ASSUME_NONNULL_END
