//
//  WebServiceHandler.h
//  WebServiceHandler-IOS 
//
//  Created by Md Farhad Hossain on 4/18/16.
//  Copyright © 2016 Md Farhad Hossain rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark protocol
@protocol WebServiceDelegate
@required
-(void)retriveFromWebServiceWithResponse:(NSData *) response requestCode:(int) requestCode url:(NSString *) url andError:(NSError *) error;
@optional
-(void)onProgressUpdate:(float) progress;
@end
#pragma end

@interface WebServiceHandler : NSObject<NSURLSessionTaskDelegate>{
    id <NSObject, WebServiceDelegate > delegate;
}
@property (retain) id <NSObject, WebServiceDelegate > delegate;


-(void)makeHTTPGETRequest:(NSString *)urlString vars:(NSDictionary *)vars requestCode:(int) requestCode;

-(void)makeHTTPPOSTRequest:(NSString *)urlString vars:(NSDictionary *)vars requestCode:(int) requestCode;

@end
