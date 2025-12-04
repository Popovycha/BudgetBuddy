import Foundation

struct UserProfile: Codable {
    let userId: String
    var age: Int?
    var numberOfDependents: Int?
    var location: String?
    var zipCode: String?
    var monthlyNetIncome: Double?
    var maritalStatus: MaritalStatus?
    var createdAt: Date
    var updatedAt: Date
    
    enum MaritalStatus: String, Codable {
        case single
        case married
        case divorced
        case widowed
    }
    
    init(userId: String) {
        self.userId = userId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
