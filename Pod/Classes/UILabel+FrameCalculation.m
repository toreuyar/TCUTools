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
//  UILabel+FrameCalculation.m
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 01/01/15.
//  E-mail: mail@toreuyar.net
//  Copyright (c) 2015 Töre Çağrı Uyar. All rights reserved.
//

#import "UILabel+FrameCalculation.h"

@implementation UILabel (FrameCalculation)

- (void)setCalculatedFrame {
    [self setCalculatedFrameWithMinimumHeight:CGFLOAT_MIN
                             andMaximumHeight:CGFLOAT_MAX
                                       origin:self.frame.origin];
}

- (void)setCalculatedFrameWithOrigin:(CGPoint)origin {
    [self setCalculatedFrameWithMinimumHeight:CGFLOAT_MIN
                             andMaximumHeight:CGFLOAT_MAX
                                       origin:origin];
}

- (void)setCalculatedFrameWithMinimumHeight:(CGFloat)minimumHeight andMaximumHeight:(CGFloat)maximumHeight {
    [self setCalculatedFrameWithMinimumHeight:minimumHeight
                             andMaximumHeight:maximumHeight
                                       origin:self.frame.origin];
}

- (void)setCalculatedFrameWithMinimumHeight:(CGFloat)minimumHeight andMaximumHeight:(CGFloat)maximumHeight origin:(CGPoint)origin {
    CGRect tempFrame = self.frame;
    CGSize constrainSize = CGSizeMake(tempFrame.size.width, CGFLOAT_MAX);
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:@{NSFontAttributeName:self.font}];
    tempFrame.size.height = ceil([attributedText boundingRectWithSize:constrainSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height + 1);
    if (tempFrame.size.height > maximumHeight) {
        tempFrame.size.height = maximumHeight;
    }
    if (tempFrame.size.height < minimumHeight) {
        tempFrame.size.height = minimumHeight;
    }
    tempFrame.origin = origin;
    self.frame = tempFrame;
}

@end
