//
//  ContentView.swift
//  BudgetBuddy
//
//  Created by Artem Popovych on 11/27/25.
//

import SwiftUI

struct WelcomeScreenView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showLoginView = false
    @State private var showRegistrationView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.93, blue: 0.91)
                    .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top padding
                Spacer()
                    .frame(height: 40)
                
                // Logo with background circle
                ZStack {
                    Circle()
                        .fill(Color(red: 0.98, green: 0.92, blue: 0.90))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "banknote")
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                }
                .padding(.bottom, 32)
                
                // Title
                Text("The Budget Buddy")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.bottom, 16)
                
                // Subtitle
                Text("Struggling to manage your finances?")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.bottom, 24)
                
                // Description texts
                VStack(spacing: 16) {
                    Text("Many people find it challenging to track expenses and stay within budget.")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                    
                    Text("Our simple budget planner will guide you through creating a personalized plan in just a few minutes.")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
                
                Spacer()
                
                // Buttons at bottom
                VStack(spacing: 12) {
                    NavigationLink(destination: LoginView(viewModel: authViewModel)) {
                        Text("Log In")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0.15, green: 0.20, blue: 0.35))
                            .cornerRadius(16)
                    }
                    
                    NavigationLink(destination: RegistrationView(viewModel: authViewModel)) {
                        Text("Create Account")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    WelcomeScreenView(authViewModel: AuthViewModel())
}
