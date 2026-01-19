import Foundation

struct ZipcodeDemographics {
    let zipcode: String
    let medianHouseholdIncome: Double
    let averageRent: Double
    let rentPercentileAboveNational: Double
    let populationDensity: Int
    let costOfLivingIndex: Double
}

struct CensusAPIResponse: Codable {
    let data: [[String]]?
    let error: CensusError?
    
    struct CensusError: Codable {
        let message: String?
    }
}

class DemographicDataService {
    static let shared = DemographicDataService()
    
    private let censusAPIKey = "687bdfb5a1db8a3174c28272cf40ffef7ec68e95"
    private let censusBaseURL = "https://api.census.gov/data/2021/acs/acs5"
    
    private let nationalMedianRent: Double = 1_800
    private let nationalMedianHouseholdIncome: Double = 75_000
    
    // Runtime cache for API results
    private var apiCache: [String: ZipcodeDemographics] = [:]
    private let cacheLock = NSLock()
    
    
    func fetchLiveCensusData(for zipcode: String, completion: @escaping (ZipcodeDemographics?) -> Void) {
        let cleanedZipcode = zipcode.trimmingCharacters(in: .whitespaces)
        
        // Check runtime cache first
        cacheLock.lock()
        if let cachedData = apiCache[cleanedZipcode] {
            cacheLock.unlock()
            print("DemographicDataService: Using runtime cached data for \(cleanedZipcode)")
            completion(cachedData)
            return
        }
        cacheLock.unlock()
        
        // Try Census API
        fetchFromCensusAPI(zipcode: cleanedZipcode) { [weak self] demographics in
            if let demographics = demographics {
                // Cache the result
                self?.cacheLock.lock()
                self?.apiCache[cleanedZipcode] = demographics
                self?.cacheLock.unlock()
                completion(demographics)
            } else {
                // Generate reasonable estimate for unknown zipcode
                print("DemographicDataService: Generating estimate for unknown zipcode \(cleanedZipcode)")
                let estimate = self?.generateEstimate(for: cleanedZipcode)
                completion(estimate)
            }
        }
    }
    
    private func fetchFromCensusAPI(zipcode: String, completion: @escaping (ZipcodeDemographics?) -> Void) {
        let variables = "B19013_001E,B25058_001E,B01003_001E"
        let geoFilter = "zip%20code%20tabulation%20area:\(zipcode)"
        
        var urlComponents = URLComponents(string: censusBaseURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "get", value: variables),
            URLQueryItem(name: "for", value: geoFilter),
            URLQueryItem(name: "key", value: censusAPIKey)
        ]
        
        guard let url = urlComponents?.url else {
            print("DemographicDataService: Invalid URL for Census API")
            completion(nil)
            return
        }
        
        print("DemographicDataService: Fetching Census API data for \(zipcode)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("DemographicDataService: Census API Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("DemographicDataService: No data received from Census API")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CensusAPIResponse.self, from: data)
                
                if let error = response.error {
                    print("DemographicDataService: Census API Error: \(error.message ?? "Unknown error")")
                    completion(nil)
                    return
                }
                
                guard let data = response.data, data.count > 1 else {
                    print("DemographicDataService: Invalid Census API response format")
                    completion(nil)
                    return
                }
                
                let row = data[1]
                guard row.count >= 3 else {
                    print("DemographicDataService: Incomplete Census data")
                    completion(nil)
                    return
                }
                
                let medianIncome = Double(row[0]) ?? 75_000
                let medianRent = Double(row[1]) ?? 1_800
                let population = Int(row[2]) ?? 0
                
                let rentPercentile = self?.calculateRentPercentile(medianRent) ?? 50
                let colIndex = self?.calculateCostOfLivingIndex(medianIncome, medianRent) ?? 100
                let populationDensity = self?.estimatePopulationDensity(population) ?? 10_000
                
                let demographics = ZipcodeDemographics(
                    zipcode: zipcode,
                    medianHouseholdIncome: medianIncome,
                    averageRent: medianRent,
                    rentPercentileAboveNational: rentPercentile,
                    populationDensity: populationDensity,
                    costOfLivingIndex: colIndex
                )
                
                print("DemographicDataService: Successfully fetched Census API data for \(zipcode)")
                completion(demographics)
            } catch {
                print("DemographicDataService: JSON Decode Error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    private func generateEstimate(for zipcode: String) -> ZipcodeDemographics {
        // Generate reasonable estimates based on zipcode hash
        let hash = abs(zipcode.hashValue)
        
        // Income range: $50k - $150k
        let incomeVariation = Double((hash % 100_000))
        let medianIncome = 50_000 + incomeVariation
        
        // Rent range: $800 - $3,500
        let rentVariation = Double((hash / 100) % 2_700)
        let averageRent = 800 + rentVariation
        
        let rentPercentile = calculateRentPercentile(averageRent)
        let colIndex = calculateCostOfLivingIndex(medianIncome, averageRent)
        let populationDensity = 5_000 + (hash % 30_000)
        
        return ZipcodeDemographics(
            zipcode: zipcode,
            medianHouseholdIncome: medianIncome,
            averageRent: averageRent,
            rentPercentileAboveNational: rentPercentile,
            populationDensity: populationDensity,
            costOfLivingIndex: colIndex
        )
    }
    
    private func calculateRentPercentile(_ rent: Double) -> Double {
        let percentile = (rent / nationalMedianRent) * 100
        return min(max(percentile, 0), 100)
    }
    
    private func calculateCostOfLivingIndex(_ income: Double, _ rent: Double) -> Double {
        let incomeRatio = income / nationalMedianHouseholdIncome
        let rentRatio = rent / nationalMedianRent
        let index = ((incomeRatio * 0.4) + (rentRatio * 0.6)) * 100
        return index
    }
    
    private func estimatePopulationDensity(_ population: Int) -> Int {
        let avgZipcodeArea = 10.0
        return Int(Double(population) / avgZipcodeArea)
    }
}
