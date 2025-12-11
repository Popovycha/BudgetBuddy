import SwiftUI
import CoreLocation

struct ProfileSetupView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var monthlyExpensesViewModel = MonthlyExpensesViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showLocationSuggestions = false
    @State private var locationSuggestions: [(city: String, state: String, zipCode: String)] = []
    @State private var isSearchingLocation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.93, blue: 0.91)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with back button
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .navigationBarBackButtonHidden(true)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title
                        VStack(spacing: 8) {
                            Text("Tell Us About You")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("This helps us provide better advice")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Error message
                        if let error = profileViewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 1, green: 0.9, blue: 0.9))
                                .cornerRadius(8)
                        }
                        
                        // Age field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Age")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("25", text: $profileViewModel.age)
                                .keyboardType(.numberPad)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                                )
                                .submitLabel(.next)
                        }
                        
                        // Number of Dependents
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Number of Dependents")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("0", text: $profileViewModel.numberOfDependents)
                                .keyboardType(.numberPad)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                                )
                                .submitLabel(.next)
                        }
                        
                        // Location with autocomplete
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location (City, State)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    TextField("New York, NY", text: $profileViewModel.location)
                                        .autocapitalization(.words)
                                        .padding(12)
                                        .submitLabel(.next)
                                        .onChange(of: profileViewModel.location) { newValue in
                                            if !newValue.isEmpty {
                                                searchLocations(query: newValue)
                                                showLocationSuggestions = true
                                            } else {
                                                showLocationSuggestions = false
                                            }
                                        }
                                    
                                    Button(action: {
                                        requestDeviceLocation()
                                    }) {
                                        if isSearchingLocation {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.95, green: 0.70, blue: 0.65)))
                                                .frame(width: 20, height: 20)
                                        } else {
                                            Image(systemName: "location.fill")
                                                .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                        }
                                    }
                                    .padding(.trailing, 12)
                                }
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                                )
                                
                                // Location suggestions dropdown
                                if showLocationSuggestions && !locationSuggestions.isEmpty {
                                    VStack(alignment: .leading, spacing: 0) {
                                        ForEach(locationSuggestions.prefix(5), id: \.zipCode) { result in
                                            Button(action: {
                                                profileViewModel.location = "\(result.city), \(result.state)"
                                                profileViewModel.zipCode = result.zipCode
                                                showLocationSuggestions = false
                                            }) {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("\(result.city), \(result.state)")
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(.black)
                                                    if !result.zipCode.isEmpty {
                                                        Text(result.zipCode)
                                                            .font(.system(size: 12))
                                                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                                    }
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(12)
                                                .background(Color.white)
                                            }
                                            Divider()
                                                .padding(.horizontal, 12)
                                        }
                                    }
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        
                        // Zip Code
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Zip Code")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("10001", text: $profileViewModel.zipCode)
                                .keyboardType(.numberPad)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                                )
                                .submitLabel(.next)
                                .onChange(of: profileViewModel.zipCode) { newZipcode in
                                    if newZipcode.count == 5 {
                                        if let result = ZipcodeService.shared.lookupZipcode(newZipcode) {
                                            profileViewModel.location = "\(result.city), \(result.state)"
                                        }
                                    }
                                }
                        }
                        
                        // Monthly Net Income
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Monthly Net Income")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                
                                TextField("0.00", text: $profileViewModel.monthlyNetIncome)
                                    .keyboardType(.decimalPad)
                                    .submitLabel(.done)
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.90, green: 0.85, blue: 0.82), lineWidth: 1)
                            )
                        }
                        
                        // Marital Status (optional for now)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Marital Status")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Picker("Marital Status", selection: $profileViewModel.maritalStatus) {
                                Text("Single").tag(UserProfile.MaritalStatus.single)
                                Text("Married").tag(UserProfile.MaritalStatus.married)
                                Text("Divorced").tag(UserProfile.MaritalStatus.divorced)
                                Text("Widowed").tag(UserProfile.MaritalStatus.widowed)
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Continue button with Navigation
                        NavigationLink(destination: MonthlyExpensesView(
                            monthlyExpensesViewModel: monthlyExpensesViewModel,
                            profileViewModel: profileViewModel,
                            authViewModel: authViewModel
                        )) {
                            Text("Continue")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .foregroundColor(.white)
                                .background(Color(red: 0.15, green: 0.20, blue: 0.35))
                                .cornerRadius(16)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            if let userId = authViewModel.currentUser?.id {
                                profileViewModel.saveProfile(userId: userId)
                            }
                        })
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                }
            }
        }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    profileViewModel.loadProfile(userId: userId)
                }
            }
        }
    }
    
    // MARK: - Location Search
    func searchLocations(query: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query) { placemarks, error in
            DispatchQueue.main.async {
                guard let placemarks = placemarks else {
                    self.locationSuggestions = []
                    return
                }
                
                self.locationSuggestions = placemarks.compactMap { placemark in
                    let city = placemark.locality ?? ""
                    let state = placemark.administrativeArea ?? ""
                    let zipCode = placemark.postalCode ?? ""
                    
                    guard !city.isEmpty && !state.isEmpty else { return nil }
                    return (city: city, state: state, zipCode: zipCode)
                }
            }
        }
    }
    
    func requestDeviceLocation() {
        isSearchingLocation = true
        let locationManager = CLLocationManager()
        
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
        
        // Simulate getting location - in production use CLLocationManagerDelegate
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isSearchingLocation = false
        }
    }
}

#Preview {
    ProfileSetupView(
        profileViewModel: ProfileViewModel(),
        authViewModel: AuthViewModel()
    )
}
