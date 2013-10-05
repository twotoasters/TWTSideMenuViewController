/*
 Copyright (c) 2013 Two Toasters, LLC <general@twotoasters.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "TWTSideMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "UIView-Transform.h"

static NSTimeInterval const kDefaultAnimationDelayDuration = 0.2;
static NSTimeInterval const kDefaultAnimationDuration = 0.5;
static NSTimeInterval const kDefaultSwapAnimationDuration = 0.55;
static NSTimeInterval const kDefaultSwapAnimationClosedDuration = 0.45;

@interface TWTSideMenuViewController () {
    CGAffineTransform menuCloseTransfrom;
    CGAffineTransform mainOpenTransfrom;
    
    CGAffineTransform originScaleTransfrom;
}

@property (nonatomic, strong) UIView *closeOverlayView;
@property (nonatomic, strong) UIView *containerView;

@end

@implementation TWTSideMenuViewController

#pragma mark - Life Cycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)initWithMenuViewController:(UIViewController *)menuViewController mainViewController:(UIViewController *)mainViewController
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _menuViewController = menuViewController;
        _mainViewController = mainViewController;
        
        [self commonInitialization];
    }
    return self;
}

- (void)commonInitialization
{
    self.animationDuration = kDefaultAnimationDuration;
    
    [self addViewController:self.menuViewController];
    [self addViewController:self.mainViewController];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandle:)];
    [self.view addGestureRecognizer:panGesture];
    
    self.menuViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.menuViewController.view];
    
    self.containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.mainViewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:self.mainViewController.view];
    [self.view addSubview:self.containerView];
    
    self.menuViewController.view.transform = [self closeTransformForMenuView];
    menuCloseTransfrom = self.menuViewController.view.transform;
    
    _closeOverlayView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    self.closeOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.closeOverlayView.alpha = 0.;
    [self.view addSubview:self.closeOverlayView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle:)];
    [self.closeOverlayView addGestureRecognizer:tapGesture];
}

#pragma mark - UIGesture

- (void)tapGestureHandle:(UITapGestureRecognizer *)tapGesture {
    if (!self.open)
        return ;
    [self closeMenuAnimated:YES completion:NULL];
}

- (void)panGestureHandle:(UIPanGestureRecognizer *)panGesture {
    UIGestureRecognizerState state = panGesture.state;
    
    CGPoint translation = [panGesture translationInView:panGesture.view];
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            
            
            if (!self.open) {
                // 当Menu关闭的时候
                CGFloat xOffset = translation.x * 0.9;
                CGFloat width = 857.5;
                
                float scaleOffset = (1.0 - (xOffset / width));
                
                if (xOffset > 0) {
                    // 正常的缩小和向右边移动
                    // left
                    CGAffineTransform leftScaleTransform = CGAffineTransformScale(menuCloseTransfrom, scaleOffset, scaleOffset);
                    CGAffineTransform leftPanGestureTransfrom = CGAffineTransformTranslate(leftScaleTransform, xOffset * 0.9, 0);
                    self.menuViewController.view.transform = leftPanGestureTransfrom;
                    
                    // main
                    CGAffineTransform mainScaleTransfrom = CGAffineTransformScale(CGAffineTransformIdentity, scaleOffset, scaleOffset);
                    CGAffineTransform mainPanGestureTransfrom = CGAffineTransformTranslate(mainScaleTransfrom, xOffset, 0);
                    self.containerView.transform = mainPanGestureTransfrom;
                    
                    // 过度的view
                    CGFloat widthOffset = self.view.bounds.size.width / (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? 4 : 3);
                    float alphaOffset = (translation.x + widthOffset) / self.view.bounds.size.width;
                    self.closeOverlayView.alpha = alphaOffset;
                    self.closeOverlayView.transform = mainPanGestureTransfrom;
                    
                } else if (xOffset < 0) {
                    // 不正常的放大和向左边移动
                }
                
            } else {
                CGFloat xOffset = translation.x * 0.88;
                CGFloat width = 520.5;
                
                float scaleOffset = (1.0 - (xOffset / width));
                
                // 打开的时候
                if (xOffset > 0) {
                    // 不正常的缩小和向右边移动
                    
                } else if (xOffset < 0) {
                    // 正常的放大和向左边移动
                    // left
                    self.menuViewController.view.transform = CGAffineTransformTranslate(CGAffineTransformScale(CGAffineTransformIdentity, scaleOffset, scaleOffset), xOffset * 0.75, 0);
                    
                    // main
                    CGAffineTransform originTransfrom = originScaleTransfrom;
                    CGAffineTransform scaleTransform = CGAffineTransformScale(originTransfrom, scaleOffset, scaleOffset);
                    CGAffineTransform openTransfrom = CGAffineTransformTranslate(scaleTransform, xOffset * 0.67, 0);
                    self.containerView.transform = openTransfrom;
                    
                    // 过度的view
                    CGFloat widthOffset = self.view.bounds.size.width / (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? 4 : 3);
                    float alphaOffset = (1.0 - (-translation.x + widthOffset) / self.view.bounds.size.width);
                    self.closeOverlayView.alpha = alphaOffset;
                    self.closeOverlayView.transform = openTransfrom;
                }
                
            }

            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            CGFloat velocityX = [panGesture velocityInView:panGesture.view].x;
            
            CGFloat mainViewScale = self.containerView.xscale;
            
            if (self.open) {
                // 已经打开了
                // 1、我只要判断滑动距离为
                if (velocityX <= 0) {
                    if (mainViewScale >= (1.0 - self.zoomScale) / 3.8 + self.zoomScale) {
                        self.open = YES;
                        [self closeMenuAnimated:YES completion:NULL];
                    } else {
                        self.open = NO;
                        [self openMenuAnimated:YES completion:NULL];
                    }
                } else {
                    self.open = NO;
                    [self openMenuAnimated:YES completion:NULL];
                }
            } else {
                if (velocityX >= 0) {
                    if (mainViewScale <= (1.0 - self.zoomScale) / 1.2 + self.zoomScale) {
                        self.open = NO;
                        [self openMenuAnimated:YES completion:NULL];
                    } else {
                        self.open = YES;
                        [self closeMenuAnimated:YES completion:NULL];
                    }
                } else {
                    self.open = YES;
                    [self closeMenuAnimated:YES completion:NULL];
                }
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Status Bar management

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if ([self respondsToSelector:@selector(preferredStatusBarStyle)]) {
        if (self.open) {
            return self.menuViewController.preferredStatusBarStyle;
        } else {
            return self.mainViewController.preferredStatusBarStyle;
        }
    } else {
        return UIStatusBarStyleDefault;
    }
}

- (void)updateStatusBarStyle
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - Menu Management

- (CGAffineTransform)closeTransformForMenuView
{
    CGAffineTransform originTransfrom = self.menuViewController.view.transform;
    CGFloat mainMidX = CGRectGetMidX(self.mainViewController.view.bounds);
    CGFloat menuEdgeOffsetHorizontal = self.edgeOffset.horizontal;
    CGFloat menuEdgeOffsetVertical = self.edgeOffset.vertical;
    
    CGFloat tx;
    if (originTransfrom.tx != 0) {
        tx = -menuCloseTransfrom.tx + originTransfrom.tx;
    } else {
        tx = (mainMidX + menuEdgeOffsetHorizontal);
    }
    
    CGFloat transformSize = (1.0f + (1.0f * self.zoomScale)) / self.menuViewController.view.transform.a;
    CGAffineTransform transform = CGAffineTransformScale(originTransfrom, transformSize, transformSize);
    CGAffineTransform tempMenuCloseTransfrom = CGAffineTransformTranslate(transform, -tx, -menuEdgeOffsetVertical);
    return tempMenuCloseTransfrom;
}

- (CGAffineTransform)openTransformForView:(UIView *)view
{
    CGFloat originXScale = view.xscale;
    CGFloat transformSize = (self.zoomScale / originXScale);
    CGAffineTransform newTransform = CGAffineTransformTranslate(view.transform, CGRectGetMidX(self.mainViewController.view.bounds) + self.edgeOffset.horizontal - view.tx, self.edgeOffset.vertical);
    originScaleTransfrom = CGAffineTransformScale(newTransform, transformSize, transformSize);
    return originScaleTransfrom;
}

- (void)openMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    if (self.open) {
        return;
    }
    self.open = YES;
    
    void (^openMenuBlock)(void) = ^{
        self.menuViewController.view.transform = CGAffineTransformIdentity;
        self.containerView.transform = [self openTransformForView:self.containerView];
        
        self.closeOverlayView.transform = [self openTransformForView:self.closeOverlayView];
        self.closeOverlayView.alpha = 1.0;
    };
    
    void (^openCompleteBlock)(BOOL) = ^(BOOL finished) {
        if (finished) {
        }
        
        if (completion) {
            completion(finished);
        }
    };
    
    [self addShadowToViewController:self.mainViewController];
    
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:openMenuBlock
                         completion:openCompleteBlock];
    } else {
        openMenuBlock();
        openCompleteBlock(YES);
    }
    
    [self updateStatusBarStyle];
}

- (void)closeMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    if (!self.open) {
        return;
    }
    self.open = NO;
    
    void (^closeMenuBlock)(void) = ^{
        self.menuViewController.view.transform = [self closeTransformForMenuView];
        self.containerView.transform = CGAffineTransformIdentity;
        
        self.closeOverlayView.transform = CGAffineTransformIdentity;
        self.closeOverlayView.alpha = 0.;
    };
    
    void (^closeCompleteBlock)(BOOL) = ^(BOOL finished) {
        if (finished) {
            [self updateStatusBarStyle];
        }
        
        if (completion) {
            completion(finished);
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:self.animationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:closeMenuBlock
                         completion:closeCompleteBlock];
    } else {
        closeMenuBlock();
    }
}

- (void)toggleMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    if (self.open) {
        [self closeMenuAnimated:animated completion:completion];
    } else {
        [self openMenuAnimated:animated completion:completion];
    }
}

- (void)setMainViewController:(UIViewController *)mainViewController animated:(BOOL)animated closeMenu:(BOOL)closeMenu
{
    UIViewController *outgoingViewController = self.mainViewController;
    UIView *overlayView = [[UIView alloc] initWithFrame:outgoingViewController.view.frame];
    overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    [self.containerView addSubview:overlayView];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @0.0f;
    animation.duration = kDefaultAnimationDuration;
    [overlayView.layer addAnimation:animation forKey:@"opacity"];
    
    UIViewController *incomingViewController = mainViewController;
    
    CGFloat outgoingStartX = CGRectGetMaxX(outgoingViewController.view.frame);
    NSTimeInterval changeTimeInterval = kDefaultSwapAnimationDuration;
    NSTimeInterval delayInterval = kDefaultAnimationDelayDuration;
    if (!self.open) {
        changeTimeInterval = kDefaultSwapAnimationClosedDuration;
        delayInterval = 0.0;
    }
    
    [self addShadowToViewController:incomingViewController];
    [self.containerView addSubview:incomingViewController.view];

    incomingViewController.view.frame = self.containerView.bounds;
    incomingViewController.view.transform = CGAffineTransformTranslate(incomingViewController.view.transform, outgoingStartX, 0.0f);
    
    void (^swapChangeBlock)(void) = ^{
        outgoingViewController.view.transform = CGAffineTransformMakeScale(0.85, 0.85);
        overlayView.transform = CGAffineTransformMakeScale(0.85, 0.85);
        
        incomingViewController.view.transform = CGAffineTransformIdentity;
    };
    
    void (^finishedChangeBlock)(BOOL finished) = ^(BOOL finished) {
        [self addViewController:incomingViewController];
        
        [outgoingViewController removeFromParentViewController];
        outgoingViewController.view.transform = CGAffineTransformIdentity;
        [outgoingViewController.view removeFromSuperview];
        [outgoingViewController didMoveToParentViewController:nil];
        [overlayView removeFromSuperview];
        self.open = NO;
    };
    
    if (animated) {
        if (closeMenu) {
            [self closeMenuAnimated:animated completion:nil];
        }
        
        [UIView animateWithDuration:changeTimeInterval
                              delay:delayInterval
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:swapChangeBlock
                         completion:finishedChangeBlock];
    } else {
        swapChangeBlock();
        finishedChangeBlock(YES);
    }
    
    self.mainViewController = mainViewController;
    self.mainViewController.sideMenuViewController = self;
}

#pragma mark - View Management

- (void)addViewController:(UIViewController *)viewController
{
    viewController.sideMenuViewController = self;
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
}

#pragma mark - Shadow management

- (void)addShadowToViewController:(UIViewController *)viewController
{
    CALayer *mainLayer = viewController.view.layer;
    if (mainLayer) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:mainLayer.bounds];
        mainLayer.shadowPath = path.CGPath;
        mainLayer.shadowColor = self.shadowColor.CGColor;
        mainLayer.shadowOffset = CGSizeZero;
        mainLayer.shadowOpacity = 0.6f;
        mainLayer.shadowRadius = 10.0f;
    }
}

@end

@implementation UIViewController (TWTSideMenuViewController)

- (void)setSideMenuViewController:(TWTSideMenuViewController *)sideMenuViewController
{
    objc_setAssociatedObject(self, @selector(sideMenuViewController), sideMenuViewController, OBJC_ASSOCIATION_ASSIGN);
}

- (TWTSideMenuViewController *)sideMenuViewController
{
    TWTSideMenuViewController *sideMenuController = objc_getAssociatedObject(self, @selector(sideMenuViewController));
    if (!sideMenuController) {
        sideMenuController = self.parentViewController.sideMenuViewController;
    }
    return sideMenuController;
}

@end

