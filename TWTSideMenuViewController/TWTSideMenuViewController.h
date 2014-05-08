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

#import <UIKit/UIKit.h>

@class TWTSideMenuViewController;

@protocol TWTSideMenuViewControllerDelegate <NSObject>
@optional
- (void)sideMenuViewControllerWillOpenMenu:(TWTSideMenuViewController *)sideMenuViewController;
- (void)sideMenuViewControllerDidOpenMenu:(TWTSideMenuViewController *)sideMenuViewController;
- (void)sideMenuViewControllerWillCloseMenu:(TWTSideMenuViewController *)sideMenuViewController;
- (void)sideMenuViewControllerDidCloseMenu:(TWTSideMenuViewController *)sideMenuViewController;
@end

@interface TWTSideMenuViewController : UIViewController

typedef NS_ENUM(NSInteger, TWTSideMenuAnimationType) {
    TWTSideMenuAnimationTypeSlideOver, //Default - new view controllers slide over the old view controller.
    TWTSideMenuAnimationTypeFadeIn //New View controllers fade in over the old view controller.
};

/** Apply to this delegate to get several side menu events */
@property (nonatomic, weak) id<TWTSideMenuViewControllerDelegate> delegate;

/** The animation type - will default to Slide Over. */
@property (nonatomic, assign) TWTSideMenuAnimationType animationType;

/** Time interval for opening and closing the side menu */
@property (nonatomic, assign) NSTimeInterval animationDuration;

/** Time interval for swapping main view controllers */
@property (nonatomic, assign) NSTimeInterval animationSwapDuration;

/** Is the menu currently open? */
@property (nonatomic, assign, getter = isOpen) BOOL open;

/** Offset to position the menu in open position */
@property (nonatomic, assign) UIOffset edgeOffset;

/** The scale for zooming the viewport. 0.0 to 1.0 */
@property (nonatomic, assign) CGFloat zoomScale;

/** The color of the shadow to display behind the scaled main view */
@property (nonatomic, strong) UIColor *shadowColor;

/** Left side menu view */
@property (nonatomic, strong) IBOutlet UIViewController *menuViewController;

/** Main View */
@property (nonatomic, strong) IBOutlet UIViewController *mainViewController;

/** When the menu is opened, a transparent button is displayed over the main view. This property gives the opportunity to modify it's accessibility label. */
@property (nonatomic, copy) NSString *closeOverlayAccessibilityLabel;

/** When the menu is opened, a transparent button is displayed over the main view. This property gives the opportunity to modify it's accessibility hint. */
@property (nonatomic, copy) NSString *closeOverlayAccessibilityHint;

/** Initializer that sets up a menuViewController and a mainViewController
 @param menuViewController The view controller to display in the left view
 @param mainViewController The view controller to display in the right view
 @return TWTMenuViewController A view that manages a menu view and opening/closing animations
 */
- (id)initWithMenuViewController:(UIViewController *)menuViewController mainViewController:(UIViewController *)mainViewController;

@end

@interface TWTSideMenuViewController (MenuActions)

/** Open the left side menu; animated or not
 @param animated Is the menu open action animated
 */
- (void)openMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

/** Close the left side menu; animated or not
 @param animated Is the menu close action animated
 */
- (void)closeMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

/** Toggle the state of the left side menu
 @param animated Is the toggle action animated
 */
- (void)toggleMenuAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end

@interface TWTSideMenuViewController (MainViewActions)

- (void)setMainViewController:(UIViewController *)mainViewController animated:(BOOL)animated closeMenu:(BOOL)closeMenu;

@end

@interface UIViewController (TWTSideMenuViewController)

@property (nonatomic, weak) TWTSideMenuViewController *sideMenuViewController;

@end

