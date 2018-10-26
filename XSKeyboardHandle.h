//
//  XSKeyboardHandle.h
//  XSKeyboardHandle
//
//  Created by xisi on 2018/6/13.
//  Copyright © 2018年 xisi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    处理键盘升起时，正在编辑的视图如果被遮盖，则随键盘升起
 */
@interface XSKeyboardHandle : NSObject

+ (void)enable;         //  对所有的UITextField、UITextView启用键盘处理

@end
