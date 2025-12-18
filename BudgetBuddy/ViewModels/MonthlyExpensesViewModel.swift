import Foundation
import Combine

class MonthlyExpensesViewModel: ObservableObject {
    @Published var monthlyExpenses: MonthlyExpenses?
    
    // Essentials
    @Published var housing: String = ""
    @Published var transportation: String = ""
    @Published var carPayment: String = ""
    @Published var carInsurance: String = ""
    @Published var carMaintenance: String = ""
    @Published var groceries: String = ""
    
    // Lifestyle
    @Published var subscriptions: String = ""
    @Published var otherExpenses: String = ""
    
    // Savings
    @Published var savings: String = ""
    
    // Dependents
    @Published var dependentExpenses: String = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showDependentExpenses = false
    
    private let storageService = LocalStorageService.shared
    
    func loadExpenses(userId: String) {
        if let expenses = storageService.getMonthlyExpenses(userId: userId) {
            self.monthlyExpenses = expenses
            self.housing = String(expenses.housing ?? 0)
            self.transportation = String(expenses.transportation ?? 0)
            self.carPayment = String(expenses.carPayment ?? 0)
            self.carInsurance = String(expenses.carInsurance ?? 0)
            self.carMaintenance = String(expenses.carMaintenance ?? 0)
            self.groceries = String(expenses.groceries ?? 0)
            self.subscriptions = String(expenses.subscriptions ?? 0)
            self.otherExpenses = String(expenses.otherExpenses ?? 0)
            self.savings = String(expenses.savings ?? 0)
            self.dependentExpenses = String(expenses.dependentExpenses ?? 0)
        } else {
            self.monthlyExpenses = MonthlyExpenses(userId: userId)
        }
    }
    
    func setShouldShowDependentExpenses(_ show: Bool) {
        self.showDependentExpenses = show
        if !show {
            self.dependentExpenses = ""
        }
    }
    
    func saveExpenses(userId: String) {
        isLoading = true
        errorMessage = nil
        
        // Validate housing
        guard !housing.isEmpty, let housingAmount = Double(housing), housingAmount >= 0 else {
            errorMessage = "Please enter a valid housing expense"
            isLoading = false
            return
        }
        
        // Validate transportation
        guard !transportation.isEmpty, let transportAmount = Double(transportation), transportAmount >= 0 else {
            errorMessage = "Please enter a valid transportation expense"
            isLoading = false
            return
        }
        
        // Validate car payment
        guard !carPayment.isEmpty, let carPaymentAmount = Double(carPayment), carPaymentAmount >= 0 else {
            errorMessage = "Please enter a valid car payment"
            isLoading = false
            return
        }
        
        // Validate car insurance
        guard !carInsurance.isEmpty, let carInsuranceAmount = Double(carInsurance), carInsuranceAmount >= 0 else {
            errorMessage = "Please enter a valid car insurance amount"
            isLoading = false
            return
        }
        
        // Validate car maintenance
        guard !carMaintenance.isEmpty, let carMaintenanceAmount = Double(carMaintenance), carMaintenanceAmount >= 0 else {
            errorMessage = "Please enter a valid car maintenance amount"
            isLoading = false
            return
        }
        
        // Validate groceries
        guard !groceries.isEmpty, let groceriesAmount = Double(groceries), groceriesAmount >= 0 else {
            errorMessage = "Please enter a valid groceries expense"
            isLoading = false
            return
        }
        
        // Validate subscriptions
        guard !subscriptions.isEmpty, let subscriptionsAmount = Double(subscriptions), subscriptionsAmount >= 0 else {
            errorMessage = "Please enter a valid subscriptions expense"
            isLoading = false
            return
        }
        
        // Validate other expenses
        guard !otherExpenses.isEmpty, let otherAmount = Double(otherExpenses), otherAmount >= 0 else {
            errorMessage = "Please enter a valid other expenses amount"
            isLoading = false
            return
        }
        
        // Validate savings
        guard !savings.isEmpty, let savingsAmount = Double(savings), savingsAmount >= 0 else {
            errorMessage = "Please enter a valid savings amount"
            isLoading = false
            return
        }
        
        // Validate dependent expenses if shown
        var dependentAmount: Double? = nil
        if showDependentExpenses {
            guard !dependentExpenses.isEmpty, let depAmount = Double(dependentExpenses), depAmount >= 0 else {
                errorMessage = "Please enter a valid dependent expense"
                isLoading = false
                return
            }
            dependentAmount = depAmount
        }
        
        // Create or update expenses
        var expenses = monthlyExpenses ?? MonthlyExpenses(userId: userId)
        expenses.housing = housingAmount
        expenses.transportation = transportAmount
        expenses.carPayment = carPaymentAmount
        expenses.carInsurance = carInsuranceAmount
        expenses.carMaintenance = carMaintenanceAmount
        expenses.groceries = groceriesAmount
        expenses.subscriptions = subscriptionsAmount
        expenses.otherExpenses = otherAmount
        expenses.savings = savingsAmount
        expenses.dependentExpenses = dependentAmount
        expenses.updatedAt = Date()
        
        // Save to local storage
        storageService.saveMonthlyExpenses(expenses)
        self.monthlyExpenses = expenses
        
        // Save to Supabase
        // Always try to insert first, if it fails (duplicate key), then update
        SupabaseService.shared.saveMonthlyExpenses(
            userId: userId,
            housing: housingAmount,
            transportation: transportAmount,
            carPayment: carPaymentAmount,
            carInsurance: carInsuranceAmount,
            carMaintenance: carMaintenanceAmount,
            groceries: groceriesAmount,
            subscriptions: subscriptionsAmount,
            otherExpenses: otherAmount,
            savings: savingsAmount,
            dependentExpenses: dependentAmount ?? 0
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Expenses saved to Supabase successfully")
                case .failure(let error):
                    // If insert fails (likely duplicate), try update
                    print("Insert failed, attempting update: \(error)")
                    SupabaseService.shared.updateMonthlyExpenses(
                        userId: userId,
                        housing: housingAmount,
                        transportation: transportAmount,
                        carPayment: carPaymentAmount,
                        carInsurance: carInsuranceAmount,
                        carMaintenance: carMaintenanceAmount,
                        groceries: groceriesAmount,
                        subscriptions: subscriptionsAmount,
                        otherExpenses: otherAmount,
                        savings: savingsAmount,
                        dependentExpenses: dependentAmount
                    ) { updateResult in
                        DispatchQueue.main.async {
                            if case .failure(let updateError) = updateResult {
                                print("Error updating expenses in Supabase: \(updateError)")
                            } else {
                                print("Expenses updated to Supabase successfully")
                            }
                        }
                    }
                }
            }
        }
        
        isLoading = false
    }
    
    func isExpensesComplete() -> Bool {
        return monthlyExpenses != nil &&
               monthlyExpenses?.housing != nil &&
               monthlyExpenses?.transportation != nil &&
               monthlyExpenses?.carPayment != nil &&
               monthlyExpenses?.carInsurance != nil &&
               monthlyExpenses?.carMaintenance != nil &&
               monthlyExpenses?.groceries != nil &&
               monthlyExpenses?.subscriptions != nil &&
               monthlyExpenses?.otherExpenses != nil &&
               monthlyExpenses?.savings != nil
    }
}
