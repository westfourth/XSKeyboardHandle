//
//  XSKeyboardHandle.m
//  XSKeyboardHandle
//
//  Created by xisi on 2018/6/13.
//  Copyright © 2018年 xisi. All rights reserved.
//

#import "XSKeyboardHandle.h"
#import <objc/runtime.h>

static UIView *XSKeyboardHandleLastView = nil;
static NSNotification *XSKeyboardHandleLastNotification = nil;
const CGFloat kXSKeyboardHandleGap = 0;             //  键盘与编辑视图的间隔

/*
    UITextField顺序 ------  didBegin，willShow，willHide，didEnd
    UITextView顺序  ------  willShow，didBegin，willHide，didEnd
 */
@implementation XSKeyboardHandle

+ (void)enable {
    [self registerNotifications];
}

+ (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
}

+ (void)unregisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)keyboardWillShow:(NSNotification *)notification {
    XSKeyboardHandleLastNotification = notification;
    
    /*  先didBeginEdit，再keyboardWillShow
        lastView不为nil，触发事件
     */
    if (XSKeyboardHandleLastView != nil) {
        [self showEvent];
    }
}

+ (void)keyboardWillHide:(NSNotification *)notification {
    XSKeyboardHandleLastNotification = notification;
    [self hideEvent];
}


+ (void)textFieldTextDidBeginEditing:(NSNotification *)notification {
    XSKeyboardHandleLastView = notification.object;
}

+ (void)textFieldTextDidEndEditing:(NSNotification *)notification {
    XSKeyboardHandleLastView = nil;
}


+ (void)textViewTextDidBeginEditing:(NSNotification *)notification {
    XSKeyboardHandleLastView = notification.object;
    
    /*  先keyboardWillShow，再didBeginEdit
        所以在这里触发事件
     */
    [self showEvent];
}

+ (void)textViewTextDidEndEditing:(NSNotification *)notification {
    XSKeyboardHandleLastView = nil;
}


//_______________________________________________________________________________________________________________

+ (void)showEvent {
    UIView *view = XSKeyboardHandleLastView;
    NSNotification *notification = XSKeyboardHandleLastNotification;
    UIView *controllerView = [self locateControllerView:view];
    
    CGRect transformedRect = [self coordinateInWindowForView:view];
    CGRect originalRect = transformedRect;
    originalRect.origin.y -= controllerView.transform.ty;
    
    //
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardMinY = CGRectGetMinY(keyboardRect);
    CGFloat viewMaxY = CGRectGetMaxY(originalRect);
    
    CGFloat offsetY = keyboardMinY - viewMaxY - kXSKeyboardHandleGap;           //  负数表示要将self.view向上移动
    if (offsetY < 0) {          //  将要编辑的视图比较低
        [self transformView:controllerView offsetY:offsetY duration:duration options:curve];
    } else {                    //  将要编辑的视图比较高
        [self transformView:controllerView offsetY:0 duration:duration options:curve];
    }
}

+ (void)hideEvent {
    UIView *view = XSKeyboardHandleLastView;
    NSNotification *notification = XSKeyboardHandleLastNotification;
    UIView *controllerView = [self locateControllerView:view];
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    [self transformView:controllerView offsetY:0 duration:duration options:curve];
}

/*!
 将self.view上下移动
 */
+ (void)transformView:(UIView *)view offsetY:(CGFloat)moveOffsetY duration:(NSTimeInterval)duration options:(UIViewAnimationCurve)curve {
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:curve];
        view.transform = CGAffineTransformMakeTranslation(0, moveOffsetY);
    }];
}


//_______________________________________________________________________________________________________________

//  找到视图所在控制器的view
+ (UIView *)locateControllerView:(UIView *)view {
    if (view.nextResponder == nil) {
        return nil;
    }
    
    if ([view.nextResponder isKindOfClass:[UIViewController class]]) {
        return view;
    }
    
    id nextResponder = view.nextResponder;
    while (![[nextResponder nextResponder] isKindOfClass:[UIViewController class]]) {
        nextResponder = [nextResponder nextResponder];
    }
    return nextResponder;
}

//  转换为window坐标系
+ (CGRect)coordinateInWindowForView:(UIView *)view {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    CGRect rect = [view convertRect:view.bounds toView:window];
    return rect;
}


@end
