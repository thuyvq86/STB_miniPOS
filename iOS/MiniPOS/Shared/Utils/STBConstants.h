//
//  STBConstants.h
//  MiniPOS
//
//  Created by Nam Nguyen on 10/16/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

/**
 * Components
 */
#define DEFAULT_ANIMATION_DURATION 0.2f
#define MINIMUM_ANIMATION_DURATION 0.1f

#define DEFAULT_CORNER_RADIUS   4.0f
#define TABLEVIEW_CORNER_RADIUS 5.0f
#define DEFAULT_SHADOW_RADIUS   2.0f
#define DEFAULT_SHADOW_OPACITY  0.5f

static CGFloat const kStatusBarHeight     = 20.0f;
static CGFloat const kNavigationBarHeight = 44.0f;
static CGFloat const kToolbarHeight       = 44.0f;
static CGFloat const kTableCellHeight     = 44.0f;

static CGFloat const kButtonHeight        = 30.0f;
static CGFloat const kButtonWidth         = 100.0f;

/**
 * Enums
 */

//accessing a screen from a menu
typedef enum Open_Style{
    OpenStylePopup = 0,
    OpenStyleSlide = 1
}OpenStyle;

//List of HTTP status codes
typedef enum {
    StatusCodeNoInternet                  = -1,
    StatusCodeUnknown                     = 0,
    StatusCodeOkNotExpiredFromCache       = 10,
    StatusCodeOk                          = 200,
    StatusCodeCreated                     = 201,
    StatusCodeAccepted                    = 202,
    StatusCodeNonAuthorativeInformation   = 203,
    StatusCodeNoContent                   = 204,
    StatusCodeResetContent                = 205,
    StatusCodePartialContent              = 206,
    StatusCodeMovedPermanently            = 301,
    StatusCodeFound                       = 302,
    StatusCodeSeeOther                    = 303,
    StatusCodeNotModified                 = 304,
    StatusCodeUseProxy                    = 305,
    StatusCodeTemporaryRedirect           = 307,
    StatusCodeBadRequest                  = 400,
    StatusCodeNotAuthorized               = 401,
    StatusCodePaymentRequired             = 402,
    StatusCodeForbidden                   = 403,
    StatusCodeNotFound                    = 404,
    StatusCodeMethodNotAllowed            = 405,
    StatusCodeNotAcceptable               = 406,
    StatusCodeProxyAuthenticationRequired = 407,
    StatusCodeRequestTimeout              = 408,
    StatusCodeConflict                    = 409,
    StatusCodeGone                        = 410,
    StatusCodeLengthRequired              = 411,
    StatusCodePreconditionFailed          = 412,
    StatusCodeRequestEntityTooLarge       = 413,
    StatusCodeRequestUriTooLong           = 414,
    StatusCodeUnsupportedMediaType        = 415,
    StatusCodeRequestRangeNotSatisfiable  = 416,
    StatusCodeExpectationFailed           = 417,
    StatusCodeInternalServerError         = 500,
    StatusCodeNotImplemented              = 501,
    StatusCodeBadGateway                  = 502,
    StatusCodeServiceNotAvailable         = 503,
    StatusCodeGatewayTimeOut              = 504,
    StatusCodeHttpVersionNotSupported     = 505,
    StatusCodeClientError                 = 1000
} HTTPStatusCode;