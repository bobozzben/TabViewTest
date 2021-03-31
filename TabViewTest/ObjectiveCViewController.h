//
//  ObjectiveCViewController.h
//  TabViewTest
//
//  Created by Ben_Mac on 2020/11/5.
//  Copyright © 2020 Ben_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjectiveCViewController : UIViewController {
    int intValue ;
    NSString *stringValue;
}
@property (strong, nonatomic) NSString *goString;

@end

NS_ASSUME_NONNULL_END
