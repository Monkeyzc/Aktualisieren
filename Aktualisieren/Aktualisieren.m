//
//  Aktualisieren.m
//  Aktualisieren
//
//  Created by zhaofei on 2018/12/26.
//  Copyright © 2018 zhaofei. All rights reserved.
//

#import "Aktualisieren.h"

#define currentInstalledVersion [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]

static NSString *skippedVersionKey = @"skippedVersionKey";
static NSString *nextTimeUpdateKey = @"nextTimeUpdateKey";

static CGFloat customNewVersionView_conatiner_padding = 32;
static CGFloat customNewVersionView_content_padding = 12;
static CGFloat customNewVersionView_button_height = 50;
static CGFloat customNewVersionView_content_max_height = 300;

@interface Aktualisieren()
    
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *contentLabel;
@property (nonatomic, strong) UIButton *skipBtn;
@property (nonatomic, strong) UIButton *nextTimeBtn;
@property (nonatomic, strong) UIButton *updateBtn;
@property (nonatomic, strong) NSLayoutConstraint *contentHeightConstraint;
@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *currentAppStoreVersion;
@property (nonatomic, strong) NSString *appStoreReleaseNotes;
@end

@implementation Aktualisieren
    
+ (void)checkNewVersion: (NSString *)appId {
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat: @"https://itunes.apple.com/cn/lookup?id=%@", appId];
    NSURL *url = [NSURL URLWithString: urlString];
    NSURLSessionDataTask *task = [session dataTaskWithURL: url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"dataTaskError: %@", error.localizedDescription);
            return ;
        }
        
        NSError *jsError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingMutableLeaves error: &jsError];
        if (jsError) {
            NSLog(@"jsonError: %@", jsError.localizedDescription);
            return;
        }
        
        if (![json isKindOfClass: [NSDictionary class]]) {
            NSLog(@"Is not dictionary");
            return ;
        }
        
        NSArray *results = [json objectForKey: @"results"];
        if (![results isKindOfClass: [NSArray class]] || results.count == 0) {
            NSLog(@"results is empty");
            return ;
        }
        
        NSDictionary *firstObjc = results.firstObject;
        
        if (![firstObjc isKindOfClass: [NSDictionary class]]) {
            NSLog(@"firstObjc is not dictionary");
            return ;
        }
        
        NSString *currentAppStoreVersion = [firstObjc objectForKey: @"version"];
        NSString *appStoreReleaseNotes = [firstObjc objectForKey: @"releaseNotes"];
        
        NSLog(@"currentAppStoreVersion: %@", currentAppStoreVersion);
        NSLog(@"appStoreReleaseNotes: %@", appStoreReleaseNotes);
        
        if ([self checkIsNewVersion: currentAppStoreVersion]) {
            [self alertWithAppId: appId NewVersion: currentAppStoreVersion releaseNotes: appStoreReleaseNotes];
        }
    }];
    [task resume];
}
    
+ (BOOL)checkIsNewVersion:(NSString *)currentAppStoreVersion {
    // check appStoreVersion > installedVersion
    BOOL isNew = [currentInstalledVersion compare: currentAppStoreVersion options: NSNumericSearch] == NSOrderedAscending;
    
    // check skipVersion != installedVersion
    NSString *skipedVersion = [[NSUserDefaults standardUserDefaults] objectForKey: skippedVersionKey];
    if ([skipedVersion isEqualToString: currentAppStoreVersion]) {
        isNew = false;
    }
    return isNew;
}

+ (void)alertWithAppId:(NSString *)appId NewVersion: (NSString *)newVersion releaseNotes:(NSString *)releaseNotes {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *newWindow = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
        Aktualisieren *v = [[Aktualisieren alloc] init];
        v.frame = [UIScreen mainScreen].bounds;
        v.window = newWindow;
        
        v.appId = appId;
        v.currentAppStoreVersion = newVersion;
        v.appStoreReleaseNotes = releaseNotes;
        
        v.contentLabel.text = releaseNotes;
        
        [v.window addSubview: v];
        
        [newWindow makeKeyAndVisible];
    });
}
   
#pragma mark - lazy load
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont systemFontOfSize: 20];
        _titleLabel.text = @"新版本提示";
    }
    return _titleLabel;
}
    
