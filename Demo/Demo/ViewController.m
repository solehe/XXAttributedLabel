//
//  ViewController.m
//  Demo
//
//  Created by solehe on 2020/3/11.
//  Copyright © 2020 solehe. All rights reserved.
//

#import "ViewController.h"
#import "XXAttributedLabel.h"
#import "TouchTestView.h"

@interface ViewController ()
<
    M80AttributedLabelDelegate
>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // TouchTestView
    TouchTestView *touchView = [[TouchTestView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:touchView];
    
    // Label
    XXAttributedLabel *label = [[XXAttributedLabel alloc]initWithFrame:CGRectZero];
    [label setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
    [label setTag:1024];

    NSString *text  = @"你可以前往https://github.com/solehe/XXAttributedLabel下载源代码";
    NSRange range   = [text rangeOfString:@"https://github.com/solehe/XXAttributedLabel"];
    label.text      = text;
    [label addCustomLink:[NSValue valueWithRange:range] forRange:range];
    label.delegate  = self;

    label.font      = [UIFont systemFontOfSize:16];
    label.frame     = CGRectInset(touchView.bounds, 20, 200);
    label.lineSpacing = 4.f;
    
    [touchView addSubview:label];

    CGFloat width   = CGRectGetWidth(self.view.bounds) - 40;
    CGSize size     = [label sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    CGRect frame    = label.frame;
    frame.size      = size;
    label.frame     = frame;
    
    
    // 支持选择
    label.enableSelected = YES;
    
    // 长按链接回调
    [label setLongPressedLinkBlock:^(id  _Nonnull linkData, LongPressedEndBlock  _Nonnull block) {
        
        NSString *linkString = nil;
        
        if ([linkData isKindOfClass:[NSString class]])
        {
            linkString = linkData;
        }
        else
        {
            linkString = [label.text substringWithRange:[linkData rangeValue]];
        }

        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"长按了链接" message:linkString preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            block();
        }];
        [alertVc addAction:cancelAction];
        
        [self presentViewController:alertVc animated:YES completion:nil];
    }];
    
    // 选择触发监听
    __weak typeof(label) weak_label = label;
    [label setSelectingListenBlock:^(BOOL selecting) {
        if (selecting) {
            [self.view becomeFirstResponder];
            [[UIMenuController sharedMenuController] showMenuFromView:weak_label rect:weak_label.bounds];
        } else {
            [self.view resignFirstResponder];
            [[UIMenuController sharedMenuController] hideMenu];
        }
    }];
    
    // 放大镜触发监听
    [label setMagnifyDisplayBlock:^(BOOL display) {
        [[UIMenuController sharedMenuController] setMenuVisible:!display];
    }];
}


#pragma mark - M80AttributedLabelDelegate

- (void)m80AttributedLabel:(M80AttributedLabel *)label
             clickedOnLink:(id)linkData {
    
    if ([linkData isKindOfClass:[NSString class]])
    {
        NSLog(@"点击了链接：%@", linkData);
    }
    else
    {
        NSLog(@"点击了链接：%@", [label.text substringWithRange:[linkData rangeValue]]);
    }
}

#pragma mark -

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)paste:(id)obj {
    XXAttributedLabel *label = [self.view viewWithTag:1024];
    [[UIPasteboard generalPasteboard] setString:label.selectedText];
    NSLog(@"复制到粘贴板的文本：%@", label.selectedText);
}

@end
