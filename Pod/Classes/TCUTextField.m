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
//  TCUTextField.m
//  TCUTools
//
//  Created by Töre Çağrı Uyar on 01/01/15.
//  E-mail: mail@toreuyar.net
//  Copyright (c) 2015 Töre Çağrı Uyar. All rights reserved.
//

#import "TCUTextField.h"
#import "NSString+Email.h"
#import "TCUDataManager.h"

@class TCUTextField;

@interface _TCUTextFieldDelegate : NSObject <UITextFieldDelegate>

@property (nonatomic, weak) TCUTextField *textField;

@end

@interface TCUTextField()

@property (strong, nonatomic) _TCUTextFieldDelegate *ownDelegate;

- (void)pickerDismissButtonAction;
- (void)dateChanged:(id)sender;

@end

@implementation _TCUTextFieldDelegate

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(TCUTextField *)textField {
    return [self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)] ? [self.textField.tcuTextFieldDelegate textFieldShouldBeginEditing:self.textField] : YES;
}

- (void)textFieldDidBeginEditing:(TCUTextField *)textField {
    if (self.textField.datePicker) {
        switch (self.textField.datePickerTimeFrame) {
            case DatePickerTimeFrameFuture: {
                self.textField.datePicker.minimumDate = [NSDate date];
                self.textField.datePicker.maximumDate = nil;
                break;
            }
            case DatePickerTimeFramePast: {
                self.textField.datePicker.minimumDate = nil;
                self.textField.datePicker.maximumDate = [NSDate date];
                break;
            }
            default: {
                break;
            }
        }
    } else if (self.textField.dataPicker) {
        self.textField.dataPicker.associatedObject = self.textField;
        [self.textField.dataPicker reloadAllComponents];
    }
    if (self.textField.toolBarTitleButton) {
        self.textField.toolBarTitleButton.title = self.textField.placeholder;
    }
    if (self.textField.inputDoneBarButton) {
        self.textField.inputDoneBarButton.target = self.textField;
        self.textField.inputDoneBarButton.action = @selector(inputDone:);
    }
    if (self.textField.pickerDismissButton) {
        [self.textField.pickerDismissButton addTarget:self.textField action:@selector(pickerDismissButtonAction) forControlEvents:UIControlEventTouchUpInside];
        self.textField.pickerDismissButton.hidden = NO;
    }
    if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldDefaultTextColor)]) {
        self.textField.textColor = self.textField.tcuTextFieldDelegate.textFieldDefaultTextColor;
    }
    if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.textField.tcuTextFieldDelegate textFieldDidBeginEditing:self.textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(TCUTextField *)textField {
    return [self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)] ? [self.textField.tcuTextFieldDelegate textFieldShouldEndEditing:self.textField] : YES;
}

