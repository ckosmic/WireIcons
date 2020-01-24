#line 1 "Tweak.x"
#import <libcolorpicker.h>

struct SBIconImageInfo {
    CGSize size;
    CGFloat scale;
    CGFloat continuousCornerRadius;
};

@interface SBIcon : NSObject
@end
@interface SBLeafIcon : SBIcon
@end
@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;
@end
@interface SBApplicationIcon : SBLeafIcon
    -(SBApplication*)application;
    -(UIImage *)iconImageWithInfo:(struct SBIconImageInfo)arg1;
@end
@interface SBIconImageView : UIView
    @property (nonatomic,readonly) SBApplicationIcon * icon;
    @property (nonatomic,readonly) UIImage * displayedImage;
    -(void)iconImageDidUpdate:(id)arg1;
    -(id)contentsImage;
@end
@interface SBIconView : UIView
    @property (nonatomic,retain) SBApplicationIcon * icon;
    @property (nonatomic,readonly) UIImage * iconImageSnapshot;
    -(void)setIconImageInfo:(struct SBIconImageInfo)arg1;
    -(id)_iconImageView;
@end
@interface SBIconImageInfo : NSObject
@end

@interface WireColorManager : NSObject
    @property (nonatomic, retain) NSMutableDictionary *colorCache;

    +(instancetype)sharedInstance;
    -(id)init;
    -(UIColor *)getAverageColor:(UIImage *)image;
    -(void)getDynamicColorForBundleIdentifier:(NSString *)bundleIdentifier withIconImage:(UIImage*)image completion:(void (^)(UIColor *))completionHandler;
@end

static NSString *const prefsBundlePath = @"/var/mobile/Library/Preferences/com.ckosmic.wireiconsprefs.plist";
static NSString *wireColor;
static double wireWidth;
static double cornerRadius;
static int iconImgScale;
static bool dynamicColors = false;


@implementation WireColorManager

+(instancetype)sharedInstance {
    static WireColorManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [WireColorManager alloc];
        sharedInstance.colorCache = [NSMutableDictionary new];
    });
    return sharedInstance;
}

-(id)init {
    return [WireColorManager sharedInstance];
}

-(UIColor *)getAverageColor:(UIImage *)image {
    NSMutableArray<UIColor *> *result = [NSMutableArray new];
    
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    NSUInteger i = 0;
    for(int n = 0; n < (width * height); n++) {
        CGFloat a = ((CGFloat) rawData[i + 3]) / 255.0f;
        CGFloat r = ((CGFloat) rawData[i]);
        CGFloat g = ((CGFloat) rawData[i + 1]);
        CGFloat b = ((CGFloat) rawData[i + 2]);
        
        if(a > 0) {
            UIColor *acolor = [UIColor colorWithRed:r green:g blue:b alpha:a];
            [result addObject:acolor];
        }
        i += bytesPerPixel;
    }
    free(rawData);
    
    CGFloat aR = 0;
    CGFloat aG = 0;
    CGFloat aB = 0;
    for(UIColor *c in result) {
        CGFloat r = 0.0, g = 0.0, b = 0.0, a = 0.0;
        [c getRed:&r green:&g blue:&b alpha:&a];
        aR += r;
        aG += g;
        aB += b;
    }
    
    CGFloat count = [result count];
    aR /= count;
    aG /= count;
    aB /= count;
    
    UIColor *averageColor = [UIColor colorWithRed:aR/255.0 green:aG/255.0 blue:aB/255.0 alpha:1.0];
    
    return averageColor;
}

-(void)getDynamicColorForBundleIdentifier:(NSString *)bundleIdentifier withIconImage:(UIImage*)image completion:(void (^)(UIColor *))completionHandler {
    if(!image) return;
    if(self.colorCache[bundleIdentifier]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            completionHandler([self.colorCache[bundleIdentifier] copy]);
        });
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIColor *color = [self getAverageColor:image];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (!self.colorCache[bundleIdentifier]) {
                self.colorCache[bundleIdentifier] = [color copy];
                completionHandler([color copy]);
            } else {
                completionHandler([self.colorCache[bundleIdentifier] copy]);
            }
        });
    });
}

@end

static void refreshPrefs() {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsBundlePath];
    wireColor = [prefs objectForKey:@"wireColor"];
    wireWidth = [[prefs objectForKey:@"wireWidth"] doubleValue];
    cornerRadius = [[prefs objectForKey:@"cornerRadius"] doubleValue];
    iconImgScale = [[prefs objectForKey:@"iconImgScale"] intValue];
    dynamicColors = [[prefs objectForKey:@"dynamicColors"] boolValue];
    if([prefs objectForKey:@"wireWidth"] == nil) wireWidth = 1;
    if([prefs objectForKey:@"cornerRadius"] == nil) cornerRadius = 12;
    if([prefs objectForKey:@"iconImgScale"] == nil) iconImgScale = 60;
    if([prefs objectForKey:@"dynamicColors"] == nil) dynamicColors = false;
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

