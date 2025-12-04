import Foundation
import Combine

class BudgetAnalysisViewModel: ObservableObject {
    @Published var analysisResult: BudgetAnalysisResult?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let analysisService = BudgetAnalysisService.shared
    
    func analyzeBudget(
        monthlyNetIncome: String,
        housing: String,
        transportation: String,
        carPayment: String,
        carInsurance: String,
        carMaintenance: String,
        groceries: String,
        subscriptions: String,
        otherExpenses: String,
        savings: String,
        zipcode: String = "",
        city: String = "",
        isHCOLOverride: Bool? = nil
    ) {
        isLoading = true
        errorMessage = nil
        
        // Convert strings to doubles
        guard let nmi = Double(monthlyNetIncome), nmi > 0 else {
            errorMessage = "Please enter a valid monthly net income"
            isLoading = false
            return
        }
        
        let housing = Double(housing) ?? 0
        let transportation = Double(transportation) ?? 0
        let carPayment = Double(carPayment) ?? 0
        let carInsurance = Double(carInsurance) ?? 0
        let carMaintenance = Double(carMaintenance) ?? 0
        let groceries = Double(groceries) ?? 0
        let subscriptions = Double(subscriptions) ?? 0
        let otherExpenses = Double(otherExpenses) ?? 0
        let savings = Double(savings) ?? 0
        
        // Perform analysis
        DispatchQueue.main.async {
            self.analysisResult = self.analysisService.analyzeBudget(
                monthlyNetIncome: nmi,
                housing: housing,
                transportation: transportation,
                carPayment: carPayment,
                carInsurance: carInsurance,
                carMaintenance: carMaintenance,
                groceries: groceries,
                subscriptions: subscriptions,
                otherExpenses: otherExpenses,
                savings: savings,
                zipcode: zipcode,
                city: city,
                isHCOLOverride: isHCOLOverride
            )
            self.isLoading = false
        }
    }
}
