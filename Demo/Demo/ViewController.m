//
//  ViewController.m
//  Demo
//
//  Created by solehe on 2020/3/11.
//  Copyright © 2020 solehe. All rights reserved.
//

#import <XXAttributedLabel.h>

#import "ViewController.h"
#import "TouchTestView.h"

@interface ViewController ()
<
    TMAttributedLabelDelegate
>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];

    // Do any additional setup after loading the view.
    XXAttributedLabel *label = [[XXAttributedLabel alloc] initWithFrame:CGRectMake(20, 100, 335, 180)];
    [label setBackgroundColor:[UIColor yellowColor]];
    [label setLinkHighlightColor:[UIColor redColor]];
    [label setEnableSelected:YES];
    [label setLineSpacing:3.f];
    [label setNumberOfLines:0];
    [label setTag:1024];
    [label setDelegate:self];
    [self.view addSubview:label];
    
    [label append:@"风急天高猿啸哀，\n"];
    [label append:@"渚清沙白鸟飞回。\n"];
    [label append:@"无边落木萧萧下，\n"];
    [label append:@"不尽长江滚滚来。\n"];
    [label append:@"万里悲秋常作客，\n"];
    [label append:@"百年多病独登台。\n"];
    [label append:@"艰难苦恨繁霜鬓，\n"];
    //[label append:@"潦倒新停浊酒杯。\n"];
    
    // 以顶部对齐的方式添加一个label
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
    [label1 setText:@"潦倒新停浊酒杯。"];
    
    CGFloat width = [label sizeThatFits:CGSizeMake(335, label.font.lineHeight)].width;
    [label1 setFrame:CGRectMake(0, 0, width, label.font.lineHeight+3)];
    
    [label append:label1 alignment:TMAttributedAlignmentTop];
    
    // 重新计算尺寸
    CGSize size = [label sizeThatFits:CGSizeMake(335, 180)];
    [label setFrame:CGRectMake(20, 100, size.width, size.height)];
    
    // 添加链接
    NSString *linkString = @"无边落木萧萧下，";
    NSRange range = [label.text rangeOfString:linkString];
    [label addCustomLink:linkString forRange:range color:[UIColor blueColor]];
    
    
    // 长按链接回调
    [label setLongPressedLinkBlock:^(id  _Nonnull linkData, LongPressedEndBlock  _Nonnull block)
    {
        
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
    [label setSelectingListenBlock:^(BOOL selecting)
    {
        if (selecting) {
            [self.view becomeFirstResponder];
            [[UIMenuController sharedMenuController] showMenuFromView:weak_label rect:weak_label.bounds];
        } else {
            [self.view resignFirstResponder];
            [[UIMenuController sharedMenuController] hideMenu];
        }
    }];
    
    // 放大镜触发监听
    [label setMagnifyDisplayBlock:^(BOOL display)
     {
        if (display) {
            [[UIMenuController sharedMenuController] hideMenu];
            
        } else {
            [[UIMenuController sharedMenuController] showMenuFromView:weak_label rect:weak_label.bounds];
        }
    }];
}


#pragma mark - TMAttributedLabelDelegate

- (void)attributedLabel:(TMAttributedLabel *)label clickedOnLink:(id)linkData
{
    
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

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)copy:(id)obj
{
    XXAttributedLabel *label = [self.view viewWithTag:1024];
    [[UIPasteboard generalPasteboard] setString:label.selectedText];
    NSLog(@"复制到粘贴板的文本：%@", label.selectedText);
}

@end
