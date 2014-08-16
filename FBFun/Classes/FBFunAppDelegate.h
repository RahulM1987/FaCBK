//
//  FBFunAppDelegate.h
//  FBFun
//
//  Created by Ray Wenderlich on 7/13/10.
//  Copyright Ray Wenderlich 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBFunViewController;

@interface FBFunAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    FBFunViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FBFunViewController *viewController;

@end

