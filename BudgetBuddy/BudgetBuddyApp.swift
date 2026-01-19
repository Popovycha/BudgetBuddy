//
//  BudgetBuddyApp.swift
//  BudgetBuddy
//
//  Created by Artem Popovych on 11/27/25.
//

import SwiftUI
import Supabase

@main
struct BudgetBuddyApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var monthlyExpensesViewModel = MonthlyExpensesViewModel()
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://stawhbhqkcstsmqjkquz.supabase.co")!,
        supabaseKey: "sb_publishable_me9hrng2DpDHGeNBMHsdTw_R-0eyDKN"
    )
    
    var body: some Scene {
        WindowGroup {
            ZStack {
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
}
