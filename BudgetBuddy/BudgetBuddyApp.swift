//
//  BudgetBuddyApp.swift
//  BudgetBuddy
//
//  Created by Artem Popovych on 11/27/25.
//

import SwiftUI

@main
struct BudgetBuddyApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var monthlyExpensesViewModel = MonthlyExpensesViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                HomeView(
                    authViewModel: authViewModel,
                    profileViewModel: profileViewModel,
                    monthlyExpensesViewModel: monthlyExpensesViewModel
                )
            } else if authViewModel.showProfileSetup {
                ProfileSetupView(
                    profileViewModel: profileViewModel,
                    authViewModel: authViewModel
                )
            } else {
                WelcomeScreenView(authViewModel: authViewModel)
            }
        }
    }
}
