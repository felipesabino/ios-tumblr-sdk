//
//  TumblrManager.m
//  ios-tumblr-sdk
//
//  Created by Felipe Sabino on 4/21/11.
//  Copyright 2011 http://felipe.sabino.me . All rights reserved.
//

#import "TumblrManager.h"

typedef enum _tumblrApiCall {
    
    TumblrApiCallAuthentication,
    TumblrApiCallDashboard,
} TumblrApiCall;


@interface TumblrManager (Private)

-(NSDictionary *) parseTumblrJavascriptJSON: (NSString *)json;
-(NSString *) getTypeString: (TumblrPostType) type;
-(NSString *) getFilterString: (TumblrFilterType) filter;

@end


@implementation TumblrManager

@synthesize delegate = _delegate;
@synthesize email = _strEmail;
@synthesize password = _strPassword;



-(id) initWithDelegate: (id<TumblrManagerDelegate>) delegate email: (NSString *) email andPassword: (NSString *) password {
    
    self = [self initWithDelegate:delegate];
    
    if (self) {
        self.email = email;
        self.password = password;
    }
    
    return self;
}

-(id) initWithDelegate: (id<TumblrManagerDelegate>) delegate {
    
    self = [super self];
    
    if (self) {
        
        _delegate = delegate;
        _arrConnections = [[NSMutableArray alloc] init];
        
        //using CFDictionary as NSURLConnection can't be used as key in a NSMutableArray
        //reference: http://stackoverflow.com/questions/332276/managing-multiple-asynchronous-nsurlconnection-connections
        
        _cfdicConnectionData = CFDictionaryCreateMutable(
                                       kCFAllocatorDefault,
                                       0,
                                       &kCFTypeDictionaryKeyCallBacks,
                                       &kCFTypeDictionaryValueCallBacks);
        
        _cfdicConnectionApiCall = CFDictionaryCreateMutable(
                                                         kCFAllocatorDefault,
                                                         0,
                                                         &kCFTypeDictionaryKeyCallBacks,
                                                         &kCFTypeDictionaryValueCallBacks);
        
        //get api params from plist
        NSString *path = [[NSBundle mainBundle] pathForResource:@"tumblr-sdk" ofType:@"plist"];
        _dicParams = [[NSDictionary dictionaryWithContentsOfFile:path] retain];       
        
    }
    
    return self;
}

#pragma - Private Methods


//Parse tumblr json string response and return a array representing data
-(NSDictionary *) parseTumblrJavascriptJSON: (NSString *)json {
    
    
    //remove "var tumblr_api_read = " from beginning of response;
    json = [json substringFromIndex:22];
    
    //remove ";" at end of string
    json = [json substringToIndex:[json length] - 2];
        
    return [[(NSDictionary *)[json JSONValue] retain] autorelease];
    
}

//get the type string to use at the api call
-(NSString *)getTypeString:(TumblrPostType)type {
    
    switch (type) {
        case TumblrPostTypeText:
            return @"text";
            break;
        case TumblrPostTypeQuote:
            return @"quote";
            break;
        case TumblrPostTypePhoto:
            return @"photo";
            break;
        case TumblrPostTypeLink:
            return @"link";
            break;
        case TumblrPostTypeChat:
            return @"chat";
            break;
        case TumblrPostTypeVideo:
            return @"video";
            break;
        case TumblrPostTypeAudio:
            return @"audio";
            break;
        default:
            return nil;
            break;
    }
    
}

//get the filter string to use at the api call
-(NSString *)getFilterString:(TumblrFilterType)filter {
    
    switch (filter) {
        case TumblrFilterTypeText:
            return @"text";
            break;
        case TumblrFilterTypeNone:
            return @"none";
            break;
        default:
            return nil;
            break;
    }
    
}

#pragma - API calls

-(void)authenticate {
    
    [self authenticateWithEmail:_strEmail andPassword:_strPassword];
    
}

