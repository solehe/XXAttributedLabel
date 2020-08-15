//
//  ViewController.m
//  Demo
//
//  Created by solehe on 2020/3/11.
//  Copyright © 2020 solehe. All rights reserved.
//

#import "ViewController.h"
#import "AttributedLabel.h"
//#import "XXAttributedLabel.h"
#import "TouchTestView.h"

@interface ViewController ()
//<
//    M80AttributedLabelDelegate
//>

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
    AttributedLabel *label = [[AttributedLabel alloc] initWithFrame:CGRectMake(20, 100, 335, 180)];
//    [label setVerticalAlignment:XXAttributedAlignmentBottom];
//    [label setTextAlignment:NSTextAlignmentRight];
    [label setBackgroundColor:[UIColor greenColor]];
//    [label setTextInsets:UIEdgeInsetsMake(50, 20, 20, 30)];
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
    
//    CGSize size = [label sizeThatFits:CGSizeMake(335, 180)];
//    [label setFrame:CGRectMake(20, 100, size.width, size.height)];
}

//
//#pragma mark - M80AttributedLabelDelegate
//
//- (void)m80AttributedLabel:(M80AttributedLabel *)label
//             clickedOnLink:(id)linkData {
//
//    if ([linkData isKindOfClass:[NSString class]])
//    {
//        NSLog(@"点击了链接：%@", linkData);
//    }
//    else
//    {
//        NSLog(@"点击了链接：%@", [label.text substringWithRange:[linkData rangeValue]]);
//    }
//}
//
//#pragma mark -
//
//- (BOOL)canBecomeFirstResponder {
//    return YES;
//}
//
//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{
//    if (action == @selector(copy:)) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//- (void)copy:(id)obj {
//    XXAttributedLabel *label = [self.view viewWithTag:1024];
//    [[UIPasteboard generalPasteboard] setString:label.selectedText];
//    NSLog(@"复制到粘贴板的文本：%@", label.selectedText);
//}

@end
