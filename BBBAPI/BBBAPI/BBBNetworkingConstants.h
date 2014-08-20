//
//  BBBNetworkingConstants.h
//  BBBNetworking
//
//  Created by Tomek Kuźma on 24/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#ifndef BBBNetworking_BBBNetworkingConstants_h
#define BBBNetworking_BBBNetworkingConstants_h

/** Supported HTTP methods */
typedef NS_ENUM(NSUInteger, BBBHTTPMethod) {
    BBBHTTPMethodGET,
    BBBHTTPMethodPOST,
    BBBHTTPMethodDELETE,
    BBBHTTPMethodPUT,
};

/** Supported content types */
typedef NS_ENUM(NSUInteger, BBBContentType) {
    BBBContentTypeURLEncodedForm,
    BBBContentTypeJSON,
};

#endif
