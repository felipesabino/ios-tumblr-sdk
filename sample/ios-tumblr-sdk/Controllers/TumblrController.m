//
//  TumblrController.m
//  ios-tumblr-sdk
//
//  Created by Felipe Sabino on 4/21/11.
//  Copyright 2011 http://felipe.sabino.me . All rights reserved.
//

#import "TumblrController.h"


@implementation TumblrController


-(id)initWithEmail:(NSString *)email andPassword:(NSString *)password {
    
    self = [super init];
    
    if (self) {
        _tbTumblr =[[TumblrManager alloc] initWithDelegate:self email:email andPassword:password];
        _arrData = [[NSMutableArray alloc] init];
        
        self.tableView.rowHeight = 50.0;
    }
    
    return self;    
    
}

-(void)loadView {
    
    [super loadView];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

//    [_tbTumblr requestDashboard:TumblrPostTypeQuote atPage:1 andNumberOfRecordsPerPage:40 filtered:TumblrFilterTypeText];
    [_tbTumblr requestPage:@"beautiful-quotes" forType:TumblrPostTypeQuote withSearch:nil atPage:1 andNumberOfRecordsPerPage:50 filtered:TumblrFilterTypeText];
    
}

#pragma - TumblrManagerDelegate

-(void)tumblrManager:(TumblrManager *)tumblrManager didReceiveDashboadData:(NSArray *)data {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [_arrData addObjectsFromArray:data];
    [self.tableView reloadData];
    
}


-(void)tumblrManagerErrorRequestingDashboadData:(TumblrManager *)tumblrManager {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    UIAlertView *alvwError = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error getting dashboard data" delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
    
    
    [alvwError show];
    [alvwError release];

    
}

#pragma - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//        [_tbTumblr requestDashboard:TumblrPostTypeQuote atPage:1 andNumberOfRecordsPerPage:40 filtered:TumblrFilterTypeText];
        [_tbTumblr requestPage:@"beautiful-quotes" forType:TumblrPostTypeQuote withSearch:nil atPage:1 andNumberOfRecordsPerPage:50 filtered:TumblrFilterTypeText];

    }
    
}

#pragma - TableView Delegate and Datasource


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_arrData count];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    NSString *strCellIdentifier = @"Cell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strCellIdentifier];
    
    if (!cell){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellIdentifier];
        
    }
    
    NSDictionary *dicItem = [_arrData objectAtIndex:indexPath.row];
    [cell.textLabel setText:[dicItem objectForKey:@"quote-text"]];

    return cell;
    
}


#pragma - Memory

-(void)dealloc {
    
    [_arrData release];
    
    [super dealloc];
    
    
}
@end
