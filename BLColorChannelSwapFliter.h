//
//  BLColorChannelSwapFliter.h
//  JPQRCodeTool
//
//  Created by NewPan on 2017/9/6.
//  Copyright © 2017年 尹久盼. All rights reserved.
//

#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLColorChannelSwapFliter : CIFilter

/**
 *图片输入.
 */
@property (nonatomic, strong) CIImage *inputImage;

- (instancetype)initWithKernelSourceName:(NSString *)kernelSourceName;

@end

NS_ASSUME_NONNULL_END
