import Foundation

struct User: Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let authProvider: AuthProvider
    
    enum AuthProvider: String, Codable {
        case email
        case google
        case facebook
    }
}

struct AuthResponse: Codable {
    let user: User
    let token: String
}
