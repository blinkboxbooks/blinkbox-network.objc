//
//  BBBAPIErrors.h
//  BBBAPI
//
//  Created by Owen Worley on 11/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

NS_ENUM(NSInteger, BBBAPIError) {
    /**
     *  Used when needed parameter is not supplied to the method
     *  or when object is supplied but it has wrong type or 
     *  for example one of it's needed properties is not set
     */
    BBBAPIWrongUsage = 700,
    /**
     *  Error returned when for any reason API call cannot connect to the server
     */
    BBBAPIErrorCouldNotConnect = 701,
    /**
     *  Returned when call cannot be authenticated, or when server returns 401
     */
    BBBAPIErrorUnauthorised = 702,
    /**
     *  Used when server cannot find a resource and returns 404
     */
    BBBAPIErrorNotFound = 703,
    /**
     *  Used when server returns 500
     */
    BBBAPIServerError = 704,
    /**
     *  Used when server returns 403
     */
    BBBAPIErrorForbidden = 705,
    /**
     *  Used when we cannot decode or read data returned from the server
     */
    BBBAPIUnreadableData = 706,
};

