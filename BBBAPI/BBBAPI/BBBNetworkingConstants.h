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
    BBBHTTPMethodGET = 0,
    BBBHTTPMethodPOST = 1,
    BBBHTTPMethodDELETE = 2,
    BBBHTTPMethodPUT = 3,
};

/** Supported content types */
typedef NS_ENUM(NSUInteger, BBBContentType) {
    BBBContentTypeUnknown = -1,
    BBBContentTypeURLEncodedForm = 0,
    BBBContentTypeJSON = 1,
};

#endif
