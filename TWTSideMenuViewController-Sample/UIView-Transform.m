/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIView-Transform.h"
@implementation UIView (Transform)

CGAffineTransform makeTransform(CGFloat xScale, CGFloat yScale, CGFloat theta, CGFloat tx, CGFloat ty)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform.a = xScale * cos(theta);
    transform.b = yScale * sin(theta);
    transform.c = xScale * -sin(theta);
    transform.d = yScale * cos(theta);
    transform.tx = tx;
    transform.ty = ty;

    return transform;
}

- (CGFloat) xscale
{
    CGAffineTransform t = self.transform;
    return sqrt(t.a * t.a + t.c * t.c);
}

- (void) setXscale: (CGFloat) xScale
{
    self.transform = makeTransform(xScale, self.yscale, self.rotation, self.tx, self.ty);
}

- (CGFloat) yscale
{
    CGAffineTransform t = self.transform;
    return sqrt(t.b * t.b + t.d * t.d);
}

- (void) setYscale: (CGFloat) yScale
{
    self.transform = makeTransform(self.xscale, yScale, self.rotation, self.tx, self.ty);
}


- (CGFloat) rotation
{
    CGAffineTransform t = self.transform;
    return atan2f(t.b, t.a); 
}

- (void) setRotation: (CGFloat) theta
{
    self.transform = makeTransform(self.xscale, self.yscale, theta, self.tx, self.ty);
}


- (CGFloat) tx
{
    CGAffineTransform t = self.transform;
    return t.tx;
}

- (void) setTx:(CGFloat)tx
{
    self.transform = makeTransform(self.xscale, self.yscale, self.rotation, tx, self.ty);
}

- (CGFloat) ty
{
    CGAffineTransform t = self.transform;
    return t.ty;
}

- (void) setTy:(CGFloat)ty
{
    self.transform = makeTransform(self.xscale, self.yscale, self.rotation, self.tx, ty);
}

- (CGPoint) offsetPointToParentCoordinates: (CGPoint) aPoint
{
    return CGPointMake(aPoint.x + self.center.x, aPoint.y + self.center.y);
}

- (CGPoint) pointInViewCenterTerms: (CGPoint) aPoint
{
    return CGPointMake(aPoint.x - self.center.x, aPoint.y - self.center.y);
}

- (CGPoint) pointInTransformedView: (CGPoint) aPoint
{
    CGPoint offsetItem = [self pointInViewCenterTerms:aPoint];
    CGPoint updatedItem = CGPointApplyAffineTransform(offsetItem, self.transform);
    CGPoint finalItem = [self offsetPointToParentCoordinates:updatedItem];
    
    return finalItem;
}

- (CGRect) originalFrame
{
    CGAffineTransform currentTransform = self.transform;
    self.transform = CGAffineTransformIdentity;
    CGRect originalFrame = self.frame;
    self.transform = currentTransform;
    
    return originalFrame;
}

- (CGPoint) originalCenter
{
    CGAffineTransform currentTransform = self.transform;
    self.transform = CGAffineTransformIdentity;
    CGPoint originalCenter = self.center;
    self.transform = currentTransform;
    
    return originalCenter;
}

- (NSString *) transformDescription
{
    NSMutableString *descriptionString = [NSMutableString string];
    
    [descriptionString appendFormat:@"Frame: %@; ", NSStringFromCGRect(self.originalFrame)];
    [descriptionString appendFormat:@"Transformed Frame: %@; ", NSStringFromCGRect(self.frame)];
    [descriptionString appendFormat:@"Scale: [%0.5f, %0.5f]; ", self.xscale, self.yscale];
    [descriptionString appendFormat:@"Rotation: [%0.5f]; ", self.rotation];
    [descriptionString appendFormat:@"Translation: [%0.5f, %0.5f]; ", self.tx, self.ty];
    [descriptionString appendFormat:@"Transform: %@", CGAffineTransformIsIdentity(self.transform) ? @"Identity" : NSStringFromCGAffineTransform(self.transform)];

    return descriptionString;
}

- (CGPoint) transformedTopLeft
{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    return [self pointInTransformedView:point];
}

- (CGPoint) transformedTopRight
{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    return [self pointInTransformedView:point];
}

