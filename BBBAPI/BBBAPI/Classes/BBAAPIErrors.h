//
//  BBAAPIErrors.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 11/08/2014.
 

NS_ENUM(NSInteger, BBAAPIError) {
    /**
     *  Used when needed parameter is not supplied to the method
     *  or when object is supplied but it has wrong type or 
     *  for example one of it's needed properties is not set
     */
    BBAAPIWrongUsage = 700,
    /**
     *  Error returned when for any reason API call cannot connect to the server
     */
    BBAAPIErrorCouldNotConnect = 701,
    /**
     *  Returned when call cannot be authenticated, or when server returns 401
     */
    BBAAPIErrorUnauthorised = 702,
    /**
     *  Used when server cannot find a resource and returns 404
     */
    BBAAPIErrorNotFound = 703,
    /**
     *  Used when server returns 500
     */
    BBAAPIServerError = 704,
    /**
     *  Used when server returns 403
     */
    BBAAPIErrorForbidden = 705,
    /**
     *  Used when we cannot decode or read data returned from the server
     */
    BBAAPIUnreadableData = 706,
    /**
     *  Used when the server returns a 400 (Bad Request)
     */
    BBAAPIErrorBadRequest = 707,
    /**
     *  Used when the server returns a 409 (Conflict)
     */
    BBAAPIErrorConflict = 708,
};

