import SwiftUI

struct EditExpensesView: View {
    @ObservedObject var monthlyExpensesViewModel: MonthlyExpensesViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    
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
                        
                        Text("Edit Expenses")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(action: {
                            if let userId = authViewModel.currentUser?.id {
                                monthlyExpensesViewModel.saveExpenses(userId: userId)
                                if monthlyExpensesViewModel.errorMessage == nil {
                                    isPresented = false
                                }
                            }
                        }) {
                            Text("Save")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    
                    ScrollView {
                        VStack(spacing: 20) {
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
                            
                            ExpenseField(label: "Housing (Rent/Mortgage)", icon: "house.fill", value: $monthlyExpensesViewModel.housing)
                            ExpenseField(label: "Transportation (Gas, Public Transit)", value: $monthlyExpensesViewModel.transportation)
                            ExpenseField(label: "Car Payment (Monthly Debt)", value: $monthlyExpensesViewModel.carPayment)
                            ExpenseField(label: "Car Insurance", value: $monthlyExpensesViewModel.carInsurance)
                            ExpenseField(label: "Car Maintenance & Parking", value: $monthlyExpensesViewModel.carMaintenance)
                            ExpenseField(label: "Groceries", value: $monthlyExpensesViewModel.groceries)
                            
                            // LIFESTYLE Section
                            Text("LIFESTYLE")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                .tracking(0.5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                            
                            ExpenseField(label: "Subscriptions (Netflix, Gym)", value: $monthlyExpensesViewModel.subscriptions)
                            ExpenseField(label: "Other Expenses", value: $monthlyExpensesViewModel.otherExpenses)
                            
                            // SAVINGS Section
                            Text("SAVINGS")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                .tracking(0.5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                            
                            ExpenseField(label: "Monthly Savings", value: $monthlyExpensesViewModel.savings)
                            
                            Spacer()
                                .frame(height: 20)
                        }
                        .padding(20)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    EditExpensesView(
        monthlyExpensesViewModel: MonthlyExpensesViewModel(),
        authViewModel: AuthViewModel(),
        isPresented: .constant(true)
    )
}
