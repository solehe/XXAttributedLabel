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
    TMAttributedLabelDelegate
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
    XXAttributedLabel *label = [[XXAttributedLabel alloc] initWithFrame:CGRectMake(20, 100, 335, 180)];
    [label setBackgroundColor:[UIColor yellowColor]];
    [label setLinkColor:[UIColor redColor]];
    [label setEnableSelected:YES];
    [label setNumberOfLines:0];
    [self.view addSubview:label];
    
    [label setText:@"ဘယ်လိုပါလဲ။ 我们不爱睡觉အိမ်ကို မြင်ဖို့ ကောင်းပါတယ်။ ပိုမြန်မြန်မြန်မြန်မြန် မဟုတ်ဘူး။ အိမ်ကို သွားဖို့ ကောင်းပါတယ်။ အိမ်ကို ရောက်တဲ့"];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, label.font.lineHeight)];
    [view setBackgroundColor:[UIColor redColor]];
    [label append:view];

    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, label.font.lineHeight)];
    [label1 setBackgroundColor:[UIColor purpleColor]];
    [label1 setTextColor:[UIColor redColor]];
    [label1 setText:@"111"];
    [label append:label1];
    
    [label append:[UIImage imageNamed:@"icon_chats_block"]];
    
    [label append:@"888"];
    
    [label append:@"န်မြန်မြန်မြန်မြန်"];
    
    [label append:@"生命诚可贵，爱情价更高。若为自由故，两者皆可抛。"];
    
    [label append:@"12356703j,ad.asjd;kl"];
    
    [label addCustomLink:@"" forRange:NSMakeRange(12, 6)];

    [label addCustomLink:@"" forRange:NSMakeRange(152, 24) color:[UIColor magentaColor]];
    
    CGSize size = [label sizeThatFits:CGSizeMake(335, 180)];
    [label setFrame:CGRectMake(20, 100, size.width, size.height)];
    
    
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

- (void)attributedLabel:(TMAttributedLabel *)label clickedOnLink:(id)linkData {
    
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
    if (action == @selector(copy:)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)copy:(id)obj {
    XXAttributedLabel *label = [self.view viewWithTag:1024];
    [[UIPasteboard generalPasteboard] setString:label.selectedText];
    NSLog(@"复制到粘贴板的文本：%@", label.selectedText);
}

@end
