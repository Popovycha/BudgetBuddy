import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var showProfileSetup = false
    
    private var cancellables = Set<AnyCancellable>()
    private let storageService = LocalStorageService.shared
    
    // MARK: - Authentication Methods
    
    func loginWithEmail(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // TODO: Replace with actual API call
            if email.isEmpty || password.isEmpty {
                self.errorMessage = "Email and password are required"
            } else if !email.contains("@") {
                self.errorMessage = "Invalid email format"
            } else {
                // Mock successful login
                self.currentUser = User(
                    id: UUID().uuidString,
                    email: email,
                    firstName: "User",
                    lastName: "Name",
                    authProvider: .email
                )
                self.isAuthenticated = true
            }
            self.isLoading = false
        }
    }
    
    func loginWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement Google Sign-In
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.currentUser = User(
                id: UUID().uuidString,
                email: "user@gmail.com",
                firstName: "Google",
                lastName: "User",
                authProvider: .google
            )
            self.isAuthenticated = true
            self.isLoading = false
        }
    }
    
    func loginWithFacebook() {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement Facebook Sign-In
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.currentUser = User(
                id: UUID().uuidString,
                email: "user@facebook.com",
                firstName: "Facebook",
                lastName: "User",
                authProvider: .facebook
            )
            self.isAuthenticated = true
            self.isLoading = false
        }
    }
    
    func registerWithEmail(email: String, password: String, firstName: String, lastName: String) {
        isLoading = true
        errorMessage = nil
        
        // TODO: Replace with actual API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty {
                self.errorMessage = "All fields are required"
            } else if !email.contains("@") {
                self.errorMessage = "Invalid email format"
            } else if password.count < 6 {
                self.errorMessage = "Password must be at least 6 characters"
            } else {
                let newUser = User(
                    id: UUID().uuidString,
                    email: email,
                    firstName: firstName,
                    lastName: lastName,
                    authProvider: .email
                )
                self.currentUser = newUser
                self.storageService.saveUser(newUser)
                
                // Check if profile exists, if not show profile setup
                if !self.storageService.profileExists(userId: newUser.id) {
                    self.showProfileSetup = true
                } else {
                    self.isAuthenticated = true
                }
            }
            self.isLoading = false
        }
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
        errorMessage = nil
    }
}
