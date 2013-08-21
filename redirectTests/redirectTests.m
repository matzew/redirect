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

- (void)testHTTPModified
{
    
    // http ....
    _client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://secure-pushee.rhcloud.com/ag-push"]];
    _client.parameterEncoding = AFJSONParameterEncoding;
    
    // apply HTTP Basic:
    [_client setAuthorizationHeaderWithUsername:@"608acb1c-96b7-47a7-9663-ac9eb8781e04" password:@"0ad0ee26-5f54-4224-9739-41d67e21c3b0"];
    
    NSMutableURLRequest *request = [_client requestWithMethod:@"POST" path:@"rest/registry/device" parameters:@{@"deviceToken": @"122343223"}];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        NSLog(@"Success!");
        _finished = YES;
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR: %@", error);
        _finished = YES;
        
        // this fails, due to a '405' response code;
        // on the server (http access log) I see a GET is issued against:
        // http://secure-pushee.rhcloud.com/ag-push/rest/registry/device
        
        // However we are submitting a POST..... A post with CURL against the 'http' returns the expected 302 code...
        
        STFail(@"%@", error);
    }];
    
    [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *req, NSURLResponse *redirectResponse) {

        if (redirectResponse != nil) {
            request.URL = req.URL;
            
            return request;
        }

        return request;
    }];
    
    
    [_client enqueueHTTPRequestOperation:operation];
    
    
    while(!_finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
}

/*
- (void)testHTTP
{
    
    // http ....
    _client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://secure-pushee.rhcloud.com/ag-push"]];
    _client.parameterEncoding = AFJSONParameterEncoding;
    
    // apply HTTP Basic:
    [_client setAuthorizationHeaderWithUsername:@"608acb1c-96b7-47a7-9663-ac9eb8781e04" password:@"0ad0ee26-5f54-4224-9739-41d67e21c3b0"];
    
    
    [_client postPath:@"rest/registry/device" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success!");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
        _finished = YES;
        
        
        // this fails, due to a '405' response code;
        // on the server (http access log) I see a GET is issued against:
        // http://secure-pushee.rhcloud.com/ag-push/rest/registry/device
        
        // However we are submitting a POST..... A post with CURL against the 'http' returns the expected 302 code...
        
        STFail(@"%@", error);
        
    }];
    
    
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

- (void) testZSometingHttps {
    
    NSURL *url = [NSURL URLWithString:@"http://secure-pushee.rhcloud.com/ag-push"];//rest/registry/device"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"rest/registry/device" parameters:@{@"deviceToken": @"122343223"}];
    
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             NSLog(@"\n\nSUCCESS\n\n");
                                             
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {

                                             _finished = YES;

                                             // this fails, due to a '405' response code;
                                             // on the server (http access log) I see a GET is issued against:
                                             // http://secure-pushee.rhcloud.com/ag-push/rest/registry/device

                                             // However we are submitting a POST..... A post with CURL against the 'http' returns the expected 302 code...

                                             STFail(@"%@", error);

                                         }];
    
    [operation start];
    while(!_finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
}
*/
@end
