import Foundation

class LocalStorageService {
    static let shared = LocalStorageService()
    
    private let userDefaults = UserDefaults.standard
    private let userProfileKey = "userProfile_"
    private let currentUserKey = "currentUser"
    private let monthlyExpensesKey = "monthlyExpenses_"
    
    // MARK: - User Storage
    
    func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: currentUserKey)
        }
    }
    
    func getCurrentUser() -> User? {
        guard let data = userDefaults.data(forKey: currentUserKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }
    
    func deleteCurrentUser() {
        userDefaults.removeObject(forKey: currentUserKey)
    }
    
    // MARK: - User Profile Storage
    
    func saveUserProfile(_ profile: UserProfile) {
        let key = userProfileKey + profile.userId
        if let encoded = try? JSONEncoder().encode(profile) {
            userDefaults.set(encoded, forKey: key)
        }
    }
    
    func getUserProfile(userId: String) -> UserProfile? {
        let key = userProfileKey + userId
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    func deleteUserProfile(userId: String) {
        let key = userProfileKey + userId
        userDefaults.removeObject(forKey: key)
    }
    
    // MARK: - Check if profile exists
    
    func profileExists(userId: String) -> Bool {
        let key = userProfileKey + userId
        return userDefaults.data(forKey: key) != nil
    }
    
    // MARK: - Monthly Expenses Storage
    
    func saveMonthlyExpenses(_ expenses: MonthlyExpenses) {
        let key = monthlyExpensesKey + expenses.userId
        if let encoded = try? JSONEncoder().encode(expenses) {
            userDefaults.set(encoded, forKey: key)
        }
    }
    
    func getMonthlyExpenses(userId: String) -> MonthlyExpenses? {
        let key = monthlyExpensesKey + userId
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(MonthlyExpenses.self, from: data)
    }
    
    func deleteMonthlyExpenses(userId: String) {
        let key = monthlyExpensesKey + userId
        userDefaults.removeObject(forKey: key)
    }
    
    func expensesExist(userId: String) -> Bool {
        let key = monthlyExpensesKey + userId
        return userDefaults.data(forKey: key) != nil
    }
}