@class SBIconImageView; @class SBIconView; 
static void (*_logos_orig$_ungrouped$SBIconImageView$setIconView$)(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST, SEL, SBIconView *); static void _logos_method$_ungrouped$SBIconImageView$setIconView$(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST, SEL, SBIconView *); static void (*_logos_orig$_ungrouped$SBIconImageView$iconImageDidUpdate$)(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST, SEL, SBApplicationIcon *); static void _logos_method$_ungrouped$SBIconImageView$iconImageDidUpdate$(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST, SEL, SBApplicationIcon *); static void (*_logos_orig$_ungrouped$SBIconView$setIcon$)(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST, SEL, SBApplicationIcon *); static void _logos_method$_ungrouped$SBIconView$setIcon$(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST, SEL, SBApplicationIcon *); 

#line 158 "Tweak.x"



static void _logos_method$_ungrouped$SBIconImageView$setIconView$(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, SBIconView * arg1) {
    _logos_orig$_ungrouped$SBIconImageView$setIconView$(self, _cmd, arg1);
        
    double offset = -(60 - iconImgScale) / 2.0;
    UIView *wireView = [[UIView alloc] initWithFrame: CGRectMake(offset, offset, 60, 60)];
    [wireView.layer setBorderWidth: wireWidth];
    [wireView.layer setCornerRadius: cornerRadius];
    
    if(dynamicColors) {
        CGSize imageSize = CGSizeMake(60, 60);
        struct SBIconImageInfo imageInfo;
        imageInfo.size  = imageSize;
        imageInfo.scale = 1.0;
        imageInfo.continuousCornerRadius = 0;
        if(arg1.icon && [arg1.icon iconImageWithInfo:imageInfo]) {
            [[WireColorManager sharedInstance] getDynamicColorForBundleIdentifier: arg1.icon.application.bundleIdentifier withIconImage: [arg1.icon iconImageWithInfo:imageInfo] completion: ^(UIColor *color) {
                [wireView.layer setBorderColor: color.CGColor];
            }];
        } else {
            
            [wireView.layer setBorderColor: LCPParseColorString(wireColor, @"#ffffff").CGColor];
        }
    } else {
        [wireView.layer setBorderColor: LCPParseColorString(wireColor, @"#ffffff").CGColor];
    }
    
    [self addSubview: wireView];
}


static void _logos_method$_ungrouped$SBIconImageView$iconImageDidUpdate$(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, SBApplicationIcon * icon) {
    UIView *wireView = self.subviews[0];
    
    CGSize imageSize = CGSizeMake(60, 60);
    struct SBIconImageInfo imageInfo;
    imageInfo.size  = imageSize;
    imageInfo.scale = 1.0;
    imageInfo.continuousCornerRadius = 0;
    if(dynamicColors) {
        if(icon && [icon iconImageWithInfo:imageInfo]) {
            [[WireColorManager sharedInstance] getDynamicColorForBundleIdentifier: icon.application.bundleIdentifier withIconImage: [icon iconImageWithInfo:imageInfo] completion: ^(UIColor *color) {
                [wireView.layer setBorderColor: color.CGColor];
            }];
        } else {
            [wireView.layer setBorderColor: LCPParseColorString(wireColor, @"#ffffff").CGColor];
        }
    } else {
        [wireView.layer setBorderColor: LCPParseColorString(wireColor, @"#ffffff").CGColor];
    }
}






static void _logos_method$_ungrouped$SBIconView$setIcon$(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, SBApplicationIcon * arg1) {
    _logos_orig$_ungrouped$SBIconView$setIcon$(self, _cmd, arg1);
    
    CGSize imageSize = CGSizeMake(iconImgScale, iconImgScale);

    struct SBIconImageInfo imageInfo;
    imageInfo.size  = imageSize;
    imageInfo.scale = [UIScreen mainScreen].scale;
    imageInfo.continuousCornerRadius = 12;
    
    [self setIconImageInfo:imageInfo];
    [self._iconImageView iconImageDidUpdate:arg1];
}




static __attribute__((constructor)) void _logosLocalCtor_de011b60(int __unused argc, char __unused **argv, char __unused **envp) {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)refreshPrefs, CFSTR("com.ckosmic.wireiconsprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    refreshPrefs();
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBIconImageView = objc_getClass("SBIconImageView"); MSHookMessageEx(_logos_class$_ungrouped$SBIconImageView, @selector(setIconView:), (IMP)&_logos_method$_ungrouped$SBIconImageView$setIconView$, (IMP*)&_logos_orig$_ungrouped$SBIconImageView$setIconView$);MSHookMessageEx(_logos_class$_ungrouped$SBIconImageView, @selector(iconImageDidUpdate:), (IMP)&_logos_method$_ungrouped$SBIconImageView$iconImageDidUpdate$, (IMP*)&_logos_orig$_ungrouped$SBIconImageView$iconImageDidUpdate$);Class _logos_class$_ungrouped$SBIconView = objc_getClass("SBIconView"); MSHookMessageEx(_logos_class$_ungrouped$SBIconView, @selector(setIcon:), (IMP)&_logos_method$_ungrouped$SBIconView$setIcon$, (IMP*)&_logos_orig$_ungrouped$SBIconView$setIcon$);} }
#line 238 "Tweak.x"
