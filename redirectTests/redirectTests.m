//
//  redirectTests.m
//  redirectTests
//
//  Created by Matthias Wessendorf on 8/21/13.
//  Copyright (c) 2013 Red Hat. All rights reserved.
//

#import "redirectTests.h"
#import <AFNetworking/AFNetworking.h>

@implementation redirectTests {
    BOOL _finished;
    AFHTTPClient *_client;
}

- (void)setUp
{
    [super setUp];
    
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)testHTTP
{
    // http ....
    _client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://secure-pushee.rhcloud.com/ag-push"]];
    _client.parameterEncoding = AFJSONParameterEncoding;
    
    // apply HTTP Basic:
    [_client setAuthorizationHeaderWithUsername:@"608acb1c-96b7-47a7-9663-ac9eb8781e04"
                                       password:@"0ad0ee26-5f54-4224-9739-41d67e21c3b0"];
    
    NSMutableURLRequest *request = [_client requestWithMethod:@"POST"
                                                         path:@"rest/registry/device"
                                                   parameters:@{@"deviceToken": @"122343223"}];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSLog(@"Success!");
        
        _finished = YES;
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR: %@", error);
        
        _finished = YES;
    }];
    
    [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *req, NSURLResponse *redirectResponse) {
        
        if (redirectResponse != nil) {  // we got HTTP-302 redirection
            
            // NOTE:
            //      As per Apple doc the req is 'the proposed redirected request'. But we cannot return it as it is. The reason is user-agents (and in our case NSUrlconnection) 'erroneous' after a 302-redirection modify the request http method to GET if the client performs a POST (as we do here). What we do here is to use the original request with just updating the URL to the new redirected one.
            
            // update URL of the original request
            // to the 'new' redirected one
            request.URL = req.URL;
            
            // return the original request
            return request;
        }
        
        return request;
    }];
    
    [_client enqueueHTTPRequestOperation:operation];
    
    while(!_finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (void)testHTTPs
{
    
    // http ....
    _client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://secure-pushee.rhcloud.com/ag-push"]];
    _client.parameterEncoding = AFJSONParameterEncoding;
    
    // apply HTTP Basic:
    [_client setAuthorizationHeaderWithUsername:@"608acb1c-96b7-47a7-9663-ac9eb8781e04" password:@"0ad0ee26-5f54-4224-9739-41d67e21c3b0"];
    
    
    [_client postPath:@"rest/registry/device" parameters:@{@"deviceToken": @"122343223"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success!");
        _finished = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    
    while(!_finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
}

@end
