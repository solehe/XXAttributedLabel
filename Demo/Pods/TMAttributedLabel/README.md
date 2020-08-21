TMAttributedLabel
==================


一款基于<a href="https://github.com/TTTAttributedLabel/TTTAttributedLabel">TTTAttributedLabel</a>和<a href="https://github.com/xiangwangfeng/M80AttributedLabel">M80AttributedLabel</a>实现的富文本展示Label。

# 特别说明
之前在使用TTTAttributedLabel和M80AttributedLabel时发现它们两者的功能都非常好用，但是又都不能满足需求。比如TTTAttributedLabel对于链接的识别和处理以及绘制方便支持非常好，但是其不支持内嵌图片和控件。而M80AttributedLabel使用非常方便且扩展性很强，但是其基于UIView实现使其丧失了作为Label来使用时的一些优势，同时在绘制一些其他语言（比如缅甸文）时达不到和系统一样的效果。因此在TTTAttributedLabel的绘制基础上，融合了M80AttributedLabel的一些特性，最终实现了TMAttributedLabel。由于作者能力有限，不能完全从零开发，只有站在两位巨人的肩旁上，力所能及的为开源社区贡献一点自己的力量。

# 特性
* 支持多行富文本显示
* 支持链接展示自定义链接添加
* 支持内嵌图片和控件
* 支持如下属性
   * `字体`
   * `文本颜色`
   * `链接颜色`
   * `多行显示` 
   * `文字左右对齐`
   * `文字上下对齐`
   * `换行模式`
   * `行间距`
   * `段落间距`
   * `最大行高`
   * `最小行高`
   * `多倍行高`
   * `边距`
    

# 系统要求
* iOS 9.0 及以上
* 需要 ARC

# 集成

### Podfile

```ruby
pod 'TMAttributedLabel'
```

### 手动集成

* `git clone https://github.com/solehe/TMAttributedLabel`
* 拷贝 `TMAttributedLabel` 中的源代码到你的工程中


# 使用方法

## 基本使用

```objc

TMAttributedLabel *label = [[TMAttributedLabel alloc] initWithFrame:CGRectMake(20, 100, 335, 180)];
[label setBackgroundColor:[UIColor yellowColor]];
[label setLinkHighlightColor:[UIColor redColor]];
[label setLineSpacing:3.f];
[label setNumberOfLines:0];
[self.view addSubview:label];

[label append:@"风急天高猿啸哀，\n"];
[label append:@"渚清沙白鸟飞回。\n"];
[label append:@"无边落木萧萧下，\n"];
[label append:@"不尽长江滚滚来。\n"];
[label append:@"万里悲秋常作客，\n"];
[label append:@"百年多病独登台。\n"];
[label append:@"艰难苦恨繁霜鬓，\n"];
   
```

## 链接

```objc

NSString *linkString = @"无边落木萧萧下，";
NSRange range = [label.text rangeOfString:linkString];
[label addCustomLink:linkString forRange:range color:[UIColor blueColor]];

```


## 控件

```objc

UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
[label1 setText:@"潦倒新停浊酒杯。"];

CGFloat width = [label sizeThatFits:CGSizeMake(335, label.font.lineHeight)].width;
[label1 setFrame:CGRectMake(0, 0, width, label.font.lineHeight+3)];

[label append:label1 alignment:TMAttributedAlignmentTop];
    
    
```

# 联系我
* https://github.com/solehe
* soleworld@163.com


# 许可证

TMAttributedLabel 使用 [MIT license][MIT] 许可证，详情见 LICENSE 文件。
