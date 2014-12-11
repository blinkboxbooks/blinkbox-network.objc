//
//  BBAKeyService.h
//  BBAAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBAUserDetails;

extern NSString *const BBAKeyServiceDomain;
extern NSString *const BBAKeyServiceName;

/**
 *  `BBAKeyService` is responsible for communication with the key service.
 */
@interface BBAKeyService : NSObject

/**
 *  Fetch a key (to extract a book) from the server.
 *
 *  @param keyURL     `NSURL` containing the key to fetch
 *  @param publicKey  `NSString` containing the public key sent to the server for encryption. This *must* be base64 encoded!
 *  @param user       `BBAUserDetails` for whom to fetch the key
 *  @param completion Completion handler called on success or fail of the service.
 */
- (void) getKeyForURL:(NSURL *)keyURL
            publicKey:(NSString *)publicKey
              forUser:(BBAUserDetails *)user
           completion:(void (^)(NSData *key, NSError *error))completion;
@end
