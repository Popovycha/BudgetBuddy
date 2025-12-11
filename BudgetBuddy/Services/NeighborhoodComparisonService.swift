import Foundation

struct NeighborhoodData {
    let zipcode: String
    let medianMonthlyNetIncome: Double  // Monthly net income (after taxes)
    let medianHousingCost: Double
    let averageHousingPercentage: Double
    let population: Int
    let city: String
    let state: String
}

class NeighborhoodComparisonService {
    static let shared = NeighborhoodComparisonService()
    
    // Sample neighborhood data based on Census Bureau data
    // Monthly net income is approximately 70% of gross annual income / 12
    // In a production app, this would fetch from Census API
    private let neighborhoodDatabase: [String: NeighborhoodData] = [
        // New York Metro
        "10003": NeighborhoodData(
            zipcode: "10003",
            medianMonthlyNetIncome: 4958,  // ~$85,000 gross annual
            medianHousingCost: 2500,
            averageHousingPercentage: 35,
            population: 45000,
            city: "New York",
            state: "NY"
        ),
        
        // Jersey City - 07305
        "07305": NeighborhoodData(
            zipcode: "07305",
            medianMonthlyNetIncome: 3617,  // ~$62,000 gross annual
            medianHousingCost: 1800,
            averageHousingPercentage: 32,
            population: 28000,
            city: "Jersey City",
            state: "NJ"
        ),
        
        // Jersey City - 07302
        "07302": NeighborhoodData(
            zipcode: "07302",
            medianMonthlyNetIncome: 3383,  // ~$58,000 gross annual
            medianHousingCost: 1700,
            averageHousingPercentage: 31,
            population: 32000,
            city: "Jersey City",
            state: "NJ"
        ),
        
        // Hoboken
        "07030": NeighborhoodData(
            zipcode: "07030",
            medianMonthlyNetIncome: 4375,  // ~$75,000 gross annual
            medianHousingCost: 2200,
            averageHousingPercentage: 35,
            population: 52000,
            city: "Hoboken",
            state: "NJ"
        ),
        
        // San Francisco
        "94105": NeighborhoodData(
            zipcode: "94105",
            medianMonthlyNetIncome: 7292,  // ~$125,000 gross annual
            medianHousingCost: 3500,
            averageHousingPercentage: 38,
            population: 35000,
            city: "San Francisco",
            state: "CA"
        ),
        
        // Los Angeles
        "90210": NeighborhoodData(
            zipcode: "90210",
            medianMonthlyNetIncome: 6417,  // ~$110,000 gross annual
            medianHousingCost: 3200,
            averageHousingPercentage: 36,
            population: 28000,
            city: "Beverly Hills",
            state: "CA"
        ),
        
        // Boston
        "02116": NeighborhoodData(
            zipcode: "02116",
            medianMonthlyNetIncome: 4550,  // ~$78,000 gross annual
            medianHousingCost: 2100,
            averageHousingPercentage: 34,
            population: 42000,
            city: "Boston",
            state: "MA"
        ),
        
        // Washington DC
        "20001": NeighborhoodData(
            zipcode: "20001",
            medianMonthlyNetIncome: 5367,  // ~$92,000 gross annual
            medianHousingCost: 2400,
            averageHousingPercentage: 33,
            population: 38000,
            city: "Washington",
            state: "DC"
        )
    ]
    
    func getNeighborhoodData(zipcode: String) -> NeighborhoodData? {
        return neighborhoodDatabase[zipcode]
    }
    
    func compareWithNeighborhood(
        userIncome: Double,
        userHousingCost: Double,
        zipcode: String
    ) -> ComparisonResult? {
        guard let neighborhood = getNeighborhoodData(zipcode: zipcode) else {
            return nil
        }
        
        let userHousingPercentage = (userHousingCost / userIncome) * 100
        let incomeDifference = userIncome - neighborhood.medianMonthlyNetIncome
        let housingDifference = userHousingCost - neighborhood.medianHousingCost
        let percentageDifference = userHousingPercentage - neighborhood.averageHousingPercentage
        
        return ComparisonResult(
            neighborhood: neighborhood,
            userIncome: userIncome,
            userHousingCost: userHousingCost,
            userHousingPercentage: userHousingPercentage,
            incomeDifference: incomeDifference,
            housingDifference: housingDifference,
            percentageDifference: percentageDifference
        )
    }
}

struct ComparisonResult {
    let neighborhood: NeighborhoodData
    let userIncome: Double
    let userHousingCost: Double
    let userHousingPercentage: Double
    let incomeDifference: Double
    let housingDifference: Double
    let percentageDifference: Double
    
    var incomeStatus: String {
        if incomeDifference > 0 {
            return "You earn \(String(format: "$%.0f", incomeDifference))/month more than the neighborhood median"
        } else {
            return "You earn \(String(format: "$%.0f", abs(incomeDifference)))/month less than the neighborhood median"
        }
    }
    
    var housingStatus: String {
        if housingDifference > 0 {
            return "You spend \(String(format: "$%.0f", housingDifference)) more on housing than the neighborhood median"
        } else {
            return "You spend \(String(format: "$%.0f", abs(housingDifference))) less on housing than the neighborhood median"
        }
    }
    
    var percentageStatus: String {
        if percentageDifference > 0 {
            return "Your housing is \(String(format: "%.1f", percentageDifference))% higher than the neighborhood average"
        } else {
            return "Your housing is \(String(format: "%.1f", abs(percentageDifference)))% lower than the neighborhood average"
        }
    }
}
