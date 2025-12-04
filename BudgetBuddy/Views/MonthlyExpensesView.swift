import SwiftUI

struct MonthlyExpensesView: View {
    @ObservedObject var monthlyExpensesViewModel: MonthlyExpensesViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var authViewModel: AuthViewModel
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
                        // Title
                        VStack(spacing: 8) {
                            Text("Monthly Expenses")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Enter your average costs")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Error message
                        if let error = monthlyExpensesViewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 1, green: 0.9, blue: 0.9))
                                .cornerRadius(8)
                        }
                        
                        // ESSENTIALS Section
                        Text("ESSENTIALS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                            .tracking(0.5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Housing (Rent/Mortgage)
                        ExpenseField(label: "Housing (Rent/Mortgage)", icon: "house.fill", value: $monthlyExpensesViewModel.housing)
                        
                        // Transportation (Gas, Public Transit)
                        ExpenseField(label: "Transportation (Gas, Public Transit)", value: $monthlyExpensesViewModel.transportation)
                        
                        // Car Payment (Monthly Debt)
                        ExpenseField(label: "Car Payment (Monthly Debt)", value: $monthlyExpensesViewModel.carPayment)
                        
                        // Car Insurance
                        ExpenseField(label: "Car Insurance", value: $monthlyExpensesViewModel.carInsurance)
                        
                        // Car Maintenance & Parking
                        ExpenseField(label: "Car Maintenance & Parking", value: $monthlyExpensesViewModel.carMaintenance)
                        
                        // Groceries
                        ExpenseField(label: "Groceries", value: $monthlyExpensesViewModel.groceries)
                        
                        // LIFESTYLE Section
                        Text("LIFESTYLE")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                            .tracking(0.5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        
                        // Subscriptions (Netflix, Gym)
                        ExpenseField(label: "Subscriptions (Netflix, Gym)", value: $monthlyExpensesViewModel.subscriptions)
                        
                        // Other Expenses
                        ExpenseField(label: "Other Expenses", value: $monthlyExpensesViewModel.otherExpenses)
                        
                        // SAVINGS Section
                        Text("SAVINGS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                            .tracking(0.5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        
                        // Monthly Savings
                        ExpenseField(label: "Monthly Savings", value: $monthlyExpensesViewModel.savings)
                        
                        // Dependent Expenses (conditional)
                        if monthlyExpensesViewModel.showDependentExpenses {
                            ExpenseField(label: "Expense for Dependent", value: $monthlyExpensesViewModel.dependentExpenses)
                        }
                        
                        // See Your Budget button
                        Button(action: {
                            if let userId = authViewModel.currentUser?.id {
                                monthlyExpensesViewModel.saveExpenses(userId: userId)
                                if monthlyExpensesViewModel.errorMessage == nil {
                                    authViewModel.isAuthenticated = true
                                }
                            }
                        }) {
                            if monthlyExpensesViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("See Your Budget")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.white)
                        .background(Color(red: 0.15, green: 0.20, blue: 0.35))
                        .cornerRadius(16)
                        .disabled(monthlyExpensesViewModel.isLoading)
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                }
            }
        }
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                monthlyExpensesViewModel.loadExpenses(userId: userId)
                
                // Check if user has dependents
                if let profile = profileViewModel.userProfile,
                   let dependents = profile.numberOfDependents,
                   dependents > 0 {
                    monthlyExpensesViewModel.setShouldShowDependentExpenses(true)
                }
            }
        }
    }
}

// MARK: - ExpenseField Component
struct ExpenseField: View {
    let label: String
    var icon: String = ""
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            
            HStack {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                }
                
                Text("$")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                
                TextField("0.00", text: $value)
                    .keyboardType(.decimalPad)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
            )
        }
    }
}

#Preview {
    MonthlyExpensesView(
        monthlyExpensesViewModel: MonthlyExpensesViewModel(),
        profileViewModel: ProfileViewModel(),
        authViewModel: AuthViewModel()
    )
}
