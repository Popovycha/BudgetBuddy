import Foundation

struct ZipcodeDemographics {
    let zipcode: String
    let medianHouseholdIncome: Double
    let averageRent: Double
    let rentPercentileAboveNational: Double
    let populationDensity: Int
    let costOfLivingIndex: Double
}

class DemographicDataService {
    static let shared = DemographicDataService()
    
    private let censusAPIKey = "687bdfb5a1db8a3174c28272cf40ffef7ec68e95"
    private let censusBaseURL = "https://api.census.gov/data/2021/acs/acs5"
    
    // Census ACS 5-year data is from 2017-2021 (midpoint ~2019)
    // Apply inflation adjustment to bring rent closer to current 2025/2026 values
    // Rent inflation ~30% from 2019 to 2025 based on CPI shelter index
    private let rentInflationFactor: Double = 1.30
    
    private let nationalMedianRent: Double = 1_800
    private let nationalMedianHouseholdIncome: Double = 75_000
    
    // Runtime cache for API results
    private var apiCache: [String: ZipcodeDemographics] = [:]
    private let cacheLock = NSLock()
    
    func clearCache(for zipcode: String) {
        let cleanedZipcode = zipcode.trimmingCharacters(in: .whitespaces)
        cacheLock.lock()
        apiCache.removeValue(forKey: cleanedZipcode)
        cacheLock.unlock()
        print("DemographicDataService: Cleared cache for \(cleanedZipcode)")
    }
    
    func clearAllCache() {
        cacheLock.lock()
        apiCache.removeAll()
        cacheLock.unlock()
        print("DemographicDataService: Cleared all cache")
    }
    
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
        
