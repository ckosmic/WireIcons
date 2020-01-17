#import <libcolorpicker.h>

struct SBIconImageInfo {
    CGSize size;
    CGFloat scale;
    CGFloat continuousCornerRadius;
};

@interface SBIconImageView : UIView
@end
@interface SBIconView : UIView
-(void)setIconImageInfo:(struct SBIconImageInfo)arg1;
@end
@interface SBIconImageInfo : NSObject
@end

static UIView *wireView;

static NSString *const prefsBundlePath = @"/var/mobile/Library/Preferences/com.ckosmic.wireiconsprefs.plist";
static NSString *wireColor;
static double wireWidth;
static double cornerRadius;
static int iconImgScale;

static void refreshPrefs() {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsBundlePath];
    wireColor = [prefs objectForKey:@"wireColor"];
    wireWidth = [[prefs objectForKey:@"wireWidth"] doubleValue];
    cornerRadius = [[prefs objectForKey:@"cornerRadius"] doubleValue];
    iconImgScale = [[prefs objectForKey:@"iconImgScale"] intValue];
    if([prefs objectForKey:@"wireWidth"] == nil) wireWidth = 1;
    if([prefs objectForKey:@"cornerRadius"] == nil) cornerRadius = 12;
    if([prefs objectForKey:@"iconImgScale"] == nil) iconImgScale = 60;
}

%hook SBIconImageView

-(void)setIconView:(SBIconView *)arg1 {
    %orig;
        
    int offset = -(60 - iconImgScale) / 2;
    wireView = [[UIView alloc] initWithFrame: CGRectMake(offset, offset, 60, 60)];
    [wireView.layer setBorderColor: LCPParseColorString(wireColor, @"#ffffff").CGColor];
    [wireView.layer setBorderWidth: wireWidth];
    [wireView.layer setCornerRadius: cornerRadius];
    [self addSubview: wireView];
}

%end

%hook SBIconView

-(void)setIcon:(id)arg1 {
    %orig(arg1);
    
    CGSize imageSize = CGSizeMake(iconImgScale, iconImgScale);

    struct SBIconImageInfo imageInfo;
    imageInfo.size  = imageSize;
    imageInfo.scale = [UIScreen mainScreen].scale;
    imageInfo.continuousCornerRadius = 12;
    
    [self setIconImageInfo:imageInfo];
}

%end


%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)refreshPrefs, CFSTR("com.ckosmic.wireiconsprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    refreshPrefs();
}
