//
//  ABXNotificationView.m
//  Sample Project
//
//  Created by Stuart Hall on 30/05/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import "ABXNotificationView.h"

#import "ABXNotification.h"

#import "NSString+ABXSizing.h"

@interface ABXNotificationView ()

@property (nonatomic, strong) ABXNotificationViewCallback actionCallback;
@property (nonatomic, strong) ABXNotificationViewCallback dismissCallback;

@end

@implementation ABXNotificationView

+ (ABXNotificationView*)show:(NSString*)text
                  actionText:(NSString*)actionText
             backgroundColor:(UIColor*)backgroundColor
                   textColor:(UIColor*)textColor
                 buttonColor:(UIColor*)buttonColor
                inController:(UIViewController*)controller
                 actionBlock:(ABXNotificationViewCallback)actionBlock
                dismissBlock:(ABXNotificationViewCallback)dismissBlock
{
    static NSInteger const kMaxWidth = 300;
    
    
    // Calculate the label height
    UIFont *font = [UIFont systemFontOfSize:15];
    CGFloat labelHeight = [text heightForWidth:kMaxWidth andFont:font];
    
    NSUInteger topPadding = [self topOffsetForController:controller];
    
    // Create the view
    CGFloat totalHeight = labelHeight + 50 + topPadding;
    ABXNotificationView *view = [[ABXNotificationView alloc] initWithFrame:CGRectMake(0, -totalHeight, CGRectGetWidth(controller.view.bounds), totalHeight)];
    view.backgroundColor = backgroundColor;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    view.actionCallback = actionBlock;
    view.dismissCallback = dismissBlock;
    [controller.view addSubview:view];
    
    // Label for the text
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(view.bounds) - kMaxWidth)/2, 15 + topPadding, kMaxWidth, labelHeight)];
    label.numberOfLines = 0;
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = textColor;
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [view addSubview:label];
    
    if (actionText) {
        // Action button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tintColor = buttonColor;
        [button setTitle:actionText forState:UIControlStateNormal];
        button.frame = CGRectMake((CGRectGetWidth(view.bounds) - kMaxWidth)/2, totalHeight - 40, kMaxWidth/2, 40);
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [button addTarget:view action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
    
    // Close Button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tintColor = buttonColor;
    [button setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
    if (actionText) {
        button.frame = CGRectMake(CGRectGetWidth(view.bounds) / 2, totalHeight - 40, kMaxWidth / 2, 40);
    }
    else {
        button.frame = CGRectMake((CGRectGetWidth(view.bounds) - kMaxWidth)/2, totalHeight - 40, CGRectGetWidth(view.bounds) / 2, 40);
    }
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [button addTarget:view action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    // Slide it down
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGFloat topPadding = 0;
                         CGRect r = view.frame;
                         r.origin.y = topPadding;
                         view.frame = r;
                     }];
    
    return view;
}

- (void)onAction:(UIButton*)button
{
    if (self.actionCallback) {
        self.actionCallback(self);
    }
}

- (void)onClose:(UIButton*)button
{
    if (self.dismissCallback) {
        self.dismissCallback(self);
    }
    [self dismiss];
}

- (void)dismiss
{
    // Slide it away
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect r = self.frame;
                         r.origin.y = -CGRectGetHeight(r);
                         self.frame = r;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

+ (NSInteger)topOffsetForController:(UIViewController*)controller
{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        // Determine the status bar size
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        CGRect statusBarWindowRect = [controller.view.window convertRect:statusBarFrame fromWindow: nil];
        CGRect statusBarViewRect = [controller.view convertRect:statusBarWindowRect fromView: nil];
        
        // Determine the navigation bar size
        CGFloat navbarHeight = CGRectGetHeight(controller.navigationController.navigationBar.frame);
        
        return CGRectGetHeight(statusBarViewRect) + navbarHeight;
    }
    return 0;
}

@end