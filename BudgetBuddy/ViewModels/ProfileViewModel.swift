import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var age: String = ""
    @Published var numberOfDependents: String = "0"
    @Published var location: String = ""
    @Published var zipCode: String = ""
    @Published var monthlyNetIncome: String = ""
    @Published var maritalStatus: UserProfile.MaritalStatus = .single
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let storageService = LocalStorageService.shared
    
    func loadProfile(userId: String) {
        if let profile = storageService.getUserProfile(userId: userId) {
            self.userProfile = profile
            self.age = String(profile.age ?? 0)
            self.numberOfDependents = String(profile.numberOfDependents ?? 0)
            self.location = profile.location ?? ""
            self.zipCode = profile.zipCode ?? ""
            self.monthlyNetIncome = String(profile.monthlyNetIncome ?? 0)
            self.maritalStatus = profile.maritalStatus ?? .single
        } else {
            self.userProfile = UserProfile(userId: userId)
        }
    }
    
    func saveProfile(userId: String) {
        isLoading = true
        errorMessage = nil
        
        // Validate inputs
        guard !age.isEmpty, let ageInt = Int(age), ageInt > 0 else {
            errorMessage = "Please enter a valid age"
            isLoading = false
            return
        }
        
        guard !numberOfDependents.isEmpty, let dependents = Int(numberOfDependents), dependents >= 0 else {
            errorMessage = "Please enter a valid number of dependents"
            isLoading = false
            return
        }
        
        guard !location.isEmpty else {
            errorMessage = "Please enter your location"
            isLoading = false
            return
        }
        
        guard !zipCode.isEmpty else {
            errorMessage = "Please enter your zip code"
            isLoading = false
            return
        }
        
        guard !monthlyNetIncome.isEmpty, let income = Double(monthlyNetIncome), income >= 0 else {
            errorMessage = "Please enter a valid monthly income"
            isLoading = false
            return
        }
        
        // Create or update profile
        var profile = userProfile ?? UserProfile(userId: userId)
        profile.age = ageInt
        profile.numberOfDependents = dependents
        profile.location = location
        profile.zipCode = zipCode
        profile.monthlyNetIncome = income
        profile.maritalStatus = maritalStatus
        profile.updatedAt = Date()
        
        // Save to local storage
        storageService.saveUserProfile(profile)
        self.userProfile = profile
        
        // Save to Supabase
        let maritalStatusString = maritalStatus.rawValue
        
        // Capture variables for use in nested closures
        let capturedLocation = location
        let capturedZipCode = zipCode
        
        // Always try to insert first, if it fails (duplicate key), then update
        SupabaseService.shared.saveProfileDetails(
            userId: userId,
            age: ageInt,
            numberOfDependents: dependents,
            location: capturedLocation,
            zipCode: capturedZipCode,
            monthlyNetIncome: income,
            maritalStatus: maritalStatusString
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Profile saved to Supabase successfully")
                case .failure(let error):
                    // If insert fails (likely duplicate), try update
                    print("Insert failed, attempting update: \(error)")
                    SupabaseService.shared.updateProfileDetails(
                        userId: userId,
                        age: ageInt,
                        numberOfDependents: dependents,
                        location: capturedLocation,
                        zipCode: capturedZipCode,
                        monthlyNetIncome: income,
                        maritalStatus: maritalStatusString
                    ) { updateResult in
                        DispatchQueue.main.async {
                            if case .failure(let updateError) = updateResult {
                                print("Error updating profile in Supabase: \(updateError)")
                            } else {
                                print("Profile updated to Supabase successfully")
                            }
                        }
                    }
                }
            }
        }
        
        isLoading = false
    }
    
    func isProfileComplete() -> Bool {
        return userProfile != nil &&
               userProfile?.age != nil &&
               userProfile?.numberOfDependents != nil &&
               userProfile?.location != nil &&
               userProfile?.zipCode != nil &&
               userProfile?.monthlyNetIncome != nil
    }
}
