//
//  HomeController.h
//  ios-tumblr-sdk
//
//  Created by Felipe Sabino on 4/21/11.
//  Copyright 2011 http://felipe.sabino.me . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tumblr-sdk.h"

@interface HomeController : UIViewController <TumblrManagerDelegate> {
    
    UITextField *_txtfLogin;
    UITextField *_txtfPass;
    UIButton *_btnLogin;
    
    TumblrManager *_tbTumblr;
}

@end
