import Foundation
import Supabase

// MARK: - Codable Models for Database Operations

struct UserProfileInsert: Encodable {
    let user_id: String
    let age: Int
    let number_of_dependents: Int
    let location: String
    let zip_code: String
    let monthly_net_income: Double
    let marital_status: String
}

struct UserProfileUpdate: Encodable {
    let age: Int?
    let number_of_dependents: Int?
    let location: String?
    let zip_code: String?
    let monthly_net_income: Double?
    let marital_status: String?
    
    func toDictionary() -> [String: Encodable] {
        var dict: [String: Encodable] = [:]
        if let age = age { dict["age"] = age }
        if let number_of_dependents = number_of_dependents { dict["number_of_dependents"] = number_of_dependents }
        if let location = location { dict["location"] = location }
        if let zip_code = zip_code { dict["zip_code"] = zip_code }
        if let monthly_net_income = monthly_net_income { dict["monthly_net_income"] = monthly_net_income }
        if let marital_status = marital_status { dict["marital_status"] = marital_status }
        return dict
    }
}

struct MonthlyExpensesInsert: Encodable {
    let user_id: String
    let housing: Double
    let transportation: Double
    let car_payment: Double
    let car_insurance: Double
    let car_maintenance: Double
    let groceries: Double
    let subscriptions: Double
    let other_expenses: Double
    let savings: Double
    let dependent_expenses: Double
}

struct MonthlyExpensesUpdate: Encodable {
    let housing: Double?
    let transportation: Double?
    let car_payment: Double?
    let car_insurance: Double?
    let car_maintenance: Double?
    let groceries: Double?
    let subscriptions: Double?
    let other_expenses: Double?
    let savings: Double?
    let dependent_expenses: Double?
    
    func toDictionary() -> [String: Encodable] {
        var dict: [String: Encodable] = [:]
        if let housing = housing { dict["housing"] = housing }
        if let transportation = transportation { dict["transportation"] = transportation }
        if let car_payment = car_payment { dict["car_payment"] = car_payment }
        if let car_insurance = car_insurance { dict["car_insurance"] = car_insurance }
        if let car_maintenance = car_maintenance { dict["car_maintenance"] = car_maintenance }
        if let groceries = groceries { dict["groceries"] = groceries }
        if let subscriptions = subscriptions { dict["subscriptions"] = subscriptions }
        if let other_expenses = other_expenses { dict["other_expenses"] = other_expenses }
        if let savings = savings { dict["savings"] = savings }
        if let dependent_expenses = dependent_expenses { dict["dependent_expenses"] = dependent_expenses }
        return dict
    }
}

class SupabaseService {
    static let shared = SupabaseService()
    
    private let projectURL = "https://stawhbhqkcstsmqjkquz.supabase.co"
    private let publishableKey = "sb_publishable_me9hrng2DpDHGeNBMHsdTw_R-0eyDKN"
    
    private lazy var supabase = SupabaseClient(
        supabaseURL: URL(string: projectURL)!,
        supabaseKey: publishableKey
    )
    
    private var authToken: String?
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Result<String, Error>) -> Void) {
        let signUpURL = "\(projectURL)/auth/v1/signup"
        var request = URLRequest(url: URL(string: signUpURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(publishableKey, forHTTPHeaderField: "apikey")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let user = json["user"] as? [String: Any],
                   let userId = user["id"] as? String {
                    self.authToken = json["session"] as? String
                    completion(.success(userId))
                } else {
                    completion(.failure(NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let signInURL = "\(projectURL)/auth/v1/token?grant_type=password"
        var request = URLRequest(url: URL(string: signInURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(publishableKey, forHTTPHeaderField: "apikey")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let user = json["user"] as? [String: Any],
                   let userId = user["id"] as? String {
                    self.authToken = json["access_token"] as? String
                    completion(.success(userId))
                } else {
                    completion(.failure(NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - User Profile
    
    func saveUserProfile(userId: String, firstName: String, lastName: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await self.supabase
                    .from("users")
                    .insert([
                        "id": userId,
                        "first_name": firstName,
                        "last_name": lastName,
                        "email": email,
                        "created_at": ISO8601DateFormatter().string(from: Date())
                    ])
                    .execute()
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func updateUserProfile(userId: String, firstName: String?, lastName: String?, email: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(projectURL)/rest/v1/users?id=eq.\(userId)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(publishableKey, forHTTPHeaderField: "apikey")
        
        var body: [String: Any] = [:]
        if let firstName = firstName { body["first_name"] = firstName }
        if let lastName = lastName { body["last_name"] = lastName }
        if let email = email { body["email"] = email }
        body["updated_at"] = ISO8601DateFormatter().string(from: Date())
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    // MARK: - User Profile Details
    
    func saveProfileDetails(userId: String, age: Int, numberOfDependents: Int, location: String, zipCode: String, monthlyNetIncome: Double, maritalStatus: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let profile = UserProfileInsert(
                    user_id: userId,
                    age: age,
                    number_of_dependents: numberOfDependents,
                    location: location,
                    zip_code: zipCode,
                    monthly_net_income: monthlyNetIncome,
                    marital_status: maritalStatus
                )
                
                try await supabase
                    .from("user_profiles")
                    .insert(profile)
                    .execute()
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func updateProfileDetails(userId: String, age: Int?, numberOfDependents: Int?, location: String?, zipCode: String?, monthlyNetIncome: Double?, maritalStatus: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let profile = UserProfileUpdate(
                    age: age,
                    number_of_dependents: numberOfDependents,
                    location: location,
                    zip_code: zipCode,
                    monthly_net_income: monthlyNetIncome,
                    marital_status: maritalStatus
                )
                
                try await supabase
                    .from("user_profiles")
                    .update(profile)
                    .eq("user_id", value: userId)
                    .execute()
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Monthly Expenses
    
    func saveMonthlyExpenses(userId: String, housing: Double, transportation: Double, carPayment: Double, carInsurance: Double, carMaintenance: Double, groceries: Double, subscriptions: Double, otherExpenses: Double, savings: Double, dependentExpenses: Double = 0, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let expenses = MonthlyExpensesInsert(
                    user_id: userId,
                    housing: housing,
                    transportation: transportation,
                    car_payment: carPayment,
                    car_insurance: carInsurance,
                    car_maintenance: carMaintenance,
                    groceries: groceries,
                    subscriptions: subscriptions,
                    other_expenses: otherExpenses,
                    savings: savings,
                    dependent_expenses: dependentExpenses
                )
                
                try await supabase
                    .from("monthly_expenses")
                    .insert(expenses)
                    .execute()
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func updateMonthlyExpenses(userId: String, housing: Double?, transportation: Double?, carPayment: Double?, carInsurance: Double?, carMaintenance: Double?, groceries: Double?, subscriptions: Double?, otherExpenses: Double?, savings: Double?, dependentExpenses: Double?, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let expenses = MonthlyExpensesUpdate(
                    housing: housing,
                    transportation: transportation,
                    car_payment: carPayment,
                    car_insurance: carInsurance,
                    car_maintenance: carMaintenance,
                    groceries: groceries,
                    subscriptions: subscriptions,
                    other_expenses: otherExpenses,
                    savings: savings,
                    dependent_expenses: dependentExpenses
                )
                
                try await supabase
                    .from("monthly_expenses")
                    .update(expenses)
                    .eq("user_id", value: userId)
                    .execute()
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
