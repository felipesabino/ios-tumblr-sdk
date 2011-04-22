//
//  TumblrController.h
//  ios-tumblr-sdk
//
//  Created by Felipe Sabino on 4/21/11.
//  Copyright 2011 http://felipe.sabino.me . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tumblr-sdk.h"


@interface TumblrController : UITableViewController <TumblrManagerDelegate, UIAlertViewDelegate> {
    
    TumblrManager *_tbTumblr;
    NSMutableArray *_arrData;
    
}

-(id) initWithEmail: (NSString *) email andPassword: (NSString *)password;

@end
