import Foundation

public enum SupabaseError: Error {
    case noData
    case decodingError(Error)
    case notAuthenticated
    case invalidParameters
    case serverError(Error)
    
    public var localizedDescription: String {
        switch self {
        case .noData:
            return "No data returned from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .notAuthenticated:
            return "User is not authenticated"
        case .invalidParameters:
            return "Invalid parameters provided"
        case .serverError(let error):
            return "Server error: \(error.localizedDescription)"
        }
    }
} 