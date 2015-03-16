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
//  TCUTextField.h
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 01/01/15.
//  E-mail: mail@toreuyar.net
//  Copyright (c) 2015 Töre Çağrı Uyar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCUPickerView.h"

typedef enum : NSUInteger {
    DatePickerTimeFrameUknown = 0,
    DatePickerTimeFrameFuture = 1,
    DatePickerTimeFramePast = 2,
} DatePickerTimeFrame;

@class TCUTextField;

@protocol TCUTextFieldDelegate <UITextFieldDelegate>

@optional

@property (nonatomic, strong) UIColor *textFieldDefaultTextColor;
@property (nonatomic, strong) UIColor *textFieldWarningTextColor;
@property (nonatomic, strong) UIColor *textFieldDefaultPlaceholderColor;
@property (nonatomic, strong) UIColor *textFieldWarningPlaceholderColor;
@property (nonatomic, strong) NSString *textFieldBackgroundImageName;
@property (nonatomic, strong) NSNumber *textFieldBackgroundEdgeInsetTop;
@property (nonatomic, strong) NSNumber *textFieldBackgroundEdgeInsetLeft;
@property (nonatomic, strong) NSNumber *textFieldBackgroundEdgeInsetBottom;
@property (nonatomic, strong) NSNumber *textFieldBackgroundEdgeInsetRight;

@end

@interface TCUTextField : UITextField

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet TCUPickerView *dataPicker;
@property (strong, atomic) IBOutlet UIView *inputAccessoryView;
@property (weak, nonatomic) IBOutlet UIButton *pickerDismissButton;
@property (weak, nonatomic) IBOutlet id<TCUTextFieldDelegate> tcuTextFieldDelegate;
@property (weak, nonatomic) IBOutlet id<UITextFieldDelegate> chainTextFieldDelegate;
@property (weak, nonatomic) IBOutlet TCUTextField *equalityCheckedTextField;
@property (weak, nonatomic) IBOutlet TCUTextField *nextTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *inputDoneBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolBarTitleButton;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) id selectedData;
@property (nonatomic) BOOL requiredNotEmpty;
@property (nonatomic) BOOL hiddenCursor;
@property (nonatomic) DatePickerTimeFrame datePickerTimeFrame;
@property (nonatomic) CGPoint textRectInset;
@property (nonatomic) CGPoint editingRectInset;
@property (nonatomic) CGPoint placeholderRectInset;

- (IBAction)inputDone:(id)sender;

- (void)setPlaceholderColor:(UIColor *)textColor;

@end
