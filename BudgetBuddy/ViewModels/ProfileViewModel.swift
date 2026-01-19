import Foundation
import Combine

enum ZipcodeVerificationStatus {
    case idle
    case verifying
    case verified
    case error(String)
}

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
    
    @Published var zipcodeVerificationStatus: ZipcodeVerificationStatus = .idle
    @Published var zipcodeData: ZipcodeData?
    @Published var demographicData: ZipcodeDemographics?
    @Published var metropolitanArea: MetropolitanArea?
    
    private let storageService = LocalStorageService.shared
    private let zipcodeService = ZipcodeService.shared
    private let demographicService = DemographicDataService.shared
    private let metropolitanService = MetropolitanAreaService.shared
    
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
    
    func verifyZipcode(_ zipcode: String) {
        zipcodeVerificationStatus = .verifying
        
        zipcodeService.verifyZipcode(zipcode) { [weak self] verified in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let verified = verified {
                    self.zipcodeData = verified
                    self.location = "\(verified.city), \(verified.state)"
                    self.metropolitanArea = self.metropolitanService.getMetropolitanArea(for: zipcode)
                    
                    self.demographicService.fetchLiveCensusData(for: zipcode) { [weak self] demographics in
                        DispatchQueue.main.async {
                            self?.demographicData = demographics
                            self?.zipcodeVerificationStatus = .verified
                        }
                    }
                } else {
                    self.zipcodeVerificationStatus = .error("Zipcode not found. Please verify and try again.")
                    self.zipcodeData = nil
                    self.demographicData = nil
                    self.metropolitanArea = nil
                }
            }
        }
    }
}
