import Foundation

struct MonthlyExpenses: Codable {
    let userId: String
    
    // Essentials
    var housing: Double?
    var transportation: Double?
    var carPayment: Double?
    var carInsurance: Double?
    var carMaintenance: Double?
    var groceries: Double?
    
    // Lifestyle
    var subscriptions: Double?
    var otherExpenses: Double?
    
    // Savings
    var savings: Double?
    
    // Dependents
    var dependentExpenses: Double?
    
    var createdAt: Date
    var updatedAt: Date
    
    init(userId: String) {
        self.userId = userId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
