import Foundation

struct MetropolitanArea {
    let name: String
    let zipcodes: [String]
    let averageRent: Double
    let averageIncome: Double
    let rentPercentileAboveNational: Double
}

class MetropolitanAreaService {
    static let shared = MetropolitanAreaService()
    
    private let metropolitanAreas: [String: MetropolitanArea] = [
        "NYC": MetropolitanArea(
            name: "New York City Metro",
            zipcodes: ["10003", "10007", "10011", "10012", "10013", "10014", "10021", "10022", "10023", "10024", "10028", "10065", "10075", "11231", "10580", "11962", "11976"],
            averageRent: 3_850,
            averageIncome: 110_000,
            rentPercentileAboveNational: 95
        ),
        "NJ_HUDSON": MetropolitanArea(
            name: "New Jersey Hudson County",
            zipcodes: ["07002", "07029", "07093", "07030", "07302", "07303", "07304", "07305", "07306", "07307", "07308", "07309", "07311", "07032", "07047", "07094", "07096", "07086", "07087", "07085", "07088", "07092", "07078", "07620", "07632", "07677", "08247"],
            averageRent: 2_450,
            averageIncome: 78_000,
            rentPercentileAboveNational: 85
        ),
        "SF_BAY": MetropolitanArea(
            name: "San Francisco Bay Area",
            zipcodes: ["94027", "94022", "94024", "94025", "94028", "94043", "94089", "94105", "94107", "94111", "94118", "94123", "94970", "94920"],
            averageRent: 3_900,
            averageIncome: 185_000,
            rentPercentileAboveNational: 95
        ),
        "LA": MetropolitanArea(
            name: "Los Angeles Metro",
            zipcodes: ["90210", "90402", "90077", "92661", "92657", "92662", "93108"],
            averageRent: 4_050,
            averageIncome: 200_000,
            rentPercentileAboveNational: 95
        ),
        "BOSTON": MetropolitanArea(
            name: "Boston Metro",
            zipcodes: ["02199", "02116", "02445", "02138", "02493"],
            averageRent: 2_700,
            averageIncome: 105_000,
            rentPercentileAboveNational: 87
        ),
        "DC": MetropolitanArea(
            name: "Washington DC Metro",
            zipcodes: ["20007", "20008", "22207", "22101", "22030", "20815", "20817"],
            averageRent: 2_850,
            averageIncome: 130_000,
            rentPercentileAboveNational: 89
        ),
        "SEATTLE": MetropolitanArea(
            name: "Seattle Metro",
            zipcodes: ["98101", "98102", "98103"],
            averageRent: 2_600,
            averageIncome: 115_000,
            rentPercentileAboveNational: 86
        ),
        "MIAMI": MetropolitanArea(
            name: "Miami Metro",
            zipcodes: ["33101", "33102", "33103"],
            averageRent: 2_200,
            averageIncome: 68_000,
            rentPercentileAboveNational: 82
        ),
        "CHICAGO": MetropolitanArea(
            name: "Chicago Metro",
            zipcodes: ["60601", "60602", "60603"],
            averageRent: 2_100,
            averageIncome: 92_000,
            rentPercentileAboveNational: 80
        ),
        "DENVER": MetropolitanArea(
            name: "Denver Metro",
            zipcodes: ["80201", "80202", "80203"],
            averageRent: 2_300,
            averageIncome: 98_000,
            rentPercentileAboveNational: 83
        ),
        "PORTLAND": MetropolitanArea(
            name: "Portland Metro",
            zipcodes: ["97201", "97202", "97203"],
            averageRent: 1_900,
            averageIncome: 88_000,
            rentPercentileAboveNational: 78
        )
    ]
    
    func getMetropolitanArea(for zipcode: String) -> MetropolitanArea? {
        for area in metropolitanAreas.values {
            if area.zipcodes.contains(zipcode) {
                return area
            }
        }
        return nil
    }
    
    func isInMetropolitanArea(_ zipcode: String) -> Bool {
        return getMetropolitanArea(for: zipcode) != nil
    }
    
    func getMetropolitanAreaName(for zipcode: String) -> String? {
        return getMetropolitanArea(for: zipcode)?.name
    }
    
    func isHighRentMetropolitanArea(_ zipcode: String) -> Bool {
        guard let area = getMetropolitanArea(for: zipcode) else {
            return false
        }
        return area.rentPercentileAboveNational >= 85
    }
    
    func getAllMetropolitanAreas() -> [MetropolitanArea] {
        return Array(metropolitanAreas.values).sorted { $0.averageRent > $1.averageRent }
    }
    
    func getHighRentMetropolitanAreas() -> [MetropolitanArea] {
        return getAllMetropolitanAreas().filter { $0.rentPercentileAboveNational >= 85 }
    }
}
