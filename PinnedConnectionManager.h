//
//  PinnedConnectionManager.h
//
//  Created by Kevin Rohling on 11/6/14.
//

#import <Foundation/Foundation.h>

@interface PinnedConnectionManager : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSArray *acceptedCertificates;
@property (strong, nonatomic) NSURLResponse *response;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) void ( ^ completionHandler)( NSURLResponse *urlResponse, NSData *data, NSError *error );

- (id) initWithRequest: (NSURLRequest *) request AcceptedCertificates: (NSArray *) acceptedCertificates completionHandler:( void ( ^ )( NSURLResponse *urlResponse, NSData *data, NSError *error ) ) completionHandler;

- (void) start;

@end
