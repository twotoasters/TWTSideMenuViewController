/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (Transform)
@property (nonatomic) CGFloat rotation;
@property (nonatomic) CGFloat xscale;
@property (nonatomic) CGFloat yscale;
@property (nonatomic) CGFloat tx;
@property (nonatomic) CGFloat ty;

@property (nonatomic, readonly) CGRect originalFrame;
@property (nonatomic, readonly) CGPoint originalCenter;

@property (nonatomic, readonly) CGPoint transformedTopLeft;
@property (nonatomic, readonly) CGPoint transformedTopRight;
@property (nonatomic, readonly) CGPoint transformedBottomLeft;
@property (nonatomic, readonly) CGPoint transformedBottomRight;

@property (nonatomic, readonly) NSString *transformDescription;

- (CGPoint) pointInTransformedView: (CGPoint) pointInParentCoordinates;
- (BOOL) intersectsView: (UIView *) aView;
@end
