//
//  HomeController.m
//  ios-tumblr-sdk
//
//  Created by Felipe Sabino on 4/21/11.
//  Copyright 2011 http://felipe.sabino.me . All rights reserved.
//

#import "HomeController.h"
#import "TumblrController.h"
#import <QuartzCore/QuartzCore.h>


@interface HomeController (Private)

-(void) buttonLoginTapped: (UIButton *) button;

@end


@implementation HomeController


-(void)loadView {
    
    [super loadView];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _txtfLogin = [[UITextField alloc] init];
    CGRect rect = CGRectNull;
    rect.origin.x = 20.0;
    rect.origin.y = 8.0;
    rect.size.width = 280.0;
    rect.size.height = 25.0;
    _txtfLogin.frame = rect;
    _txtfLogin.font = [UIFont systemFontOfSize:14.0];
    _txtfLogin.placeholder = @"Tumblr Email";
    _txtfLogin.secureTextEntry = NO;
    _txtfLogin.layer.cornerRadius = 5.0;
    _txtfLogin.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _txtfLogin.layer.borderWidth = 1.0;
//    txtfLogin.delegate = self; 
    
    [self.view addSubview:_txtfLogin];
    
    _txtfPass = [[UITextField alloc] init];
    rect.origin.x = 20.0;
    rect.origin.y = 40.0;
    rect.size.width = 280.0;
    rect.size.height = 25.0;
    _txtfPass.frame = rect;
    _txtfPass.font = [UIFont systemFontOfSize:14.0];
    _txtfPass.placeholder = @"Password";
    _txtfPass.secureTextEntry = YES;
    _txtfPass.layer.cornerRadius = 5.0;
    _txtfPass.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _txtfPass.layer.borderWidth = 1.0;
//    txtfPass.delegate = self;  

    [self.view addSubview:_txtfPass];
    
    _btnLogin = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    rect.origin.x = 20.0;
    rect.origin.y = 75.0;
    rect.size.width = 280.0;
    rect.size.height = 25.0;
    _btnLogin.frame = rect;
    [self.view addSubview:_btnLogin];
    [_btnLogin setTitle:@"Login" forState:UIControlStateNormal];
    [_btnLogin addTarget:self action:@selector(buttonLoginTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _tbTumblr = [[TumblrManager alloc] initWithDelegate:self];
    
}



#pragma - Events

-(void)buttonLoginTapped:(UIButton *)button {
    
    _btnLogin.enabled = NO;
    _btnLogin.alpha = 0.7;    
    [_tbTumblr authenticateWithEmail:_txtfLogin.text andPassword:_txtfPass.text];
    
}


#pragma - TumbleManagerDelegate

-(void)tumblrManager:(TumblrManager *)tumblrManager didReceivedAuthenticationInfo:(BOOL)userIsLogged {
    
    
    if (userIsLogged) {
        TumblrController *ctrl = [[TumblrController alloc] initWithEmail:_txtfLogin.text andPassword:_txtfPass.text];
        [self.navigationController pushViewController:ctrl animated:YES];
        [ctrl release];
        
        _txtfPass.text = @"";


    } else {
        
        NSLog(@"user is not logged");
        //nsalert
    }
    
    _btnLogin.enabled = YES;
    _btnLogin.alpha = 1.0;
}

#pragma - Memory

-(void)viewDidUnload {
    
    [_txtfLogin release], _txtfLogin = nil;
    [_txtfPass release], _txtfPass = nil;
    [_btnLogin release], _btnLogin = nil;
    
    [_tbTumblr release], _tbTumblr = nil;
    
    [super viewDidUnload];
    
    
}


-(void)dealloc {
    
    
    [_txtfLogin release];
    [_txtfPass release];
    [_btnLogin release];
    
    [_tbTumblr release];
    
    [super dealloc];
    
    
}

@end