        // For all zipcodes, validate against neighbors to ensure consistency
        // Only use neighbor average if difference exceeds 30% threshold
        fetchWithNeighborValidation(zipcode: cleanedZipcode, completion: completion)
    }
    
    private func fetchWithNeighborValidation(zipcode: String, completion: @escaping (ZipcodeDemographics?) -> Void) {
        // Get neighboring zipcodes (±1, ±2)
        let neighbors = getNeighboringZipcodes(zipcode)
        
        // Fetch data for main zipcode and neighbors in parallel
        let group = DispatchGroup()
        let dataLock = NSLock()
        var rentValues: [Double] = []
        var incomeValues: [Double] = []
        var mainDemographics: ZipcodeDemographics?
        
        // Fetch main zipcode
        group.enter()
        fetchFromCensusAPI(zipcode: zipcode) { demographics in
            dataLock.lock()
            if let demographics = demographics {
                mainDemographics = demographics
                rentValues.append(demographics.averageRent)
                incomeValues.append(demographics.medianHouseholdIncome)
            }
            dataLock.unlock()
            group.leave()
        }
        
        // Fetch neighbors (limit to 4 for better coverage while maintaining performance)
        for neighbor in neighbors.prefix(4) {
            group.enter()
            fetchFromCensusAPI(zipcode: neighbor) { demographics in
                dataLock.lock()
                if let demographics = demographics {
                    rentValues.append(demographics.averageRent)
                    incomeValues.append(demographics.medianHouseholdIncome)
                }
                dataLock.unlock()
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            print("DemographicDataService: Neighbor validation complete for \(zipcode) - \(rentValues.count) rent values collected, rents: \(rentValues.map { Int($0) })")
            
            // If we have neighbor data, check for significant differences
            if rentValues.count >= 2, let main = mainDemographics {
                // Find the highest rent among all collected values (user's + neighbors)
                let maxRent = rentValues.max() ?? main.averageRent
                let userRent = main.averageRent
                
                // Check if there's a significant difference between user's rent and max neighbor rent
                let rentDiff = abs(maxRent - userRent) / max(maxRent, userRent)
                
                if rentDiff > 0.30 {
                    // Average user's zipcode rent with the highest neighbor rent
                    // This gives a more realistic estimate when Census data is inconsistent
                    let adjustedRent = (userRent + maxRent) / 2.0
                    let avgIncome = incomeValues.reduce(0, +) / Double(incomeValues.count)
                    
                    print("DemographicDataService: Zipcode \(zipcode) rent ($\(Int(userRent))) differs >30% from highest neighbor ($\(Int(maxRent))), using average: $\(Int(adjustedRent))")
                    
                    let colIndex = self.calculateCostOfLivingIndex(avgIncome * 12 / 0.70, adjustedRent, zipcode: zipcode)
                    
                    let adjusted = ZipcodeDemographics(
                        zipcode: zipcode,
                        medianHouseholdIncome: avgIncome,
                        averageRent: adjustedRent,
                        rentPercentileAboveNational: self.calculateRentPercentile(adjustedRent),
                        populationDensity: main.populationDensity,
                        costOfLivingIndex: colIndex
                    )
                    
                    self.cacheLock.lock()
                    self.apiCache[zipcode] = adjusted
                    self.cacheLock.unlock()
                    completion(adjusted)
                    return
                }
            }
            
            // Use main demographics if available and valid
            if let main = mainDemographics {
                print("DemographicDataService: Returning data for \(zipcode) - COL Index: \(String(format: "%.1f", main.costOfLivingIndex))")
                self.cacheLock.lock()
                self.apiCache[zipcode] = main
                self.cacheLock.unlock()
                completion(main)
            } else {
                // Fall back to estimate
                print("DemographicDataService: Generating estimate for unknown zipcode \(zipcode)")
                let estimate = self.generateEstimate(for: zipcode)
                completion(estimate)
            }
        }
    }
    
    private func getNeighboringZipcodes(_ zipcode: String) -> [String] {
        // First check if we have geographic neighbors defined for this area
        if let geoNeighbors = getGeographicNeighbors(for: zipcode), !geoNeighbors.isEmpty {
            return geoNeighbors
        }
        
        // Fall back to numeric proximity for areas without defined geographic neighbors
        guard let zipcodeInt = Int(zipcode) else { return [] }
        
        var neighbors: [String] = []
        
        // Add ±1, ±2, and ±3 zipcodes for better coverage
        for offset in [-3, -2, -1, 1, 2, 3] {
            let neighborInt = zipcodeInt + offset
            if neighborInt > 0 && neighborInt < 100000 {
                neighbors.append(String(format: "%05d", neighborInt))
            }
        }
        
        return neighbors
    }
    
    private func getGeographicNeighbors(for zipcode: String) -> [String]? {
        // Geographic neighbor clusters based on actual proximity, not numeric order
        // These are zipcodes that are physically close to each other
        
        // Southern Brooklyn cluster (Gravesend, Sheepshead Bay, Brighton Beach, Coney Island)
        let southernBrooklyn = ["11223", "11235", "11229", "11224", "11214", "11228"]
        if southernBrooklyn.contains(zipcode) {
            return southernBrooklyn.filter { $0 != zipcode }
        }
        
        // Central Brooklyn cluster (Flatbush, Midwood, Kensington)
        let centralBrooklyn = ["11226", "11230", "11210", "11203", "11218", "11219"]
        if centralBrooklyn.contains(zipcode) {
            return centralBrooklyn.filter { $0 != zipcode }
        }
        
        // North Brooklyn cluster (Williamsburg, Greenpoint, Bushwick)
        let northBrooklyn = ["11211", "11222", "11206", "11221", "11237", "11249"]
        if northBrooklyn.contains(zipcode) {
            return northBrooklyn.filter { $0 != zipcode }
        }
        
        // Downtown Brooklyn / Brooklyn Heights / Park Slope
        let downtownBrooklyn = ["11201", "11215", "11217", "11231", "11232", "11238"]
        if downtownBrooklyn.contains(zipcode) {
            return downtownBrooklyn.filter { $0 != zipcode }
        }
        
        // Jersey City cluster
        let jerseyCity = ["07302", "07304", "07305", "07306", "07307", "07310", "07311"]
        if jerseyCity.contains(zipcode) {
            return jerseyCity.filter { $0 != zipcode }
        }
        
        // Hoboken / Union City / West New York
        let hudsonCountyNorth = ["07030", "07087", "07093", "07047"]
        if hudsonCountyNorth.contains(zipcode) {
            return hudsonCountyNorth.filter { $0 != zipcode }
        }
        
        // Lower Manhattan cluster
        let lowerManhattan = ["10001", "10002", "10003", "10004", "10005", "10006", "10007", "10012", "10013", "10014"]
        if lowerManhattan.contains(zipcode) {
            return lowerManhattan.filter { $0 != zipcode }
        }
        
        // Midtown Manhattan cluster
        let midtownManhattan = ["10016", "10017", "10018", "10019", "10020", "10022", "10036"]
        if midtownManhattan.contains(zipcode) {
            return midtownManhattan.filter { $0 != zipcode }
        }
        
        // Upper East Side Manhattan
        let upperEastSide = ["10021", "10028", "10065", "10075", "10128"]
        if upperEastSide.contains(zipcode) {
            return upperEastSide.filter { $0 != zipcode }
        }
        
        // Upper West Side Manhattan
        let upperWestSide = ["10023", "10024", "10025", "10069"]
        if upperWestSide.contains(zipcode) {
            return upperWestSide.filter { $0 != zipcode }
        }
        
        // San Francisco cluster
        let sanFrancisco = ["94102", "94103", "94104", "94105", "94107", "94108", "94109", "94110", "94111", "94112"]
        if sanFrancisco.contains(zipcode) {
            return sanFrancisco.filter { $0 != zipcode }
        }
        
        // Los Angeles - West Side
        let laWestSide = ["90024", "90025", "90049", "90064", "90066", "90067", "90077", "90210", "90212"]
        if laWestSide.contains(zipcode) {
            return laWestSide.filter { $0 != zipcode }
        }
        
        // Los Angeles - Downtown / East
        let laDowntown = ["90012", "90013", "90014", "90015", "90017", "90021", "90071"]
        if laDowntown.contains(zipcode) {
            return laDowntown.filter { $0 != zipcode }
        }
        
        return nil // No geographic cluster defined, use numeric fallback
    }
    
    private func fetchFromCensusAPI(zipcode: String, completion: @escaping (ZipcodeDemographics?) -> Void) {
        // B19013_001E = Median Household Income
        // B25064_001E = Median Gross Rent (includes utilities - more accurate than contract rent)
        // B01003_001E = Total Population
        let variables = "B19013_001E,B25064_001E,B01003_001E"
        
        // Build URL manually to avoid double-encoding issues
        let urlString = "\(censusBaseURL)?get=\(variables)&for=zip%20code%20tabulation%20area:\(zipcode)&key=\(censusAPIKey)"
        
        guard let url = URL(string: urlString) else {
            print("DemographicDataService: Invalid URL for Census API")
            completion(nil)
            return
        }
        
        print("DemographicDataService: Fetching Census API data for \(zipcode) - URL: \(urlString)")
        
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
            
            // Log raw response for debugging
            let rawString = String(data: data, encoding: .utf8) ?? ""
            print("DemographicDataService: Raw Census response for \(zipcode): \(rawString.prefix(200))")
            
            // Check if response is an error message (not JSON)
            if rawString.hasPrefix("error") {
                print("DemographicDataService: Census API returned error for \(zipcode): \(rawString)")
                completion(nil)
                return
            }
            
            do {
                // Census API returns a raw 2D array: [["header1", "header2", ...], ["value1", "value2", ...]]
                let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String]]
                
                guard let rows = jsonArray, rows.count > 1 else {
                    print("DemographicDataService: Invalid Census API response format - not enough rows")
                    completion(nil)
                    return
                }
                
                let row = rows[1]
                guard row.count >= 3 else {
                    print("DemographicDataService: Incomplete Census data")
                    completion(nil)
                    return
                }
                
                var medianIncomeAnnual = Double(row[0]) ?? 75_000
                let censusRent = Double(row[1]) ?? 1_800
                let population = Int(row[2]) ?? 0
                
                // Apply inflation adjustment to Census rent data (2017-2021 data → 2025/2026)
                // Census ACS 5-year estimates are ~4-6 years old
                let inflationFactor = self?.rentInflationFactor ?? 1.30
                let medianRent = censusRent * inflationFactor
                
                print("DemographicDataService: Census rent $\(Int(censusRent)) adjusted to $\(Int(medianRent)) with \(Int((inflationFactor - 1) * 100))% inflation factor")
                
                // Validate income data - if it seems unreasonable, use regional estimate
                if medianIncomeAnnual < 20_000 || medianIncomeAnnual > 500_000 {
                    print("DemographicDataService: Census income $\(Int(medianIncomeAnnual)) for \(zipcode) seems unreliable, using estimate")
                    medianIncomeAnnual = 75_000
                }
                
                // Convert annual gross income to monthly net (approx 70% after taxes)
                let medianIncomeMonthlyNet = (medianIncomeAnnual / 12) * 0.70
                
                let rentPercentile = self?.calculateRentPercentile(medianRent) ?? 50
                let colIndex = self?.calculateCostOfLivingIndex(medianIncomeAnnual, medianRent, zipcode: zipcode) ?? 100
                let populationDensity = self?.estimatePopulationDensity(population) ?? 10_000
                
                let demographics = ZipcodeDemographics(
                    zipcode: zipcode,
                    medianHouseholdIncome: medianIncomeMonthlyNet,
                    averageRent: medianRent,
                    rentPercentileAboveNational: rentPercentile,
                    populationDensity: populationDensity,
                    costOfLivingIndex: colIndex
                )
                
                print("DemographicDataService: Census data for \(zipcode) - Annual Income: $\(Int(medianIncomeAnnual)), Monthly Net: $\(Int(medianIncomeMonthlyNet)), Rent: $\(Int(medianRent)), COL Index: \(String(format: "%.1f", colIndex))")
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
        
        // Annual income range: $50k - $150k
        let incomeVariation = Double((hash % 100_000))
        let medianIncomeAnnual = 50_000 + incomeVariation
        
        // Convert to monthly net (approx 70% after taxes)
        let medianIncomeMonthlyNet = (medianIncomeAnnual / 12) * 0.70
        
        // Rent range: $800 - $3,500
        let rentVariation = Double((hash / 100) % 2_700)
        let averageRent = 800 + rentVariation
        
        let rentPercentile = calculateRentPercentile(averageRent)
        let colIndex = calculateCostOfLivingIndex(medianIncomeAnnual, averageRent, zipcode: zipcode)
        let populationDensity = 5_000 + (hash % 30_000)
        
        return ZipcodeDemographics(
            zipcode: zipcode,
            medianHouseholdIncome: medianIncomeMonthlyNet,
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
    
    private func calculateCostOfLivingIndex(_ income: Double, _ rent: Double, zipcode: String = "") -> Double {
        // Calculate COL based on rent ratio to national median
        // Only use neighbor averaging (done in fetchWithNeighborValidation) when difference > 30%
        let rentRatio = rent / nationalMedianRent
        let index = rentRatio * 100
        
        return max(index, 50) // Minimum index of 50
    }
    
    private func getMetroAdjustmentFactor(for zipcode: String) -> Double {
        // Adjustment factors for areas where Census rent data is typically underreported
        // due to rent control, stabilization, or market conditions
        
        // Manhattan (100xx)
        if zipcode.hasPrefix("100") || zipcode.hasPrefix("101") || zipcode.hasPrefix("102") {
            return 1.6 // Manhattan is significantly underreported
        }
        
        // Brooklyn (112xx)
        if zipcode.hasPrefix("112") {
            return 1.4
        }
        
        // Jersey City / Hudson County NJ (070xx, 073xx)
        if zipcode.hasPrefix("070") || zipcode.hasPrefix("073") {
            return 1.4
        }
        
        // San Francisco (941xx)
        if zipcode.hasPrefix("941") {
            return 1.5
        }
        
        // Los Angeles (900xx, 901xx, 902xx)
        if zipcode.hasPrefix("900") || zipcode.hasPrefix("901") || zipcode.hasPrefix("902") {
            return 1.3
        }
        
        // Boston (021xx, 022xx)
        if zipcode.hasPrefix("021") || zipcode.hasPrefix("022") {
            return 1.3
        }
        
        // Seattle (981xx)
        if zipcode.hasPrefix("981") {
            return 1.2
        }
        
        // Washington DC (200xx)
        if zipcode.hasPrefix("200") {
            return 1.3
        }
        
        // Default: no adjustment
        return 1.0
    }
    
    private func estimatePopulationDensity(_ population: Int) -> Int {
        let avgZipcodeArea = 10.0
        return Int(Double(population) / avgZipcodeArea)
    }
}
