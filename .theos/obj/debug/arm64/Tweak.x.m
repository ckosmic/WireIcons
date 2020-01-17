#line 1 "Tweak.x"
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


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SBIconView; @class SBIconImageView; 
static void (*_logos_orig$_ungrouped$SBIconImageView$setIconView$)(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST, SEL, SBIconView *); static void _logos_method$_ungrouped$SBIconImageView$setIconView$(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST, SEL, SBIconView *); static void (*_logos_orig$_ungrouped$SBIconView$setIcon$)(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SBIconView$setIcon$(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST, SEL, id); 

#line 36 "Tweak.x"


static void _logos_method$_ungrouped$SBIconImageView$setIconView$(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, SBIconView * arg1) {
    _logos_orig$_ungrouped$SBIconImageView$setIconView$(self, _cmd, arg1);
        
    int offset = -(60 - iconImgScale) / 2;
    wireView = [[UIView alloc] initWithFrame: CGRectMake(offset, offset, 60, 60)];
    [wireView.layer setBorderColor: LCPParseColorString(wireColor, @"#ffffff").CGColor];
    [wireView.layer setBorderWidth: wireWidth];
    [wireView.layer setCornerRadius: cornerRadius];
    [self addSubview: wireView];
}





static void _logos_method$_ungrouped$SBIconView$setIcon$(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    _logos_orig$_ungrouped$SBIconView$setIcon$(self, _cmd, arg1);
    
    CGSize imageSize = CGSizeMake(iconImgScale, iconImgScale);

    struct SBIconImageInfo imageInfo;
    imageInfo.size  = imageSize;
    imageInfo.scale = [UIScreen mainScreen].scale;
    imageInfo.continuousCornerRadius = 12;
    
    [self setIconImageInfo:imageInfo];
}




static __attribute__((constructor)) void _logosLocalCtor_bbe4a825(int __unused argc, char __unused **argv, char __unused **envp) {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)refreshPrefs, CFSTR("com.ckosmic.wireiconsprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    refreshPrefs();
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBIconImageView = objc_getClass("SBIconImageView"); MSHookMessageEx(_logos_class$_ungrouped$SBIconImageView, @selector(setIconView:), (IMP)&_logos_method$_ungrouped$SBIconImageView$setIconView$, (IMP*)&_logos_orig$_ungrouped$SBIconImageView$setIconView$);Class _logos_class$_ungrouped$SBIconView = objc_getClass("SBIconView"); MSHookMessageEx(_logos_class$_ungrouped$SBIconView, @selector(setIcon:), (IMP)&_logos_method$_ungrouped$SBIconView$setIcon$, (IMP*)&_logos_orig$_ungrouped$SBIconView$setIcon$);} }
#line 73 "Tweak.x"
