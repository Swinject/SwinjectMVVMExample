//
//  NetworkError.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Foundation

public enum NetworkError: ErrorType, CustomStringConvertible {
    /// Unknown or not supported error.
    case Unknown

    /// Not connected to the internet.
    case NotConnectedToInternet

    /// International data roaming turned off.
    case InternationalRoamingOff

    /// Cannot reach the server.
    case NotReachedServer

    /// Connection is lost.
    case ConnectionLost

    /// Incorrect data returned from the server.
    case IncorrectDataReturned

    internal init(error: NSError) {
        if error.domain == NSURLErrorDomain {
            switch error.code {
            case NSURLErrorUnknown:
                self = .Unknown
            case NSURLErrorCancelled:
                self = .Unknown // Cancellation is not used in this project.
            case NSURLErrorBadURL:
                self = .IncorrectDataReturned // Because it is caused by a bad URL returned in a JSON response from the server.
            case NSURLErrorTimedOut:
                self = .NotReachedServer
            case NSURLErrorUnsupportedURL:
                self = .IncorrectDataReturned
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                self = .NotReachedServer
            case NSURLErrorDataLengthExceedsMaximum:
                self = .IncorrectDataReturned
            case NSURLErrorNetworkConnectionLost:
                self = .ConnectionLost
            case NSURLErrorDNSLookupFailed:
                self = .NotReachedServer
            case NSURLErrorHTTPTooManyRedirects:
                self = .Unknown
            case NSURLErrorResourceUnavailable:
                self = .IncorrectDataReturned
            case NSURLErrorNotConnectedToInternet:
                self = .NotConnectedToInternet
            case NSURLErrorRedirectToNonExistentLocation, NSURLErrorBadServerResponse:
                self = .IncorrectDataReturned
            case NSURLErrorUserCancelledAuthentication, NSURLErrorUserAuthenticationRequired:
                self = .Unknown
            case NSURLErrorZeroByteResource, NSURLErrorCannotDecodeRawData, NSURLErrorCannotDecodeContentData:
                self = .IncorrectDataReturned
            case NSURLErrorCannotParseResponse:
                self = .IncorrectDataReturned
            case NSURLErrorInternationalRoamingOff:
                self = .InternationalRoamingOff
            case NSURLErrorCallIsActive, NSURLErrorDataNotAllowed, NSURLErrorRequestBodyStreamExhausted:
                self = .Unknown
            case NSURLErrorFileDoesNotExist, NSURLErrorFileIsDirectory:
                self = .IncorrectDataReturned
            case
            NSURLErrorNoPermissionsToReadFile,
            NSURLErrorSecureConnectionFailed,
            NSURLErrorServerCertificateHasBadDate,
            NSURLErrorServerCertificateUntrusted,
            NSURLErrorServerCertificateHasUnknownRoot,
            NSURLErrorServerCertificateNotYetValid,
            NSURLErrorClientCertificateRejected,
            NSURLErrorClientCertificateRequired,
            NSURLErrorCannotLoadFromNetwork,
            NSURLErrorCannotCreateFile,
            NSURLErrorCannotOpenFile,
            NSURLErrorCannotCloseFile,
            NSURLErrorCannotWriteToFile,
            NSURLErrorCannotRemoveFile,
            NSURLErrorCannotMoveFile,
            NSURLErrorDownloadDecodingFailedMidStream,
            NSURLErrorDownloadDecodingFailedToComplete:
                self = .Unknown
            default:
                self = .Unknown
            }
        }
        else {
            self = .Unknown
        }
    }
    
    public var description: String {
        let text: String
        switch self {
        case Unknown:
            text = "Unknown error occurred. Check internet connection and try again."
        case NotConnectedToInternet:
            text = "Not connected to the internet. Turn on Wi-Fi, or allow cellular data connection."
        case InternationalRoamingOff:
            text = "International roaming is not allowed. Change the international roaming setting, or turn on Wi-Fi."
        case NotReachedServer:
            text = "Could not reach the Pixabay server. Check the internet connection, or wait until the server becomes accessible."
        case ConnectionLost:
            text = "Internet connection is lost. Move to a location where more stable connection is available, or wait until the connection returns to be stable."
        case IncorrectDataReturned:
            text = "Incorrect data returned from Pixabay server. Try again, or wait until Pixabay fixes the problem."
        }
        return text
    }
}
