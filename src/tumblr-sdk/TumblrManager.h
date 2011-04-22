//
//  TumblrManager.h
//  ios-tumblr-sdk
//
//  Created by Felipe Sabino on 4/21/11.
//  Copyright 2011 http://felipe.sabino.me . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"

//text, quote, photo, link, chat, video, or audio
typedef enum _tumblrPostType {
    TumblrPostTypeText,
    TumblrPostTypeQuote,
	TumblrPostTypePhoto,
    TumblrPostTypeLink,
    TumblrPostTypeChat,
    TumblrPostTypeVideo,
    TumblrPostTypeAudio,
    TumblrPostTypeAll,
} TumblrPostType;


typedef enum _tumblrFilterType {
    
    TumblrFilterTypeHtml,
    TumblrFilterTypeText,
    TumblrFilterTypeNone,    
} TumblrFilterType;


@class TumblrManager;

@protocol TumblrManagerDelegate <NSObject>

@optional
-(void) tumblrManager: (TumblrManager *)tumblrManager didReceiveDashboadData: (NSArray *)data;
-(void) tumblrManagerErrorRequestingDashboadData: (TumblrManager *)tumblrManager;
-(void) tumblrManager: (TumblrManager *)tumblrManager didReceivedAuthenticationInfo: (BOOL) userIsLogged;
-(void) tumblrManagerErrorRequestingAuthenticationInfo: (TumblrManager *)tumblrManager;


@end

@interface TumblrManager : NSObject {
    
    NSMutableArray *_arrConnections;
    CFMutableDictionaryRef _cfdicConnectionData;
    CFMutableDictionaryRef _cfdicConnectionApiCall;
    
    NSDictionary *_dicParams;    
    
    NSString *_strEmail;
    NSString *_strPassword;
    
}

@property (nonatomic, readonly) id<TumblrManagerDelegate> delegate;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *password;

/**
 @brief Return JSON representation (or fragment) for the given object.
 
 Returns a string containing JSON representation of the passed in value, or nil on error.
 If nil is returned and @p error is not NULL, @p *error can be interrogated to find the cause of the error.
 
 @param value any instance that can be represented as a JSON fragment
 **/
-(id) initWithDelegate: (id<TumblrManagerDelegate>) delegate;
-(id) initWithDelegate: (id<TumblrManagerDelegate>) delegate email: (NSString *) email andPassword: (NSString *) password;

#pragma - API Calls

-(void) authenticate;
-(void) authenticateWithEmail: (NSString *) email andPassword: (NSString *) password;

-(void) requestDashboard: (TumblrPostType) type;
-(void) requestDashboard: (TumblrPostType) type atPage:(int) page andNumberOfRecordsPerPage: (int) rpp;
-(void) requestDashboard: (TumblrPostType) type atPage:(int) page andNumberOfRecordsPerPage: (int) rpp filtered: (TumblrFilterType) filter;


@end
