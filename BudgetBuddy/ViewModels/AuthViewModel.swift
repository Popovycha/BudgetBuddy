import Foundation
import Combine
import Supabase

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var showProfileSetup = false
    
    private var cancellables = Set<AnyCancellable>()
    private let storageService = LocalStorageService.shared
    
    private lazy var supabase = SupabaseClient(
        supabaseURL: URL(string: "https://stawhbhqkcstsmqjkquz.supabase.co")!,
        supabaseKey: "sb_publishable_me9hrng2DpDHGeNBMHsdTw_R-0eyDKN"
    )
    
    // MARK: - Authentication Methods
    
    func loginWithEmail(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        if email.isEmpty || password.isEmpty {
            self.errorMessage = "Email and password are required"
            self.isLoading = false
            return
        } else if !email.contains("@") {
            self.errorMessage = "Invalid email format"
            self.isLoading = false
            return
        }
        
        Task {
            do {
                let session = try await supabase.auth.signIn(email: email, password: password)
                
                DispatchQueue.main.async {
                    self.currentUser = User(
                        id: session.user.id.uuidString,
                        email: email,
                        firstName: "User",
                        lastName: "Name",
                        authProvider: .email
                    )
                    self.isAuthenticated = true
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
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
        
        if email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty {
            self.errorMessage = "All fields are required"
            self.isLoading = false
            return
        } else if !email.contains("@") {
            self.errorMessage = "Invalid email format"
            self.isLoading = false
            return
        } else if password.count < 6 {
            self.errorMessage = "Password must be at least 6 characters"
            self.isLoading = false
            return
        }
        
        Task {
            do {
                let session = try await supabase.auth.signUp(email: email, password: password)
                
                let userId = session.user.id.uuidString
                
                let newUser = User(
                    id: userId,
                    email: email,
                    firstName: firstName,
                    lastName: lastName,
                    authProvider: .email
                )
                
                DispatchQueue.main.async {
                    self.currentUser = newUser
                    self.storageService.saveUser(newUser)
                    
                    // Save user profile to Supabase
                    Task {
                        do {
                            try await self.supabase.database
                                .from("users")
                                .insert([
                                    "id": userId,
                                    "first_name": firstName,
                                    "last_name": lastName,
                                    "email": email,
                                    "created_at": ISO8601DateFormatter().string(from: Date())
                                ])
                                .execute()
                        } catch {
                            print("Error saving profile to Supabase: \(error)")
                        }
                    }
                    
                    // Check if profile exists, if not show profile setup
                    if !self.storageService.profileExists(userId: userId) {
                        self.showProfileSetup = true
                    } else {
                        self.isAuthenticated = true
                    }
                    
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Registration failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
        errorMessage = nil
    }
}
