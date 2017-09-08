//
//  UIImage+ColorChannelSwap.m
//  JPQRCodeTool
//
//  Created by NewPan on 2017/9/6.
//  Copyright © 2017年 尹久盼. All rights reserved.
//

#import "UIImage+ColorChannelSwap.h"

@implementation UIImage (ColorChannelSwap)

- (UIImage *)bl_swapColorChannel:(BLColorChannelType)leftColorChannel andColorChannel:(BLColorChannelType)rightColorChannel {
    if (leftColorChannel == rightColorChannel) {
        return self;
    }
    
    return [BLColorChannelSwapTool swapColorChannel:leftColorChannel andColorChannel:rightColorChannel forImage:self];
}


@end
