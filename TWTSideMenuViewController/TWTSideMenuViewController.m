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

static NSTimeInterval const kDefaultAnimationDelayDuration = 0.2;
static NSTimeInterval const kDefaultAnimationDuration = 0.4;
static NSTimeInterval const kDefaultSwapAnimationDuration = 0.45;
static NSTimeInterval const kDefaultSwapAnimationClosedDuration = 0.35;

@interface TWTSideMenuViewController ()

@property (nonatomic, strong) UIButton *closeOverlayButton;
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
    self.animationType = TWTSideMenuAnimationTypeSlideOver;
    self.animationSwapDuration = kDefaultSwapAnimationDuration;

    [self addViewController:self.menuViewController];
    [self addViewController:self.mainViewController];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:self.mainViewController];
    self.containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.mainViewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:self.mainViewController.view];
    [self.view addSubview:self.containerView];
    [self.mainViewController didMoveToParentViewController:self];

    [self addChildViewController:self.menuViewController];
    [self.view insertSubview:self.menuViewController.view belowSubview:self.containerView];
    [self.menuViewController didMoveToParentViewController:self];

    [self updateMenuViewWithTransform:[self closeTransformForMenuView]];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self removeShadowFromViewController:self.mainViewController];

    if (self.open) {
        [self removeOverlayButtonFromMainViewController];

        [UIView animateWithDuration:duration animations:^{
            // Effectively closes the menu and reapplies transform. This is a half measure to get around the problem of new view controllers getting pushed on to the hierarchy without the proper height navigation.
            self.menuViewController.view.transform = [self closeTransformForMenuView];
            self.containerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.menuViewController.view.center = (CGPoint) { CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) };
            self.menuViewController.view.bounds = self.view.bounds;
        }];
    } else {
        [self updateMenuViewWithTransform:CGAffineTransformIdentity];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.open) {
        [UIView animateWithDuration:0.2 animations:^{
            self.menuViewController.view.transform = CGAffineTransformIdentity;
            self.containerView.transform = [self openTransformForView:self.containerView];
        } completion:^(BOOL finished) {
            [self addShadowToViewController:self.mainViewController];
            [self addOverlayButtonToMainViewController];
        }];
    } else {
        [self updateMenuViewWithTransform:CGAffineTransformIdentity];
        [self addShadowToViewController:self.mainViewController];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Reset the menu view's frame while the menu is closed. This keeps the menu position correctly when the menu is closed.
    if (!self.open) {
        [self updateMenuViewWithTransform:[self closeTransformForMenuView]];
    }
}

#pragma mark - Status Bar management

- (UIViewController *)childViewControllerForStatusBarStyle
{
    if (self.open) {
        return self.menuViewController;
    } else {
        return self.mainViewController;
    }
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    if (self.open) {
        return self.menuViewController;
    } else {
        return self.mainViewController;
    }
}

- (void)updateStatusBarStyle
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - Menu Management

- (void)updateMenuViewWithTransform:(CGAffineTransform)transform
{
    self.menuViewController.view.transform = transform;
    self.menuViewController.view.center = (CGPoint) { CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) };
    self.menuViewController.view.bounds = self.view.bounds;
}

- (CGAffineTransform)closeTransformForMenuView
{
    CGFloat transformSize = 1.0f / self.zoomScale;
    CGAffineTransform transform = CGAffineTransformScale(self.menuViewController.view.transform, transformSize, transformSize);
    return CGAffineTransformTranslate(transform, -(CGRectGetMidX(self.view.bounds)) - self.edgeOffset.horizontal, -self.edgeOffset.vertical);
}

- (CGAffineTransform)openTransformForView:(UIView *)view
{
    CGFloat transformSize = self.zoomScale;
    CGAffineTransform newTransform = CGAffineTransformTranslate(view.transform, CGRectGetMidX(view.bounds) + self.edgeOffset.horizontal, self.edgeOffset.vertical);
    return CGAffineTransformScale(newTransform, transformSize, transformSize);
}