- (CGPoint) transformedBottomRight
{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    point.y += frame.size.height;
    return [self pointInTransformedView:point];
}

- (CGPoint) transformedBottomLeft
{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    point.y += frame.size.height;
    return [self pointInTransformedView:point];
}

BOOL halfPlane(CGPoint p1, CGPoint p2, CGPoint testPoint)
{
    CGPoint base = CGPointMake(p2.x - p1.x, p2.y - p1.y);
    CGPoint orthog = CGPointMake(-base.y, base.x);
    return (((orthog.x * (testPoint.x - p1.x)) + (orthog.y * (testPoint.y - p1.y))) >= 0);
}

BOOL intersectionTest(CGPoint p1, CGPoint p2, UIView *aView)
{
    BOOL tlTest = halfPlane(p1, p2, aView.transformedTopLeft);
    BOOL trTest = halfPlane(p1, p2, aView.transformedTopRight);
    if (tlTest != trTest) return YES;
    
    BOOL brTest = halfPlane(p1, p2, aView.transformedBottomRight);
    if (tlTest != brTest) return YES;
    
    BOOL blTest = halfPlane(p1, p2, aView.transformedBottomLeft);
    if (tlTest != blTest) return YES;
    
    return NO;
}

- (BOOL) intersectsView: (UIView *) aView
{
    if (!CGRectIntersectsRect(self.frame, aView.frame)) return NO;

    CGPoint A = self.transformedTopLeft;
    CGPoint B = self.transformedTopRight;
    CGPoint C = self.transformedBottomRight;
    CGPoint D = self.transformedBottomLeft;
    
    if (!intersectionTest(A, B, aView))
    {
        BOOL test = halfPlane(A, B, aView.transformedTopLeft);
        BOOL t1 = halfPlane(A, B, C);
        BOOL t2 = halfPlane(A, B, D);
        if ((t1 != test) && (t2 != test)) return NO;
    }
    
    if (!intersectionTest(B, C, aView))
    {
        BOOL test = halfPlane(B, C, aView.transformedTopLeft);
        BOOL t1 = halfPlane(B, C, A);
        BOOL t2 = halfPlane(B, C, D);
        if ((t1 != test) && (t2 != test)) return NO;
    }

    if (!intersectionTest(C, D, aView))
    {
        BOOL test = halfPlane(C, D, aView.transformedTopLeft);
        BOOL t1 = halfPlane(C, D, A);
        BOOL t2 = halfPlane(C, D, B);
        if ((t1 != test) && (t2 != test)) return NO;
    }
    
    if (!intersectionTest(D, A, aView))
    {
        BOOL test = halfPlane(D, A, aView.transformedTopLeft);
        BOOL t1 = halfPlane(D, A, B);
        BOOL t2 = halfPlane(D, A, C);
        if ((t1 != test) && (t2 != test)) return NO;
    }
    
    A = aView.transformedTopLeft;
    B = aView.transformedTopRight;
    C = aView.transformedBottomRight;
    D = aView.transformedBottomLeft;
    
    if (!intersectionTest(A, B, self))
    {
        BOOL test = halfPlane(A, B, self.transformedTopLeft);
        BOOL t1 = halfPlane(A, B, C);
        BOOL t2 = halfPlane(A, B, D);
        if ((t1 != test) && (t2 != test)) return NO;
    }
    
    if (!intersectionTest(B, C, self))
    {
        BOOL test = halfPlane(B, C, self.transformedTopLeft);
        BOOL t1 = halfPlane(B, C, A);
        BOOL t2 = halfPlane(B, C, D);
        if ((t1 != test) && (t2 != test)) return NO;
    }
    
    if (!intersectionTest(C, D, self))
    {
        BOOL test = halfPlane(C, D, self.transformedTopLeft);
        BOOL t1 = halfPlane(C, D, A);
        BOOL t2 = halfPlane(C, D, B);
        if ((t1 != test) && (t2 != test)) return NO;
    }
    
    if (!intersectionTest(D, A, self))
    {
        BOOL test = halfPlane(D, A, self.transformedTopLeft);
        BOOL t1 = halfPlane(D, A, B);
        BOOL t2 = halfPlane(D, A, C);
        if ((t1 != test) && (t2 != test)) return NO;
    }    
    
    return YES;
    
}
@end
