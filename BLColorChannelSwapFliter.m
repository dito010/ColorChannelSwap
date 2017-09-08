//
//  BLColorChannelSwapFliter.m
//  JPQRCodeTool
//
//  Created by NewPan on 2017/9/6.
//  Copyright © 2017年 尹久盼. All rights reserved.
//

#import "BLColorChannelSwapFliter.h"
#import "BLLogMacros.h"

@implementation BLColorChannelSwapFliter

static CIColorKernel *customKernel = nil;

- (instancetype)initWithKernelSourceName:(NSString *)kernelSourceName {
    NSAssert(kernelSourceName.length > 0, @"初始化滤镜, kernelSourceName 为空");
    if (!kernelSourceName.length) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        if (customKernel == nil) {
            NSString *pathString = [[NSBundle bundleForClass:[self class]] pathForResource:kernelSourceName ofType:@"cikernel"];
            NSURL *kernelURL = [NSURL fileURLWithPath:pathString];
            
            NSError *error;
            NSString *kernelCode = [NSString stringWithContentsOfURL:kernelURL encoding:NSUTF8StringEncoding error:&error];
            if (kernelCode == nil) {
                BLLog(@"Error loading kernel code string in %@\n%@", NSStringFromSelector(_cmd), [error localizedDescription]);
                abort();
            }
            
            NSArray *kernels = [CIKernel kernelsWithString:kernelCode];
            NSAssert(kernels.count > 0, @"kernels 生成失败");
            if (!kernels.count) {
                return nil;
            }
            
            customKernel = kernels.firstObject;
        }
    }
    return self;
}

- (CIImage *)outputImage {
    /*
     extent，也就是之前提到的 DOD，暂且略过。
     callback，也就是之前提到的 ROI，暂且略过。
     image，缺省的 inputImage，传入我们的成员变量 inputImage 即可。
     args，输入参数数组，与 CIKernel 中定义的一一对应。这里只有一个 inputWidth。
     */
    CIImage *result = [customKernel applyWithExtent:self.inputImage.extent arguments:@[self.inputImage]];
    return result;
}

@end
