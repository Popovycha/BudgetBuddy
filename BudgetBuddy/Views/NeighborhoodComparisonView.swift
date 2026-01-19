import SwiftUI

struct NeighborhoodComparisonView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var monthlyExpensesViewModel: MonthlyExpensesViewModel
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.93, blue: 0.91)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Text("Neighborhood Comparison")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            if let demographics = profileViewModel.demographicData,
                               let zipcodeData = profileViewModel.zipcodeData {
                                let userIncome = Double(profileViewModel.monthlyNetIncome) ?? 0
                                let userHousing = Double(monthlyExpensesViewModel.housing) ?? 0
                                let neighborhoodIncome = (demographics.medianHouseholdIncome / 12) * 0.70
                                let neighborhoodRent = demographics.averageRent
                                
                                // Neighborhood Info
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("\(zipcodeData.city), \(zipcodeData.state)")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.black)
                                            
                                            Text("Zipcode: \(zipcodeData.zipcode)")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                
                                // Income Comparison
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Monthly Net Income Comparison")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    ComparisonRow(
                                        label: "Your Monthly Net Income",
                                        value: formatCurrency(userIncome),
                                        color: Color(red: 0.15, green: 0.20, blue: 0.35)
                                    )
                                    
                                    ComparisonRow(
                                        label: "Neighborhood Median",
                                        value: formatCurrency(neighborhoodIncome),
                                        color: Color(red: 0.35, green: 0.40, blue: 0.50)
                                    )
                                    
                                    Divider()
                                        .padding(.vertical, 8)
                                    
                                    let incomeDiff = userIncome - neighborhoodIncome
                                    if incomeDiff > 0 {
                                        Text("You earn \(formatCurrency(incomeDiff))/month more than the neighborhood median")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                    } else {
                                        Text("You earn \(formatCurrency(abs(incomeDiff)))/month less than the neighborhood median")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                    }
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                
                                // Housing Cost Comparison
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Housing Cost Comparison")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    ComparisonRow(
                                        label: "Your Housing Cost",
                                        value: formatCurrency(userHousing),
                                        color: Color(red: 0.95, green: 0.70, blue: 0.65)
                                    )
                                    
                                    ComparisonRow(
                                        label: "Neighborhood Median",
                                        value: formatCurrency(neighborhoodRent),
                                        color: Color(red: 0.35, green: 0.40, blue: 0.50)
                                    )
                                    
                                    Divider()
                                        .padding(.vertical, 8)
                                    
                                    let housingDiff = userHousing - neighborhoodRent
                                    if housingDiff > 0 {
                                        Text("You spend \(formatCurrency(housingDiff)) more on housing than the neighborhood median")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                    } else {
                                        Text("You spend \(formatCurrency(abs(housingDiff))) less on housing than the neighborhood median")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                    }
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                
                                // Housing Percentage Comparison
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Housing as % of Income")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    let userPercentage = userIncome > 0 ? (userHousing / userIncome) * 100 : 0
                                    let neighborhoodPercentage = neighborhoodIncome > 0 ? (neighborhoodRent / neighborhoodIncome) * 100 : 0
                                    
                                    ComparisonRow(
                                        label: "Your Percentage",
                                        value: String(format: "%.1f%%", userPercentage),
                                        color: Color(red: 0.95, green: 0.70, blue: 0.65)
                                    )
                                    
                                    ComparisonRow(
                                        label: "Neighborhood Average",
                                        value: String(format: "%.1f%%", neighborhoodPercentage),
                                        color: Color(red: 0.35, green: 0.40, blue: 0.50)
                                    )
                                    
                                    Divider()
                                        .padding(.vertical, 8)
                                    
                                    let percentageDiff = userPercentage - neighborhoodPercentage
                                    if percentageDiff > 0 {
                                        Text("Your housing is \(String(format: "%.1f%%", percentageDiff)) higher than the neighborhood average")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                    } else {
                                        Text("Your housing is \(String(format: "%.1f%%", abs(percentageDiff))) lower than the neighborhood average")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                    }
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                
                                // Insights
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                        
                                        Text("Insights")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        let percentageDiff = (userIncome > 0 ? (userHousing / userIncome) * 100 : 0) - (neighborhoodIncome > 0 ? (neighborhoodRent / neighborhoodIncome) * 100 : 0)
                                        
                                        if percentageDiff > 5 {
                                            InsightRow(
                                                icon: "exclamationmark.circle.fill",
                                                color: Color(red: 0.95, green: 0.70, blue: 0.65),
                                                text: "Your housing costs are significantly higher than your neighborhood. Consider finding more affordable housing."
                                            )
                                        } else if percentageDiff > 0 {
                                            InsightRow(
                                                icon: "info.circle.fill",
                                                color: Color(red: 0.95, green: 0.85, blue: 0.60),
                                                text: "Your housing costs are slightly above the neighborhood average."
                                            )
                                        } else {
                                            InsightRow(
                                                icon: "checkmark.circle.fill",
                                                color: Color(red: 0.45, green: 0.85, blue: 0.45),
                                                text: "Your housing costs are below the neighborhood average. Great job!"
                                            )
                                        }
                                    }
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.red)
                                    
                                    Text("No Data Available")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.black)
                                    
                                    Text("Please verify your zipcode to see neighborhood comparison data.")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func getComparison() -> ComparisonResult? {
        let zipcode = profileViewModel.userProfile?.zipCode ?? ""
        let income = Double(profileViewModel.monthlyNetIncome) ?? 0
        let housing = Double(monthlyExpensesViewModel.housing) ?? 0
        
        guard !zipcode.isEmpty, income > 0 else { return nil }
        
        return NeighborhoodComparisonService.shared.compareWithNeighborhood(
            userIncome: income,
            userHousingCost: housing,
            zipcode: zipcode
        )
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Comparison Row
struct ComparisonRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Insight Row
struct InsightRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                .lineLimit(nil)
        }
    }
}

#Preview {
    NeighborhoodComparisonView(
        profileViewModel: ProfileViewModel(),
        monthlyExpensesViewModel: MonthlyExpensesViewModel(),
        isPresented: .constant(true)
    )
}
