import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.93, blue: 0.91)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .navigationBarBackButtonHidden(true)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Logo
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.98, green: 0.92, blue: 0.90))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "banknote")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                        }
                        .padding(.bottom, 16)
                        
                        // Title
                        Text("The Budget Buddy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Login to your account")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                        
                        // Error message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 1, green: 0.9, blue: 0.9))
                                .cornerRadius(8)
                        }
                        
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email address")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("Enter your email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                                )
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            SecureField("Enter your password", text: $password)
                                .textContentType(.password)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                                )
                        }
                        
                        // Sign In button
                        Button(action: {
                            viewModel.loginWithEmail(email: email, password: password)
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.white)
                        .background(Color(red: 0.15, green: 0.20, blue: 0.35))
                        .cornerRadius(16)
                        .disabled(viewModel.isLoading)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(red: 0.90, green: 0.85, blue: 0.82))
                            
                            Text("or")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(red: 0.90, green: 0.85, blue: 0.82))
                        }
                        
                        // Social login buttons
                        VStack(spacing: 12) {
                            // Google button
                            Button(action: {
                                viewModel.loginWithGoogle()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "g.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                    
                                    Text("Continue with Google")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .padding(.horizontal, 12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                                )
                            }
                            .disabled(viewModel.isLoading)
                            
                            // Facebook button
                            Button(action: {
                                viewModel.loginWithFacebook()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "f.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                    
                                    Text("Continue with Facebook")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .padding(.horizontal, 12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                                )
                            }
                            .disabled(viewModel.isLoading)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                }
            }
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
