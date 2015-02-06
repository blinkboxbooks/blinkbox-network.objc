//
//  BBANetworkingConstants.h
//  BBANetworking
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 24/07/2014.
 

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
    /**
     *  Used in the key service which expects unecoded value but 'encoded' header
     */
    BBAContentTypeURLUnencodedForm = 2,
};

#endif
