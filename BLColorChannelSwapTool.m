//
//  BLColorChannelSwapTool.m
//  JPQRCodeTool
//
//  Created by NewPan on 2017/9/6.
//  Copyright © 2017年 尹久盼. All rights reserved.
//

#import "BLColorChannelSwapTool.h"
#import "BLColorChannelSwapFliter.h"

@implementation BLColorChannelSwapTool

+ (UIImage *)swapColorChannel:(BLColorChannelType)leftColorChannel andColorChannel:(BLColorChannelType)rightColorChannel forImage:(UIImage *)image useHardwareType:(BLColorChannelSwapHardwareType)hardwareType {
    NSAssert(image, @"对调图片颜色, 没有传图片没进来 😓");
    if (!image) {
        return nil;
    }
    switch (hardwareType) {
        case BLColorChannelSwapHardwareTypeGPU:
            return [self useGPUSwapColorChannel:leftColorChannel andColorChannel:rightColorChannel forImage:image];
           
        case BLColorChannelSwapHardwareTypeCPU:
            return [self useCPUSwapColorChannel:leftColorChannel andColorChannel:rightColorChannel forImage:image];
    }
}

+ (UIImage *)swapColorChannel:(BLColorChannelType)leftColorChannel andColorChannel:(BLColorChannelType)rightColorChannel forImage:(UIImage *)image {
    return [self swapColorChannel:leftColorChannel andColorChannel:rightColorChannel forImage:image useHardwareType:BLColorChannelSwapHardwareTypeCPU];
}


#pragma mark - 使用 GPU

// 使用 GPU 的性能是 CPU 的好几百倍, 推荐使用 GPU 的形式.
+ (UIImage *)useGPUSwapColorChannel:(BLColorChannelType)leftColorChannel andColorChannel:(BLColorChannelType)rightColorChannel forImage:(UIImage *)image {
    
    // 1. 将UIImage转换成CIImage.
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    // 2. 创建滤镜.
    BLColorChannelSwapFliter *filter = [[BLColorChannelSwapFliter alloc] initWithKernelSourceName:[self fetchKernelSourceNameWithSwapColorChannel:leftColorChannel andColorChannel:rightColorChannel]];
    
    // 设置相关参数.
    [filter setValue:ciImage forKey:@"inputImage"];

    // 3. 渲染并输出CIImage.
    CIImage *outputImage = [filter outputImage];
    
    // 4. 获取绘制上下文.
    CIContext *context = [CIContext contextWithOptions:nil];
    
    // 5. 创建输出CGImage.
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *swapedImage = [UIImage imageWithCGImage:cgImage scale:1.f orientation:UIImageOrientationUp];
    
    // 6. 释放CGImage.
    CGImageRelease(cgImage);
    
    return swapedImage;
}

+ (NSString *)fetchKernelSourceNameWithSwapColorChannel:(BLColorChannelType)leftColorChannel andColorChannel:(BLColorChannelType)rightColorChannel {
    NSString *kernelSourceName;
    
    if ((leftColorChannel == BLColorChannelTypeRed && rightColorChannel == BLColorChannelTypeGreen) || (leftColorChannel == BLColorChannelTypeGreen && rightColorChannel == BLColorChannelTypeRed)) { // 红绿对调.
        kernelSourceName = @"ColorChannelSwapRedAndGreen";
    }
    else if ((leftColorChannel == BLColorChannelTypeRed && rightColorChannel == BLColorChannelTypeBlue) || (leftColorChannel == BLColorChannelTypeBlue && rightColorChannel == BLColorChannelTypeRed)) { // 红蓝对调.
        kernelSourceName = @"ColorChannelSwapRedAndBlue";
    }
    else if ((leftColorChannel == BLColorChannelTypeGreen && rightColorChannel == BLColorChannelTypeBlue) || (leftColorChannel == BLColorChannelTypeBlue && rightColorChannel == BLColorChannelTypeGreen)) { // 蓝绿对调.
        kernelSourceName = @"ColorChannelSwapBlueAndGreen";;
    }
    
    return kernelSourceName;
}

#pragma mark - 使用 CPU

