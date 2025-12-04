import Foundation

class HCOLService {
    static let shared = HCOLService()
    
    // Comprehensive HCOL zipcodes from major metropolitan areas
    private let hcolZipcodes: Set<String> = [
        // New York-Newark-Jersey City Metropolitan Area (NY, NJ, CT)
        // Manhattan
        "10003", "10007", "10011", "10012", "10013", "10014", "10021", "10022", "10023", "10024", "10028", "10065", "10075",
        // Outer Boroughs/Suburbs
        "11231", "10580", "11962", "11976",
        // New Jersey - Bergen County and Northern NJ
        "07078", "07620", "08247", "07632", "07677",
        // Hudson County, New Jersey (all zipcodes)
        "07001", "07002", "07003", "07004", "07005", "07006", "07007", "07008", "07009", "07010",
        "07011", "07012", "07013", "07014", "07015", "07016", "07017", "07018", "07019", "07020",
        "07021", "07022", "07023", "07024", "07025", "07026", "07027", "07028", "07029", "07030",
        "07031", "07032", "07033", "07034", "07035", "07036", "07037", "07038", "07039", "07040",
        "07041", "07042", "07043", "07044", "07045", "07046", "07047", "07048", "07049", "07050",
        "07051", "07052", "07053", "07054", "07055", "07056", "07057", "07058", "07059", "07060",
        "07061", "07062", "07063", "07064", "07065", "07066", "07067", "07068", "07069", "07070",
        "07071", "07072", "07073", "07074", "07075", "07076", "07077", "07079", "07080", "07081",
        "07082", "07083", "07084", "07085", "07086", "07087", "07088", "07089", "07090", "07091",
        "07092", "07093", "07094", "07095", "07096", "07097", "07098", "07099",
        // Connecticut - Bridgeport-Stamford-Norwalk metro
        "06902", "06905", "06830",
        
        // San Francisco Bay Area (CA)
        // Silicon Valley/Peninsula
        "94027", "94022", "94024", "94025", "94028", "94043", "94089",
        // San Francisco City
        "94105", "94107", "94111", "94118", "94123",
        // Marin County
        "94970", "94920",
        
        // Greater Los Angeles Area (CA)
        // Los Angeles County
        "90210", "90402", "90077",
        // Orange County
        "92661", "92657", "92662",
        // Santa Barbara County
        "93108",
        
        // Boston-Cambridge-Newton Metropolitan Area (MA, NH, RI)
        // Massachusetts
        "02199", "02116", "02445", "02138", "02493",
        
        // Washington-Arlington-Alexandria Metropolitan Area (DC, VA, MD)
        // Washington D.C.
        "20007", "20008",
        // Virginia - Northern Virginia
        "22207", "22101", "22030",
        // Maryland - Bethesda-Gaithersburg-Frederick
        "20815", "20817",
        
        // Additional major metros (prefix-based for broader coverage)
        // Seattle (98)
        "98", 
        // Miami (33)
        "33",
        // Chicago (60, 61)
        "60", "61",
        // Denver (80)
        "80",
        // Austin (78)
        "78",
        // Portland (97)
        "97"
    ]
    
    private let hcolCities: Set<String> = [
        // New York Metro
        "Manhattan", "Brooklyn", "Queens", "New York", "TriBeCa", "Chelsea", "SoHo", "Greenwich Village",
        "Rye", "Sagaponack", "Water Mill", "Short Hills", "Alpine", "Stone Harbor", "Bergen County",
        "Stamford", "Greenwich", "Bridgeport", "Norwalk",
        
        // Hudson County, New Jersey
        "Jersey City", "Hoboken", "Weehawken", "Union City", "West New York", "Guttenberg", "North Bergen",
        "Secaucus", "Kearny", "Harrison", "East Newark", "Hudson County",
        
        // San Francisco Bay Area
        "San Francisco", "Atherton", "Los Altos", "Menlo Park", "Portola Valley", "Mountain View",
        "Sunnyvale", "Stinson Beach", "Belvedere", "Tiburon", "Marin County",
        
        // Los Angeles Area
        "Los Angeles", "Beverly Hills", "Santa Monica", "Bel-Air", "Brentwood", "Newport Beach",
        "Santa Barbara", "Montecito", "Orange County",
        
        // Boston Metro
        "Boston", "Cambridge", "Brookline", "Wellesley", "Cape Cod", "Barnstable",
        
        // Washington DC Metro
        "Washington", "Georgetown", "Arlington", "McLean", "Fairfax", "Bethesda", "Gaithersburg",
        
        // Other major metros
        "Seattle", "Bellevue", "Redmond", "Miami", "Miami Beach", "Chicago", "Evanston",
        "Denver", "Boulder", "Austin", "San Antonio", "Portland", "Beaverton"
    ]
    
    func isHCOLArea(zipcode: String, city: String) -> Bool {
        let normalizedZipcode = zipcode.trimmingCharacters(in: .whitespaces)
        let normalizedCity = city.trimmingCharacters(in: .whitespaces)
        
        // Check by exact zipcode match first
        if hcolZipcodes.contains(normalizedZipcode) {
            return true
        }
        
        // Check by zipcode prefix (first 2-5 digits for broader coverage)
        if normalizedZipcode.count >= 2 {
            let prefix2 = String(normalizedZipcode.prefix(2))
            if hcolZipcodes.contains(prefix2) {
                return true
            }
        }
        
        // Check by city name (case-insensitive exact match)
        if hcolCities.contains(normalizedCity) {
            return true
        }
        
        // Check if city contains any HCOL city name (case-insensitive partial match)
        for hcolCity in hcolCities {
            if normalizedCity.localizedCaseInsensitiveContains(hcolCity) {
                return true
            }
        }
        
        return false
    }
}