- (void)textFieldDidEndEditing:(TCUTextField *)textField {
    if (self.textField.dataPicker) {
        self.textField.dataPicker.associatedObject = nil;
    }
    if (self.textField.inputDoneBarButton) {
        self.textField.inputDoneBarButton.target = nil;
        self.textField.inputDoneBarButton.action = nil;
    }
    if (self.textField.toolBarTitleButton) {
        self.textField.toolBarTitleButton.title = nil;
    }
    if (self.textField.pickerDismissButton) {
        [self.textField.pickerDismissButton removeTarget:self action:@selector(pickerDismissButtonAction) forControlEvents:UIControlEventTouchUpInside];
        self.textField.pickerDismissButton.hidden = YES;
    }
    if (textField == self.textField.equalityCheckedTextField) {
        if ([textField.text isEqualToString:self.textField.text]) {
            if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldDefaultTextColor)]) {
                self.textField.textColor = self.textField.tcuTextFieldDelegate.textFieldDefaultTextColor;
            }
        } else {
            if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldWarningTextColor)]) {
                self.textField.textColor = self.textField.tcuTextFieldDelegate.textFieldWarningTextColor;
            }
        }
    } else {
        if (self.textField.requiredNotEmpty) {
            if (self.textField.text.length < 1) {
                if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldWarningPlaceholderColor)]) {
                    [self.textField setPlaceholderColor:self.textField.tcuTextFieldDelegate.textFieldWarningPlaceholderColor];
                }
            } else if ((self.textField.keyboardType == UIKeyboardTypeEmailAddress) &&
                       (![self.textField.text isEmailAddress])) {
                if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldWarningTextColor)]) {
                    self.textField.textColor = self.textField.tcuTextFieldDelegate.textFieldWarningTextColor;
                }
            } else if (self.textField.equalityCheckedTextField) {
                if ([self.textField.equalityCheckedTextField.text isEqualToString:self.textField.text]) {
                    if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldDefaultTextColor)]) {
                        self.textField.textColor = self.textField.tcuTextFieldDelegate.textFieldDefaultTextColor;
                    }
                } else {
                    if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldWarningTextColor)]) {
                        self.textField.textColor = self.textField.tcuTextFieldDelegate.textFieldWarningTextColor;
                    }
                }
            } else {
                if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldDefaultTextColor)]) {
                    self.textField.textColor = self.textField.tcuTextFieldDelegate.textFieldDefaultTextColor;
                }
            }
        } else if (self.textField.text.length > 0) {
            if ((self.textField.keyboardType == UIKeyboardTypeEmailAddress) &&
                (![self.textField.text isEmailAddress])) {
                if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldWarningTextColor)]) {
                    self.textField.textColor = self.textField.tcuTextFieldDelegate.textFieldWarningTextColor;
                }
            } else if (self.textField.equalityCheckedTextField) {
                if ([self.textField.equalityCheckedTextField.text isEqualToString:self.textField.text]) {
                    if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldDefaultTextColor)]) {
                        self.textField.textColor = self.textField.tcuTextFieldDelegate.textFieldDefaultTextColor;
                    }
                } else {
                    if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldWarningTextColor)]) {
                        self.textField.textColor = self.textField.tcuTextFieldDelegate.textFieldWarningTextColor;
                    }
                }
            } else {
                if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldDefaultTextColor)]) {
                    self.textField.textColor = self.textField.tcuTextFieldDelegate.textFieldDefaultTextColor;
                }
            }
        }
        if ([self.textField.chainTextFieldDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
            [self.textField.chainTextFieldDelegate textFieldDidEndEditing:self.textField];
        }
        if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
            [self.textField.tcuTextFieldDelegate textFieldDidEndEditing:self.textField];
        }
    }
}

- (BOOL)textField:(TCUTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL shouldChangeCharactersInRange = YES;
    if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        shouldChangeCharactersInRange = [self.textField.tcuTextFieldDelegate textField:self.textField shouldChangeCharactersInRange:range replacementString:string];
    }
    if (shouldChangeCharactersInRange) {
        if (textField == self.textField.equalityCheckedTextField) {
            if ([[textField.text stringByReplacingCharactersInRange:range withString:string] isEqualToString:self.textField.text]) {
                if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldDefaultTextColor)]) {
                    self.textField.textColor = self.textField.tcuTextFieldDelegate.textFieldDefaultTextColor;
                }
            } else {
                if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldWarningTextColor)]) {
                    self.textField.textColor = self.textField.tcuTextFieldDelegate.textFieldWarningTextColor;
                }
            }
            shouldChangeCharactersInRange = YES;
        } else {
            if (self.textField.hiddenCursor || self.textField.datePicker || self.textField.dataPicker) {
                shouldChangeCharactersInRange = NO;
            } else {
                if ([self.textField.chainTextFieldDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                    shouldChangeCharactersInRange = [self.textField.chainTextFieldDelegate textField:self.textField shouldChangeCharactersInRange:range replacementString:string];
                } else {
                    shouldChangeCharactersInRange = YES;
                }
            }
        }
    }
    return shouldChangeCharactersInRange;
}

- (BOOL)textFieldShouldClear:(TCUTextField *)textField {
    BOOL shouldClear = YES;
    if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        shouldClear = [self.textField.tcuTextFieldDelegate textFieldShouldClear:self.textField];
    }
    return shouldClear;
}

