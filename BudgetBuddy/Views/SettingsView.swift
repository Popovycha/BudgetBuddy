import SwiftUI

struct SettingsView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @Binding var isPresented: Bool
    
    @State private var isEditingProfile = false
    @State private var showSignOutAlert = false
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.93, blue: 0.91)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                .padding(16)
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // User Profile Card
                        HStack(spacing: 12) {
                            Text("U")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color(red: 0.95, green: 0.70, blue: 0.65))
                                .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(authViewModel.currentUser?.firstName ?? "User")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                Text("No location set")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        
                        // Edit Profile Button
                        Button(action: { isEditingProfile = true }) {
                            Text("Edit Profile")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .foregroundColor(.white)
                                .background(Color(red: 0.95, green: 0.70, blue: 0.65))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 16)
                        
                        // Data Sync Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DATA SYNC")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "icloud.and.arrow.up.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(red: 0.45, green: 0.65, blue: 1.0))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Sync to Cloud")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                        
                                        Text("Currently data is stored locally. To implement cloud sync, we recommend connecting this app to Google Firebase or Supabase for real-time secure storage.")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 0.45, green: 0.65, blue: 1.0))
                                            .lineLimit(nil)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .padding(12)
                            .background(Color(red: 0.93, green: 0.96, blue: 1.0))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 16)
                        
                        // App Access Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("APP ACCESS")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "hammer.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Developer Native Build")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red: 0.45, green: 0.85, blue: 0.45))
                                    
                                    Text("App is ready/installed")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(red: 0.45, green: 0.85, blue: 0.45))
                                }
                                .padding(.top, 8)
                            }
                            .padding(12)
                            .background(Color(red: 0.98, green: 0.96, blue: 0.94))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 16)
                        
                        // Close Button
                        Button(action: { showSignOutAlert = true }) {
                            Text("Close")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .foregroundColor(Color(red: 0.85, green: 0.35, blue: 0.35))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .sheet(isPresented: $isEditingProfile) {
            EditProfileView(
                authViewModel: authViewModel,
                profileViewModel: profileViewModel,
                isPresented: $isEditingProfile
            )
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @Binding var isPresented: Bool
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var dateOfBirth = Date()
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.93, blue: 0.91)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Text("Edit Profile")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(action: saveProfile) {
                            Text("Save")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                        }
                        .disabled(isSaving)
                    }
                    .padding(16)
                    .background(Color.white)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            // First Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("First Name")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                
                                TextField("First Name", text: $firstName)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .font(.system(size: 14))
                            }
                            
                            // Last Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Last Name")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                
                                TextField("Last Name", text: $lastName)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .font(.system(size: 14))
                            }
                            
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                
                                TextField("Email", text: $email)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .font(.system(size: 14))
                                    .keyboardType(.emailAddress)
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                
                                SecureField("Password", text: $password)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .font(.system(size: 14))
                            }
                            
                            // Date of Birth
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date of Birth")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                
                                DatePicker("DOB", selection: $dateOfBirth, displayedComponents: .date)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .font(.system(size: 14))
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            loadCurrentProfile()
        }
    }
    
    private func loadCurrentProfile() {
        firstName = authViewModel.currentUser?.firstName ?? ""
        lastName = authViewModel.currentUser?.lastName ?? ""
        email = authViewModel.currentUser?.email ?? ""
    }
    
    private func saveProfile() {
        isSaving = true
        
        // Update auth view model
        // Note: In a real app, you'd update the backend here
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSaving = false
            isPresented = false
        }
    }
}

#Preview {
    SettingsView(
        authViewModel: AuthViewModel(),
        profileViewModel: ProfileViewModel(),
        isPresented: .constant(true)
    )
}
