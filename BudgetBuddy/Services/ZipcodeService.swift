import Foundation

struct ZipcodeData: Equatable {
    let zipcode: String
    let city: String
    let state: String
    let isMetropolitanArea: Bool
}

struct ZipcodeWithDemographics {
    let zipcode: String
    let city: String
    let state: String
    let isMetropolitanArea: Bool
    let medianHouseholdIncome: Double?
    let averageRent: Double?
    let rentPercentileAboveNational: Double?
}

// Metropolitan areas for classification
private let metropolitanAreas = [
    "New York", "Brooklyn", "Jersey City", "Newark", "Hoboken",
    "San Francisco", "Los Angeles", "Boston", "Washington", "Seattle",
    "Chicago", "Miami", "Denver", "San Antonio", "Portland",
    "Los Altos", "Mountain View", "Sunnyvale", "Menlo Park", "Atherton",
    "Beverly Hills", "Santa Monica", "Newport Beach", "Santa Barbara",
    "Cambridge", "Brookline", "Arlington", "McLean", "Bethesda"
]

class ZipcodeService {
    static let shared = ZipcodeService()
    
    func verifyZipcode(_ zipcode: String, completion: @escaping (ZipcodeData?) -> Void) {
        let cleanedZipcode = zipcode.trimmingCharacters(in: .whitespaces)
        guard cleanedZipcode.count == 5, cleanedZipcode.allSatisfy({ $0.isNumber }) else {
            completion(nil)
            return
        }
        
        // Use ZipCodeAPI (free tier available)
        let urlString = "https://api.zippopotam.us/us/\(cleanedZipcode)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("ZipcodeService: API Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("ZipcodeService: No data received")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let places = json["places"] as? [[String: Any]],
                   let firstPlace = places.first,
                   var city = firstPlace["place name"] as? String,
                   let state = firstPlace["state abbreviation"] as? String {
                    
                    // Normalize Brooklyn to New York for NY zipcodes
                    if state == "NY" && city == "Brooklyn" {
                        city = "New York"
                    }
                    
                    let isMetro = metropolitanAreas.contains { city.contains($0) }
                    
                    let zipcodeData = ZipcodeData(
                        zipcode: cleanedZipcode,
                        city: city,
                        state: state,
                        isMetropolitanArea: isMetro
                    )
                    
                    print("ZipcodeService: Successfully verified \(cleanedZipcode) - \(city), \(state)")
                    completion(zipcodeData)
                } else {
                    print("ZipcodeService: Invalid API response format")
                    completion(nil)
                }
            } catch {
                print("ZipcodeService: JSON Parse Error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func lookupZipcode(_ zipcode: String, completion: @escaping ((city: String, state: String)?) -> Void) {
        verifyZipcode(zipcode) { zipcodeData in
            if let data = zipcodeData {
                completion((city: data.city, state: data.state))
            } else {
                completion(nil)
            }
        }
    }
}
