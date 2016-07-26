//
//  WebServiceHandler.m
//  WebServiceHandler-IOS
//
//  Created by Md Farhad Hossain on 4/18/16.
//  Copyright © 2016 Md Farhad Hossain All rights reserved.
//

#import "WebServiceHandler.h"

@implementation WebServiceHandler{
    NSData *myResponse;
    int myRequestCode;
    NSString *myURL;
    NSError *myError;
    NSURLSessionUploadTask *uploadTask;
    float progress;
}

@synthesize delegate;

-(void)makeHTTPGETRequest:(NSString *)urlString vars:(NSDictionary *)vars requestCode:(int) requestCode{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    
    NSMutableString *vars_str = [NSMutableString new];
    [vars_str appendString:urlString];
    if (vars != nil && vars.count > 0) {
        BOOL first = YES;
        [vars_str appendString:@"?"];
        for (NSString *key in vars) {
            if (!first) {
                [vars_str appendString:@"&"];
            }
            first = NO;
            
            [vars_str appendString:[self urlencode:key]];
            [vars_str appendString:@"="];
            [vars_str appendString:[self urlencode:[vars valueForKey:key]]];
        }
    }
    NSURL *url = [NSURL URLWithString:vars_str];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    NSLog(@"Request :%@",vars_str);
    NSURLSessionDataTask *getDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Response: %@",myString);
        myResponse=data;
        myRequestCode=requestCode;
        myError=error;
        myURL=urlString;
        [self performSelectorOnMainThread:@selector(finish) withObject:nil waitUntilDone:nil];
        
    }];
    
    [getDataTask resume];
    
}

-(void)makeHTTPPOSTRequest:(NSString *)urlString vars:(NSDictionary *)vars requestCode:(int) requestCode{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    
    NSMutableString *vars_str = [NSMutableString new];
    
    if (vars != nil && vars.count > 0) {
        BOOL first = YES;
        for (NSString *key in vars) {
            if (!first) {
                [vars_str appendString:@"&"];
            }
            first = NO;
            
            [vars_str appendString:[self urlencode:key]];
            [vars_str appendString:@"="];
            [vars_str appendString:[self urlencode:[vars valueForKey:key]]];
        }
    }
    [request setHTTPBody:[vars_str dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Response: %@",myString);
        myResponse=data;
        myRequestCode=requestCode;
        myError=error;
        myURL=urlString;
        [self performSelectorOnMainThread:@selector(finish) withObject:nil waitUntilDone:nil];
        
    }];
    
    [postDataTask resume];
    
}

-(void)finish{
    
    [delegate retriveFromWebServiceWithResponse:myResponse requestCode:(int) myRequestCode url:myURL andError:myError];
    
}

- (NSString *)urlencode:(NSString *)input {
    const char *input_c = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableString *result = [NSMutableString new];
    for (NSInteger i = 0, len = strlen(input_c); i < len; i++) {
        unsigned char c = input_c[i];
        if (
            (c >= '0' && c <= '9')
            || (c >= 'A' && c <= 'Z')
            || (c >= 'a' && c <= 'z')
            || c == '-' || c == '.' || c == '_' || c == '~'
            ) {
            [result appendFormat:@"%c", c];
        }
        else {
            [result appendFormat:@"%%%02X", c];
        }
    }
    return result;
}

#pragma mark -seesion data task delegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    // Upload progress
    progress=(float)totalBytesSent / totalBytesExpectedToSend;
    NSLog(@"Progress: %f",progress);
    [self performSelectorOnMainThread:@selector(updateProgress) withObject:nil waitUntilDone:nil];
}

-(void)updateProgress{
    [delegate onProgressUpdate:progress];
}
@end
