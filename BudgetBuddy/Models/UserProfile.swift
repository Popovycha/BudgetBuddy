import Foundation

struct UserProfile: Codable {
    let userId: String
    var age: Int?
    var numberOfDependents: Int?
    var location: String?
    var zipCode: String?
    var monthlyNetIncome: Double?
    var maritalStatus: MaritalStatus?
    var createdAt: Date?
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case age
        case numberOfDependents = "number_of_dependents"
        case location
        case zipCode = "zip_code"
        case monthlyNetIncome = "monthly_net_income"
        case maritalStatus = "marital_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(String.self, forKey: .userId)
        age = try container.decodeIfPresent(Int.self, forKey: .age)
        numberOfDependents = try container.decodeIfPresent(Int.self, forKey: .numberOfDependents)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        zipCode = try container.decodeIfPresent(String.self, forKey: .zipCode)
        maritalStatus = try container.decodeIfPresent(MaritalStatus.self, forKey: .maritalStatus)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        
        // Handle monthlyNetIncome - can be Double, String, or Int from numeric(10,2)
        if let doubleValue = try container.decodeIfPresent(Double.self, forKey: .monthlyNetIncome) {
            monthlyNetIncome = doubleValue
        } else if let stringValue = try container.decodeIfPresent(String.self, forKey: .monthlyNetIncome) {
            monthlyNetIncome = Double(stringValue)
        } else if let intValue = try container.decodeIfPresent(Int.self, forKey: .monthlyNetIncome) {
            monthlyNetIncome = Double(intValue)
        } else {
            monthlyNetIncome = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encodeIfPresent(age, forKey: .age)
        try container.encodeIfPresent(numberOfDependents, forKey: .numberOfDependents)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(zipCode, forKey: .zipCode)
        try container.encodeIfPresent(monthlyNetIncome, forKey: .monthlyNetIncome)
        try container.encodeIfPresent(maritalStatus, forKey: .maritalStatus)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
    
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