- (void)openMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    if (self.open) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(sideMenuViewControllerWillOpenMenu:)]) {
	    [self.delegate sideMenuViewControllerWillOpenMenu:self];
    }
    
    self.open = YES;
    self.menuViewController.view.transform = [self closeTransformForMenuView];

    void (^openMenuBlock)(void) = ^{
        self.menuViewController.view.transform = CGAffineTransformIdentity;
        self.containerView.transform = [self openTransformForView:self.containerView];
    };
    
    void (^openCompleteBlock)(BOOL) = ^(BOOL finished) {
        if (finished) {
            [self addOverlayButtonToMainViewController];
        }
        
        if ([self.delegate respondsToSelector:@selector(sideMenuViewControllerDidOpenMenu:)]) {
	        [self.delegate sideMenuViewControllerDidOpenMenu:self];
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
    
    if ([self.delegate respondsToSelector:@selector(sideMenuViewControllerWillCloseMenu:)]) {
	    [self.delegate sideMenuViewControllerWillCloseMenu:self];
    }
    
    self.open = NO;
    
    [self removeOverlayButtonFromMainViewController];
    
    void (^closeMenuBlock)(void) = ^{
        self.menuViewController.view.transform = [self closeTransformForMenuView];
        self.containerView.transform = CGAffineTransformIdentity;
    };
    
    void (^closeCompleteBlock)(BOOL) = ^(BOOL finished) {
        if (finished) {
            [self updateStatusBarStyle];
        }
        self.menuViewController.view.transform = CGAffineTransformIdentity;

        if ([self.delegate respondsToSelector:@selector(sideMenuViewControllerDidCloseMenu:)]) {
	        [self.delegate sideMenuViewControllerDidCloseMenu:self];
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
        closeCompleteBlock(YES);
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
    UIViewController *incomingViewController = mainViewController;

    UIView *overlayView = [[UIView alloc] initWithFrame:outgoingViewController.view.frame];
    overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    [self.containerView addSubview:overlayView];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @0.0f;
    animation.duration = kDefaultAnimationDuration;
    [overlayView.layer addAnimation:animation forKey:@"opacity"];
    
    NSTimeInterval changeTimeInterval = self.animationSwapDuration;
    NSTimeInterval delayInterval = kDefaultAnimationDelayDuration;
    if (!self.open) {
        changeTimeInterval = kDefaultSwapAnimationClosedDuration;
        delayInterval = 0.0;
    }
    
    [self addShadowToViewController:incomingViewController];
    [self addViewController:incomingViewController];
    [self.containerView addSubview:incomingViewController.view];

    incomingViewController.view.frame = self.containerView.bounds;
    
    //Create default animation curve.
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
    switch (self.animationType) {
        case TWTSideMenuAnimationTypeSlideOver: {
            CGFloat outgoingStartX = CGRectGetMaxX(outgoingViewController.view.frame);

            incomingViewController.view.transform = CGAffineTransformTranslate(incomingViewController.view.transform, outgoingStartX, 0.0f);
            break;
        }
        case TWTSideMenuAnimationTypeFadeIn:
            incomingViewController.view.alpha = 0.6f;
            options = UIViewAnimationOptionCurveEaseOut;
            break;
    }

    
    void (^swapChangeBlock)(void) = ^{
        switch (self.animationType) {
            case TWTSideMenuAnimationTypeSlideOver:
                incomingViewController.view.transform = CGAffineTransformIdentity;
                break;
            case TWTSideMenuAnimationTypeFadeIn:
                incomingViewController.view.alpha = 1.0f;
            default:
                break;
        }
    };
    
    void (^finishedChangeBlock)(BOOL finished) = ^(BOOL finished) {
        [incomingViewController didMoveToParentViewController:self];

        [outgoingViewController removeFromParentViewController];
        [outgoingViewController.view removeFromSuperview];
        [outgoingViewController didMoveToParentViewController:nil];
        [overlayView removeFromSuperview];
        [self.closeOverlayButton removeFromSuperview];
        self.open = NO;
    };
    
    if (animated) {
        if (closeMenu) {
            [self closeMenuAnimated:animated completion:nil];
        }
        
        [UIView animateWithDuration:changeTimeInterval
                              delay:delayInterval
                            options:options
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

- (void)removeShadowFromViewController:(UIViewController *)viewController
{
    CALayer *mainLayer = viewController.view.layer;
    if (mainLayer) {
        mainLayer.shadowOpacity = 0.0f;
    }
}

#pragma mark - Overlay button management

- (void)addOverlayButtonToMainViewController
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.accessibilityLabel = self.closeOverlayAccessibilityLabel;
    button.accessibilityHint = self.closeOverlayAccessibilityHint;
    button.backgroundColor = [UIColor clearColor];
    button.opaque = NO;
    button.frame = self.containerView.frame;
    
    [button addTarget:self action:@selector(closeButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(closeButtonTouchedDown) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(closeButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.view addSubview:button];
    self.closeOverlayButton = button;
}

- (void)removeOverlayButtonFromMainViewController
{
    [self.closeOverlayButton removeFromSuperview];
}

- (void)closeButtonTouchUpInside
{
    [self closeMenuAnimated:YES completion:nil];
}

- (void)closeButtonTouchedDown
{
    self.closeOverlayButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
}

- (void)closeButtonTouchUpOutside
{
    self.closeOverlayButton.backgroundColor = [UIColor clearColor];
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

