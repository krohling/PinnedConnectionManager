//
//  PinnedConnectionManager.m
//
//  Created by Kevin Rohling on 11/6/14.
//

#import "PinnedConnectionManager.h"

@implementation PinnedConnectionManager

- (id) initWithRequest:(NSURLRequest *)request AcceptedCertificates:(NSArray *)acceptedCertificates completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))completionHandler {
    self = [super init];
    
    if (self) {
        self.acceptedCertificates = acceptedCertificates;
        self.completionHandler = completionHandler;
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
    
    return self;
}


- (void) start {
    [self.connection start];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.response = response;
    NSLog(@"Received Response");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"Received Data");
    if (self.responseData == nil) {
        self.responseData = [NSMutableData dataWithData:data];
    }
    else {
        [self.responseData appendData:data];
    }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection Failed");
    self.completionHandler(self.response, self.responseData, error);
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Connection Finished Loading");
    self.completionHandler(self.response, self.responseData, nil);
}

- (void) connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    BOOL certificateValidated = false;
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    
    if (self.acceptedCertificates) {
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
        NSData *remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
        
        for (NSData *acceptedCertificate in self.acceptedCertificates) {
            if ([remoteCertificateData isEqualToData:acceptedCertificate]) {
                certificateValidated = true;
                break;
            }
        }
        
    }
    
    if (!self.acceptedCertificates || certificateValidated) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
    else {
        NSLog(@"Failed SSL certificate validation");
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}



@end
