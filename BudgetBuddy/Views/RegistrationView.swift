import SwiftUI

struct RegistrationView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var showPassword = false
    @FocusState private var focusedField: TextFieldFocus?
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
                        
                        Text("Create an account")
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
                        
                        // First name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First name")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("Enter your first name", text: $firstName)
                                .autocapitalization(.words)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                                )
                                .focused($focusedField, equals: .firstName)
                                .textFieldNextButton(focus: $focusedField, currentField: .firstName, nextField: .lastName)
                        }
                        
                        // Last name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last name")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("Enter your last name", text: $lastName)
                                .autocapitalization(.words)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                                )
                                .focused($focusedField, equals: .lastName)
                                .textFieldNextButton(focus: $focusedField, currentField: .lastName, nextField: .email)
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
                                .focused($focusedField, equals: .email)
                                .textFieldNextButton(focus: $focusedField, currentField: .email, nextField: .password)
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            HStack {
                                if showPassword {
                                    TextField("Enter your password", text: $password)
                                        .textContentType(.newPassword)
                                        .focused($focusedField, equals: .password)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                        .textContentType(.newPassword)
                                        .focused($focusedField, equals: .password)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                }
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                            )
                            .textFieldNextButton(focus: $focusedField, currentField: .password, nextField: nil)
                        }
                        
                        // Create Account button
                        Button(action: {
                            viewModel.registerWithEmail(
                                email: email,
                                password: password,
                                firstName: firstName,
                                lastName: lastName
                            )
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.white)
                        .background(Color(red: 0.15, green: 0.20, blue: 0.35))
                        .cornerRadius(16)
                        .disabled(viewModel.isLoading)
                        
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
    RegistrationView(viewModel: AuthViewModel())
}