- (UITextView *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UITextView alloc] init];
        _contentLabel.editable = NO;
        _contentLabel.font = [UIFont systemFontOfSize: 16];
        _contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _contentLabel.text = @"_skipBtn.t";
    }
    return _contentLabel;
}

- (UIButton *)skipBtn {
    if (_skipBtn == nil) {
        _skipBtn = [[UIButton alloc] init];
        _skipBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_skipBtn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [_skipBtn setTitle: @"跳过" forState: UIControlStateNormal];
    }
    return _skipBtn;
}
    
- (UIButton *)nextTimeBtn {
    if (_nextTimeBtn == nil) {
        _nextTimeBtn = [[UIButton alloc] init];
        _nextTimeBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_nextTimeBtn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [_nextTimeBtn setTitle: @"下次更新" forState: UIControlStateNormal];
    }
    return _nextTimeBtn;
}

- (UIButton *)updateBtn {
    if (_updateBtn == nil) {
        _updateBtn = [[UIButton alloc] init];
        _updateBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_updateBtn setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [_updateBtn setTitle: @"立即更新" forState: UIControlStateNormal];
    }
    return _updateBtn;
}

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        [self configureUI];
    }
    return self;
}

- (void)configureUI {
    
    UIView *bgView = [[UIView alloc] init];
    bgView.translatesAutoresizingMaskIntoConstraints = NO;
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.5;
    [self addSubview: bgView];
    
    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 8;
    containerView.layer.masksToBounds = YES;
    [self addSubview: containerView];
    
    [containerView addSubview: self.titleLabel];
    [containerView addSubview: self.contentLabel];
    
    [containerView addSubview: self.skipBtn];
    [containerView addSubview: self.nextTimeBtn];
    [containerView addSubview: self.updateBtn];
    
    // events
    [self.skipBtn addTarget: self action: @selector(handleSkip) forControlEvents: UIControlEventTouchUpInside];
    [self.nextTimeBtn addTarget: self action: @selector(handleNextTime) forControlEvents: UIControlEventTouchUpInside];
    [self.updateBtn addTarget: self action: @selector(handleUpdate) forControlEvents: UIControlEventTouchUpInside];
    
    // Layout
    NSLayoutConstraint *bgView_top = [bgView.topAnchor constraintEqualToAnchor: self.topAnchor];
    NSLayoutConstraint *bgView_left = [bgView.leftAnchor constraintEqualToAnchor: self.leftAnchor];
    NSLayoutConstraint *bgView_right = [bgView.rightAnchor constraintEqualToAnchor: self.rightAnchor];
    NSLayoutConstraint *bgView_bottom = [bgView.bottomAnchor constraintEqualToAnchor: self.bottomAnchor];
    [NSLayoutConstraint activateConstraints: @[bgView_top, bgView_left, bgView_right, bgView_bottom]];
    
    NSLayoutConstraint *conatinerView_centerY = [containerView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant: -10];
    NSLayoutConstraint *containerView_left = [containerView.leftAnchor constraintEqualToAnchor: self.leftAnchor constant: customNewVersionView_conatiner_padding];
    NSLayoutConstraint *containerView_right = [containerView.rightAnchor constraintEqualToAnchor: self.rightAnchor constant: -customNewVersionView_conatiner_padding];
    [NSLayoutConstraint activateConstraints: @[containerView_left, containerView_right, conatinerView_centerY]];
    
    // title
    NSLayoutConstraint *title_centerX = [self.titleLabel.centerXAnchor constraintEqualToAnchor: containerView.centerXAnchor];
    NSLayoutConstraint *title_top = [self.titleLabel.topAnchor constraintEqualToAnchor: containerView.topAnchor constant: 20];
    [NSLayoutConstraint activateConstraints: @[title_top, title_centerX]];
    
    // content
    NSLayoutConstraint *content_label_top = [self.contentLabel.topAnchor constraintEqualToAnchor: self.titleLabel.bottomAnchor constant: 12];
    NSLayoutConstraint *content_label_left = [self.contentLabel.leftAnchor constraintEqualToAnchor: containerView.leftAnchor constant: customNewVersionView_content_padding];
    NSLayoutConstraint *content_label_right = [self.contentLabel.rightAnchor constraintEqualToAnchor: containerView.rightAnchor constant: -customNewVersionView_content_padding];
    NSLayoutConstraint *content_label_height_less = [self.contentLabel.heightAnchor constraintLessThanOrEqualToConstant: customNewVersionView_content_max_height];
    self.contentHeightConstraint = content_label_height_less;
    [NSLayoutConstraint activateConstraints: @[content_label_top, content_label_left, content_label_right, content_label_height_less]];
    
    // skip
    NSLayoutConstraint *skip_top = [self.skipBtn.topAnchor constraintEqualToAnchor: self.contentLabel.bottomAnchor constant: 12];
    NSLayoutConstraint *skip_left = [self.skipBtn.leftAnchor constraintEqualToAnchor: containerView.leftAnchor constant: 0];
    NSLayoutConstraint *skip_right = [self.skipBtn.rightAnchor constraintEqualToAnchor: containerView.rightAnchor constant: 0];
    NSLayoutConstraint *skip_height = [self.skipBtn.heightAnchor constraintEqualToConstant: customNewVersionView_button_height];
    [NSLayoutConstraint activateConstraints: @[skip_top, skip_left, skip_right, skip_height]];
    
    // nextTime
    NSLayoutConstraint *nextTime_top = [self.nextTimeBtn.topAnchor constraintEqualToAnchor: self.skipBtn.bottomAnchor constant: 0];
    NSLayoutConstraint *nextTime_left = [self.nextTimeBtn.leftAnchor constraintEqualToAnchor: containerView.leftAnchor constant: 0];
    NSLayoutConstraint *nextTime_right = [self.nextTimeBtn.rightAnchor constraintEqualToAnchor: containerView.rightAnchor constant: 0];
    NSLayoutConstraint *nextTime_height = [self.nextTimeBtn.heightAnchor constraintEqualToConstant: customNewVersionView_button_height];
    [NSLayoutConstraint activateConstraints: @[nextTime_top, nextTime_left, nextTime_right, nextTime_height]];
    
    // update
    NSLayoutConstraint *update_top = [self.updateBtn.topAnchor constraintEqualToAnchor: self.nextTimeBtn.bottomAnchor constant: 0];
    NSLayoutConstraint *update_left = [self.updateBtn.leftAnchor constraintEqualToAnchor: containerView.leftAnchor constant: 0];
    NSLayoutConstraint *update_right = [self.updateBtn.rightAnchor constraintEqualToAnchor: containerView.rightAnchor constant: 0];
    NSLayoutConstraint *update_height = [self.updateBtn.heightAnchor constraintEqualToConstant: customNewVersionView_button_height];
    [NSLayoutConstraint activateConstraints: @[update_top, update_left, update_right, update_height]];
    
    NSLayoutConstraint *container_bottom = [containerView.bottomAnchor constraintEqualToAnchor: self.updateBtn.bottomAnchor constant: 0];
    [NSLayoutConstraint activateConstraints: @[container_bottom]];
}
    
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 计算文字高度
    CGFloat width = [UIScreen mainScreen].bounds.size.width - customNewVersionView_conatiner_padding * 2 - customNewVersionView_content_padding * 2 - self.contentLabel.textContainerInset.left - self.contentLabel.textContainerInset.right;

    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:self.contentLabel.text  attributes: @{NSFontAttributeName: [UIFont systemFontOfSize: 16]}];
    CGSize size = [attrStr boundingRectWithSize:CGSizeMake(width, (CGFloat)MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;

    CGFloat height = size.height + self.contentLabel.textContainerInset.top + self.contentLabel.textContainerInset.bottom;

    if (height < customNewVersionView_content_max_height) {
        self.contentHeightConstraint.constant = height;
    }
}

#pragma mark - Events
- (void)handleSkip {
    // save current AppStore version in userDefault
    [[NSUserDefaults standardUserDefaults] setObject: self.currentAppStoreVersion forKey: skippedVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismiss];
}
    
- (void)handleNextTime {
    [self dismiss];
}
    
- (void)handleUpdate {
    [self dismiss];
    [self launchAppStore];
}

- (void)dismiss {
    [self removeFromSuperview];
    [self.window resignKeyWindow];
    self.window = nil;
}
    
- (void)launchAppStore {
    NSString *iTunesString = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@", self.appId];
    NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:iTunesURL options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:iTunesURL];
        }
    });
}
    
- (void)dealloc {
}
    
@end
