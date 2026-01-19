import Foundation
import Combine
import Supabase
import AuthenticationServices

class AuthViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var showProfileSetup = false
    @Published var showEmailVerification = false
    
    private var cancellables = Set<AnyCancellable>()
    private let storageService = LocalStorageService.shared
    
    private lazy var supabase = SupabaseClient(
        supabaseURL: URL(string: "https://stawhbhqkcstsmqjkquz.supabase.co")!,
        supabaseKey: "sb_publishable_me9hrng2DpDHGeNBMHsdTw_R-0eyDKN"
    )
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
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
                let userId = session.user.id.uuidString
                
                print("🔐 Login successful, userId: \(userId)")
                
                // Try to fetch user profile from Supabase
                do {
                    let response = try await supabase
                        .from("users")
                        .select()
                        .eq("id", value: userId)
                        .execute()
                    
                    print("📦 Users response status: \(response.status)")
                    if let responseString = String(data: response.data, encoding: .utf8) {
                        print("📦 Users response data: \(responseString)")
                    }
                    
                    let decoder = JSONDecoder()
                    let usersArray = try decoder.decode([[String: String]].self, from: response.data)
                    print("📦 Decoded users array count: \(usersArray.count)")
                    
                    if let userData = usersArray.first {
                        var firstName = (userData["first_name"] ?? "User").trimmingCharacters(in: .whitespacesAndNewlines)
                        var lastName = (userData["last_name"] ?? "Name").trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        // Remove any backticks or special characters
                        firstName = firstName.filter { $0.isLetter || $0.isWhitespace }
                        lastName = lastName.filter { $0.isLetter || $0.isWhitespace }
                        
                        print("✅ User found: \(firstName) \(lastName)")
                        
                        DispatchQueue.main.async {
                            self.currentUser = User(
                                id: userId,
                                email: email,
                                firstName: firstName,
                                lastName: lastName,
                                authProvider: .email
                            )
                            self.storageService.saveUser(self.currentUser!)
                            self.isAuthenticated = true
                            self.isLoading = false
                        }
                    } else {
                        // If query returns empty, use default names
                        print("⚠️ No user data found, using defaults")
                        DispatchQueue.main.async {
                            self.currentUser = User(
                                id: userId,
                                email: email,
                                firstName: "User",
                                lastName: "Name",
                                authProvider: .email
                            )
                            self.storageService.saveUser(self.currentUser!)
                            self.isAuthenticated = true
                            self.isLoading = false
                        }
                    }
                } catch {
                    // If query fails, still allow login with default names
                    print("⚠️ Failed to fetch user data: \(error), using defaults")
                    DispatchQueue.main.async {
                        self.currentUser = User(
                            id: userId,
                            email: email,
                            firstName: "User",
                            lastName: "Name",
                            authProvider: .email
                        )
                        self.storageService.saveUser(self.currentUser!)
                        self.isAuthenticated = true
                        self.isLoading = false
                    }
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
                            print("💾 Saving user to Supabase:")
                            print("  - userId: \(userId)")
                            print("  - firstName: \(firstName)")
                            print("  - lastName: \(lastName)")
                            print("  - email: \(email)")
                            
                            try await self.supabase
                                .from("users")
                                .insert([
                                    "id": userId,
                                    "first_name": firstName,
                                    "last_name": lastName,
                                    "email": email,
                                    "created_at": ISO8601DateFormatter().string(from: Date())
                                ])
                                .execute()
                            
                            print("✅ User saved to Supabase successfully")
                        } catch {
                            print("❌ Error saving user to Supabase: \(error)")
                        }
                    }
                    
                    // Proceed to profile setup
                    self.isAuthenticated = false
                    self.showProfileSetup = true
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
        showProfileSetup = false
        storageService.deleteCurrentUser()
    }
}
