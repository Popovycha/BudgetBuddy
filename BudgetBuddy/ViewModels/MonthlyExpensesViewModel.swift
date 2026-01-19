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
        
        // Parse all expenses as optional (allow blank fields)
        let housingAmount = Double(housing) ?? 0
        let transportAmount = Double(transportation) ?? 0
        let carPaymentAmount = Double(carPayment) ?? 0
        let carInsuranceAmount = Double(carInsurance) ?? 0
        let carMaintenanceAmount = Double(carMaintenance) ?? 0
        let groceriesAmount = Double(groceries) ?? 0
        let subscriptionsAmount = Double(subscriptions) ?? 0
        let otherAmount = Double(otherExpenses) ?? 0
        let savingsAmount = Double(savings) ?? 0
        
        // Validate all amounts are non-negative
        let allAmounts = [housingAmount, transportAmount, carPaymentAmount, carInsuranceAmount, 
                         carMaintenanceAmount, groceriesAmount, subscriptionsAmount, otherAmount, savingsAmount]
        
        if allAmounts.contains(where: { $0 < 0 }) {
            errorMessage = "Expenses cannot be negative"
            isLoading = false
            return
        }
        
        // Parse dependent expenses if shown
        var dependentAmount: Double? = nil
        if showDependentExpenses {
            dependentAmount = Double(dependentExpenses) ?? 0
            if let depAmount = dependentAmount, depAmount < 0 {
                errorMessage = "Dependent expenses cannot be negative"
                isLoading = false
                return
            }
        }
        
        // Create or update expenses
        var expenses = monthlyExpenses ?? MonthlyExpenses(userId: userId)
        expenses.housing = housingAmount > 0 ? housingAmount : nil
        expenses.transportation = transportAmount > 0 ? transportAmount : nil
        expenses.carPayment = carPaymentAmount > 0 ? carPaymentAmount : nil
        expenses.carInsurance = carInsuranceAmount > 0 ? carInsuranceAmount : nil
        expenses.carMaintenance = carMaintenanceAmount > 0 ? carMaintenanceAmount : nil
        expenses.groceries = groceriesAmount > 0 ? groceriesAmount : nil
        expenses.subscriptions = subscriptionsAmount > 0 ? subscriptionsAmount : nil
        expenses.otherExpenses = otherAmount > 0 ? otherAmount : nil
        expenses.savings = savingsAmount > 0 ? savingsAmount : nil
        expenses.dependentExpenses = dependentAmount
        expenses.updatedAt = Date()
        
        // Save to local storage
        storageService.saveMonthlyExpenses(expenses)
        self.monthlyExpenses = expenses
        
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
