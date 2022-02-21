import Foundation

// MARK: - Network Errors

enum NetworkError: Error {
    case noConnectionError
}

extension NetworkError: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .noConnectionError:
            return NSLocalizedString(
                "There is no internet connection at the moment. Please reconnect or try again later.",
                comment: ""
            )
        }
    }
}

// MARK: - Account Errors

enum AccountError: Error {
    case invalidPassword
    case usernameNotFound
    case serverNotFound
    case invalidServerURL
    case couldNotSaveTokenToKeychain
    case couldNotFetchTokenFromKeychain
    case couldNotDeleteTokenFromKeychain
}

extension AccountError: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .serverNotFound:
            return NSLocalizedString(
                "The server could not be found. Please check the information you've entered and try again.",
                comment: ""
            )
        case .invalidPassword:
            return NSLocalizedString(
                "Invalid password. Please check that you've entered your password correctly and try logging in again.",
                comment: ""
            )
        case .usernameNotFound:
            return NSLocalizedString(
                "Username not found. Did you use your email address by mistake?",
                comment: ""
            )
        case .invalidServerURL:
            return NSLocalizedString(
                "Please enter a valid instance domain name. It should look like \"https://example.com\" or \"write.as\".",  // swiftlint:disable:this line_length
                comment: ""
            )
        case .couldNotSaveTokenToKeychain:
            return NSLocalizedString(
                "There was a problem trying to save your access token to the device, please try logging in again.",
                comment: ""
            )
        case .couldNotFetchTokenFromKeychain:
            return NSLocalizedString(
                "There was a problem trying to fetch your access token from the device, please try logging in again.",
                comment: ""
            )
        case .couldNotDeleteTokenFromKeychain:
            return NSLocalizedString(
                "There was a problem trying to delete your access token from the device, please try logging out again.",
                comment: ""
            )
        }
    }
}