+ (void)drawPixelWithIndexX:(CGFloat)indexX indexY:(CGFloat)indexY color:(UIColor *)color inContext:(CGContextRef)ctx {
    if ([color isEqual:[UIColor clearColor]]) { // 透明通道不用绘制.
        return;
    }
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(indexX, indexY, 1.f, 1.f)];
    [color set];
    [bezierPath stroke];
    CGContextSaveGState(ctx);
}

// 将原始图片的所有点的色值保存到二维数组.
+ (UIImage *)useCPUSwapColorChannel:(BLColorChannelType)leftColorChannel andColorChannel:(BLColorChannelType)rightColorChannel forImage:(UIImage *)image {
    
    // 将系统生成的二维码从 `CIImage` 转成 `CGImageRef`.
    CGImageRef imageRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imageRef);
    CGFloat height = CGImageGetHeight(imageRef);
    
    // 创建一个颜色空间.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 开辟一段 unsigned char 的存储空间，用 rawData 指向这段内存.
    // 每个 RGBA 色值的范围是 0-255，所以刚好是一个 unsigned char 的存储大小.
    // 每张图片有 height * width 个点，每个点有 RGBA 4个色值，所以刚好是 height * width * 4.
    // 这段代码的意思是开辟了 height * width * 4 个 unsigned char 的存储大小.
    unsigned char *rawData = (unsigned char *)calloc(height * width * 4, sizeof(unsigned char));
    
    // 每个像素的大小是 4 字节.
    NSUInteger bytesPerPixel = 4;
    // 每行字节数.
    NSUInteger bytesPerRow = width * bytesPerPixel;
    // 一个字节8比特
    NSUInteger bitsPerComponent = 8;
    
    // 将系统的二维码图片和我们创建的 rawData 关联起来，这样我们就可以通过 rawData 拿到指定 pixel 的内存地址.
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    UIGraphicsBeginImageContext(image.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    for (int indexY = 0; indexY < height; indexY++) {
        for (int indexX = 0; indexX < width; indexX++) {
            // 取出每个 pixel 的 RGBA 值，保存到矩阵中.
            @autoreleasepool {
                NSUInteger byteIndex = bytesPerRow * indexY + indexX * bytesPerPixel;
                
                UIColor *color = [self fetchColorWithRawData:rawData andByteIndex:byteIndex swapColorChannel:leftColorChannel andColorChannel:rightColorChannel];
                [self drawPixelWithIndexX:indexX indexY:indexY color:color inContext:ctx];
                
                byteIndex += bytesPerPixel;
            }
        }
    }
    
    free(rawData);
    
    UIImage *swapedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return swapedImage;
}

+ (UIColor *)fetchColorWithRawData:(unsigned char *)rawData andByteIndex:(NSUInteger)byteIndex swapColorChannel:(BLColorChannelType)leftColorChannel andColorChannel:(BLColorChannelType)rightColorChannel {
    
    CGFloat alpha = (CGFloat)rawData[byteIndex + 3];
    if (alpha == 0) { // 透明通道.
        return [UIColor clearColor];
    }
    
    NSUInteger red = (CGFloat)rawData[byteIndex];
    NSUInteger green = (CGFloat)rawData[byteIndex + 1];
    NSUInteger blue = (CGFloat)rawData[byteIndex + 2];
    
    NSUInteger temp = 0;
    if ((leftColorChannel == BLColorChannelTypeRed && rightColorChannel == BLColorChannelTypeGreen) || (leftColorChannel == BLColorChannelTypeGreen && rightColorChannel == BLColorChannelTypeRed)) { // 红绿对调.
        temp = red;
        red = green;
        green = temp;
    }
    else if ((leftColorChannel == BLColorChannelTypeRed && rightColorChannel == BLColorChannelTypeBlue) || (leftColorChannel == BLColorChannelTypeBlue && rightColorChannel == BLColorChannelTypeRed)) { // 红蓝对调.
        temp = red;
        red = blue;
        blue = temp;
    }
    else if ((leftColorChannel == BLColorChannelTypeGreen && rightColorChannel == BLColorChannelTypeBlue) || (leftColorChannel == BLColorChannelTypeBlue && rightColorChannel == BLColorChannelTypeGreen)) { // 蓝绿对调.
        temp = blue;
        blue = green;
        green = temp;
    }
    
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha / 255.0];
}

@end