- (BOOL)textFieldShouldReturn:(TCUTextField *)textField {
    BOOL shouldReturn = YES;
    if ([self.textField.tcuTextFieldDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        shouldReturn = [self.textField.tcuTextFieldDelegate textFieldShouldReturn:self.textField];
    }
    if (shouldReturn) {
        if (textField.nextTextField) {
            BOOL nextTextFieldBecameFirstResponder = NO;
            while (textField.nextTextField) {
                if (textField.nextTextField.enabled) {
                    [textField.nextTextField becomeFirstResponder];
                    nextTextFieldBecameFirstResponder = YES;
                    break;
                } else {
                    textField = textField.nextTextField;
                }
            }
            if (!nextTextFieldBecameFirstResponder) {
                [textField resignFirstResponder];
            }
        } else {
            [textField resignFirstResponder];
        }
    }
    return shouldReturn;
}

@end

@implementation TCUTextField

@dynamic inputAccessoryView;

- (void)setSelectedDate:(NSDate *)selectedDate {
    _selectedDate = selectedDate;
    if (selectedDate) {
        self.text = [self.dateFormatter stringFromDate:selectedDate];
    } else {
        self.text = nil;
    }
}

- (_TCUTextFieldDelegate *)ownDelegate {
    if (!_ownDelegate) {
        [self willChangeValueForKey:@"ownDelegate"];
        _ownDelegate = [[_TCUTextFieldDelegate alloc] init];
        _ownDelegate.textField = self;
        [self willChangeValueForKey:@"ownDelegate"];
    }
    return _ownDelegate;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self.ownDelegate;
}

- (void)setPickerDismissButton:(UIButton *)pickerDismissButton {
    if (_pickerDismissButton) {
        [_pickerDismissButton removeTarget:self action:@selector(pickerDismissButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    _pickerDismissButton = pickerDismissButton;
    if (pickerDismissButton) {
        
    }
}

- (void)pickerDismissButtonAction {
    [self resignFirstResponder];
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    if (self.hiddenCursor || self.datePicker || self.dataPicker) {
        return CGRectZero;
    } else {
        return [super caretRectForPosition:position];
    }
}

-(void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (self.hiddenCursor || self.datePicker || self.dataPicker) {
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            gestureRecognizer.enabled = NO;
        } else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            if (((UITapGestureRecognizer *)gestureRecognizer).numberOfTapsRequired > 1) {
                gestureRecognizer.enabled = NO;
            }
        }
    }
    [super addGestureRecognizer:gestureRecognizer];
}

- (void)setTcuTextFieldDelegate:(id<TCUTextFieldDelegate>)tcuTextFieldDelegate {
    _tcuTextFieldDelegate = tcuTextFieldDelegate;
    if ([tcuTextFieldDelegate respondsToSelector:@selector(textFieldDefaultTextColor)]) {
        self.textColor = self.tcuTextFieldDelegate.textFieldDefaultTextColor;
    }
    if ([tcuTextFieldDelegate respondsToSelector:@selector(textFieldDefaultPlaceholderColor)]) {
        [self setPlaceholderColor:self.tcuTextFieldDelegate.textFieldDefaultPlaceholderColor];
    }
    if ([tcuTextFieldDelegate respondsToSelector:@selector(textFieldBackgroundImageName)]) {
        if ([tcuTextFieldDelegate respondsToSelector:@selector(textFieldBackgroundEdgeInsetTop)] &&
            [tcuTextFieldDelegate respondsToSelector:@selector(textFieldBackgroundEdgeInsetLeft)] &&
            [tcuTextFieldDelegate respondsToSelector:@selector(textFieldBackgroundEdgeInsetBottom)] &&
            [tcuTextFieldDelegate respondsToSelector:@selector(textFieldBackgroundEdgeInsetRight)]) {
            self.background = [[TCUDataManager defaultManager] getCachedResizableImageNamed:tcuTextFieldDelegate.textFieldBackgroundImageName
                                                                                    forSize:self.bounds.size
                                                                resizableImageWithCapInsets:UIEdgeInsetsMake(tcuTextFieldDelegate.textFieldBackgroundEdgeInsetTop.doubleValue,
                                                                                                             tcuTextFieldDelegate.textFieldBackgroundEdgeInsetLeft.doubleValue,
                                                                                                             tcuTextFieldDelegate.textFieldBackgroundEdgeInsetBottom.doubleValue,
                                                                                                             tcuTextFieldDelegate.textFieldBackgroundEdgeInsetRight.doubleValue)
                                                                               resizingMode:UIImageResizingModeStretch];
        } else {
            self.background = [[TCUDataManager defaultManager] getCachedImageNamed:tcuTextFieldDelegate.textFieldBackgroundImageName
                                                                           forSize:self.bounds.size];
        }
    }
}

- (void)setEqualityCheckedTextField:(TCUTextField *)equalityCheckedTextField {
    _equalityCheckedTextField = equalityCheckedTextField;
    equalityCheckedTextField.chainTextFieldDelegate = self.ownDelegate;
}

- (void)dateChanged:(id)sender {
    self.selectedDate = self.datePicker.date;
}

- (void)setDatePicker:(UIDatePicker *)datePicker {
    if (_datePicker) {
        [_datePicker removeTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    _datePicker = datePicker;
    if (datePicker) {
        self.dataPicker = nil;
        self.inputView = datePicker;
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    } else {
        self.inputView = nil;
        self.selectedDate = nil;
    }
}

- (void)setDataPicker:(TCUPickerView *)dataPicker {
    _dataPicker = dataPicker;
    if (dataPicker) {
        self.datePicker = nil;
        self.inputView = dataPicker;
    } else {
        self.inputView = nil;
    }
}

- (void)setPlaceholderColor:(UIColor *)textColor {
    if ([self.placeholder isKindOfClass:[NSString class]]) {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: textColor}];
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, self.textRectInset.x, self.textRectInset.y);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, self.editingRectInset.x, self.editingRectInset.y);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, self.placeholderRectInset.x, self.placeholderRectInset.y);
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.hiddenCursor || self.datePicker || self.dataPicker) {
        return NO;
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

- (IBAction)inputDone:(id)sender {
    if (self.datePicker) {
        [self dateChanged:self.datePicker];
    } else if (self.dataPicker) {
        for (NSUInteger i = 0; i < self.dataPicker.numberOfComponents; i++) {
            [self.dataPicker.delegate pickerView:self.dataPicker didSelectRow:[self.dataPicker selectedRowInComponent:i] inComponent:i];
        }
    }
    if ([self.delegate textFieldShouldReturn:self]) {
        [[super allTargets] enumerateObjectsUsingBlock:^(id target, BOOL *stop) {
            [[super actionsForTarget:target forControlEvent:UIControlEventEditingDidEndOnExit] enumerateObjectsUsingBlock:^(NSString *action, NSUInteger idx, BOOL *stop) {
                SEL actionSelector = NSSelectorFromString(action);
                if ([target respondsToSelector:actionSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [target performSelector:actionSelector withObject:self];
#pragma clang diagnostic pop
                }
            }];
        }];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if (self.requiredNotEmpty) {
        if (self.text.length < 1) {
            if ([self.tcuTextFieldDelegate respondsToSelector:@selector(textFieldWarningPlaceholderColor)]) {
                [self setPlaceholderColor:self.tcuTextFieldDelegate.textFieldWarningPlaceholderColor];
            }
        } else if ((self.keyboardType == UIKeyboardTypeEmailAddress) &&
                   (![self.text isEmailAddress])) {
            if ([self.tcuTextFieldDelegate respondsToSelector:@selector(textFieldWarningTextColor)]) {
                self.textColor = self.tcuTextFieldDelegate.textFieldWarningTextColor;
            }
        } else if (self.equalityCheckedTextField) {
            if ([self.equalityCheckedTextField.text isEqualToString:self.text]) {
                if ([self.tcuTextFieldDelegate respondsToSelector:@selector(textFieldDefaultTextColor)]) {
                    self.textColor = self.tcuTextFieldDelegate.textFieldDefaultTextColor;
                }
            } else {
                if ([self.tcuTextFieldDelegate respondsToSelector:@selector(textFieldWarningTextColor)]) {
                    self.textColor = self.tcuTextFieldDelegate.textFieldWarningTextColor;
                }
            }
        } else {
            if ([self.tcuTextFieldDelegate respondsToSelector:@selector(textFieldDefaultTextColor)]) {
                self.textColor = self.tcuTextFieldDelegate.textFieldDefaultTextColor;
            }
        }
    }
}

@end