-(void) authenticateWithEmail: (NSString *) email andPassword: (NSString *) password {
    
    //format url
    NSString *strUrl = [_dicParams objectForKey:@"url_authenticate"];
    
    //request
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //format request authentication
    NSString *strPostParams = [NSString stringWithFormat:@"email=%@&password=%@", 
                               [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                               [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    

    [request setHTTPBody:[strPostParams dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];

    //inits connection
    [_delegate retain];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [_arrConnections addObject:connection];
    
}


-(void) requestDashboard: (TumblrPostType) type {
    
    [self requestDashboard:type atPage:1 andNumberOfRecordsPerPage:20 filtered:TumblrFilterTypeHtml];
    
}

-(void) requestDashboard: (TumblrPostType) type atPage:(int) page andNumberOfRecordsPerPage: (int) rpp {
    
    [self requestDashboard:type atPage:page andNumberOfRecordsPerPage:rpp filtered:TumblrFilterTypeHtml];
}


-(void) requestDashboard: (TumblrPostType) type atPage:(int) page andNumberOfRecordsPerPage: (int) rpp filtered: (TumblrFilterType) filter {    

    //format url
    NSString *strUrl = [_dicParams objectForKey:@"url_dashboard"];
    
    //request
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //format request authentication
    NSString *strPostParams = [NSString stringWithFormat:@"email=%@&password=%@", 
                               [_strEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                               [_strPassword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    //format request type of data to be returned
    NSString *strType = [self getTypeString:type];
    if (strType) {
        strPostParams = [strPostParams stringByAppendingFormat:@"&type=%@", strType];
    }
    
    //format request number of pages and total records per page
    int start = page * rpp;
    strPostParams = [strPostParams stringByAppendingFormat:@"&start=%d&num=%d", start, rpp];
    
    //format request filter
    if (filter != TumblrFilterTypeHtml) {
        strPostParams = [strPostParams stringByAppendingFormat:@"&filter=%@", [self getFilterString:filter]];
    }
    
    
    [request setHTTPBody:[strPostParams dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
       
    //inits connection
    [_delegate retain];
    
    
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    //set dictionary with api call types as all connections goes to the same delegate method call
    CFDictionaryAddValue(_cfdicConnectionApiCall, connection, [NSNumber numberWithInt:TumblrApiCallDashboard]);

    [_arrConnections addObject:connection];
    
}


#pragma - Connection Delegates

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSMutableData *dataToAppend = (NSMutableData *)CFDictionaryGetValue(_cfdicConnectionData, connection);
    
    if (!dataToAppend) {
        dataToAppend = [[NSMutableData alloc] init];
        
        CFDictionaryAddValue(_cfdicConnectionData,
                             connection,
                             dataToAppend);      
        
    }
    
    [dataToAppend appendData:data];    
    
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    
    NSNumber *nbApiCall = (NSNumber *)CFDictionaryGetValue(_cfdicConnectionApiCall, connection);
    TumblrApiCall tacApiCall = (TumblrApiCall)[nbApiCall intValue];

    if (tacApiCall == TumblrApiCallDashboard) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(tumblrManagerErrorRequestingDashboadData::)]) {
            [_delegate tumblrManagerErrorRequestingDashboadData:self];
        }

    } else if (tacApiCall == TumblrApiCallAuthentication) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(tumblrManagerErrorRequestingAuthenticationInfo:)]) {
            [_delegate tumblrManagerErrorRequestingAuthenticationInfo:self];
        }

    }    
    
    //remove nsdata from connection data dictionary
    NSMutableData *data = (NSMutableData *)CFDictionaryGetValue(_cfdicConnectionData, connection);
    CFDictionaryRemoveValue(_cfdicConnectionData, connection);
    [data release];
    
    //remve api call type from dictionary
    CFDictionaryRemoveValue(_cfdicConnectionApiCall, connection);
    
    //remove connection from array of connections
    [_arrConnections removeObject:connection]; 
    [connection release];

    [_delegate release];
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSMutableData *data = (NSMutableData *)CFDictionaryGetValue(_cfdicConnectionData, connection);
    NSNumber *nbApiCall = (NSNumber *)CFDictionaryGetValue(_cfdicConnectionApiCall, connection);
    TumblrApiCall tacApiCall = (TumblrApiCall)[nbApiCall intValue];

    NSString *strResponse = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    
    if (tacApiCall == TumblrApiCallDashboard) {
        BOOL bError = NO;
        NSArray *arrResponse;
        
        @try {
            NSDictionary *dicResponse = [self parseTumblrJavascriptJSON:strResponse];
            
            arrResponse = [[dicResponse objectForKey:@"posts"] retain];
            
            if (!arrResponse) {
                [NSException raise:@"Error getting dashboard data" format:nil];
            }
            
        }
        @catch (NSException *exception) {

            bError = YES;
            
            if (_delegate && [_delegate respondsToSelector:@selector(tumblrManagerErrorRequestingDashboadData:)]) {
                [_delegate tumblrManagerErrorRequestingDashboadData:self];
            }
            
        }
        @finally {
            
            if (!bError) {
                if (_delegate && [_delegate respondsToSelector:@selector(tumblrManager:didReceiveDashboadData:)]) {
                    [_delegate tumblrManager:self didReceiveDashboadData:arrResponse];
                }
            }
            
            [arrResponse release];
        }
        
    } else if (tacApiCall == TumblrApiCallAuthentication) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(tumblrManager:didReceivedAuthenticationInfo:)]) {
            
            if ([[strResponse substringToIndex:14] isEqualToString:@"<?xml version="]) { 
                //TODO: fix this if; I've done this because I was too lazy to parse the xml and tumblr auth does not return any XML if auth fails, it returns just "Invalid credentials." AND besides that, there is no way of calling auth method with a json response... 
                [_delegate tumblrManager:self didReceivedAuthenticationInfo:YES];
            } else {
                [_delegate tumblrManager:self didReceivedAuthenticationInfo:NO];
            }
        }
        
    }
    

    //remove nsdata from connection data dictionary
    CFDictionaryRemoveValue(_cfdicConnectionData, connection);
    [data release];
    
    //remve api call type from dictionary
    CFDictionaryRemoveValue(_cfdicConnectionApiCall, connection);
    
    //remove connection from array of connections
    [_arrConnections removeObject:connection]; 
    [connection release];
    
    [_delegate release];
}

#pragma - Memory

-(void)dealloc {
    
    self.email = nil;
    self.password = nil;
    [_dicParams release], _dicParams = nil;
    [_arrConnections release], _arrConnections = nil;
    CFRelease(_cfdicConnectionData);
    CFRelease(_cfdicConnectionApiCall);
        
    [super dealloc];
    
}

@end
