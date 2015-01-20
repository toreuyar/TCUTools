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
//  TCUTools.h
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 01/01/15.
//  E-mail: mail@toreuyar.net
//  Copyright (c) 2015 Töre Çağrı Uyar. All rights reserved.
//

#ifndef __IPHONE_7_0
    #warning "This project uses features only available in iOS SDK 7.0 and later."
#endif

#ifndef TCUTools_h
#define TCUTools_h

#import "UILabel+FrameCalculation.h"
#import "NSString+Email.h"
#import "UIImage+MaskImage.h"
#import "UIImage+CachedImage.h"
#import "UIImage+ResizeAndCrop.h"
#import "TCUDataManager.h"
#import "TCUPickerView.h"
#import "TCUTextField.h"
#import "TCUVariableType.h"
#import "TCUPropertyAttributes.h"
#import "TCUImageView.h"

#ifdef DEBUG
    #define NSLogDebug(format, ...) NSLog(@"<%s:%d> %s: " format, strrchr("/" __FILE__, '/') + 1, __LINE__, __PRETTY_FUNCTION__, ## __VA_ARGS__)
    #define NSLogPrettyPrintedJSON(JSONObject) NSLog(@"<%s:%d> %s: " @"\n%@", strrchr("/" __FILE__, '/') + 1, __LINE__, __PRETTY_FUNCTION__, ([JSONObject isKindOfClass:[NSDictionary class]] || [JSONObject isKindOfClass:[NSArray class]]) ? [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSONObject options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding] : @"Object is not a JSON object!")
#else
    #define NSLogDebug(format, ...) ((void)0)
    #define NSLogPrettyPrintedJSON(JSONObject) ((void)0)
#endif

#endif
