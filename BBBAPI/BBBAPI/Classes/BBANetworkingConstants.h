//
//  BBANetworkingConstants.h
//  BBANetworking
//
//  Created by Tomek Kuźma on 24/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#ifndef BBANetworking_BBANetworkingConstants_h
#define BBANetworking_BBANetworkingConstants_h

/** Supported HTTP methods */
typedef NS_ENUM(NSUInteger, BBAHTTPMethod) {
    BBAHTTPMethodGET = 0,
    BBAHTTPMethodPOST = 1,
    BBAHTTPMethodDELETE = 2,
    BBAHTTPMethodPUT = 3,
};

/** Supported content types */
typedef NS_ENUM(NSUInteger, BBAContentType) {
    BBAContentTypeUnknown = -1,
    BBAContentTypeURLEncodedForm = 0,
    BBAContentTypeJSON = 1,
};

#endif