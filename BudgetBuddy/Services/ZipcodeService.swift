import Foundation

struct ZipcodeData {
    let zipcode: String
    let city: String
    let state: String
}

class ZipcodeService {
    static let shared = ZipcodeService()
    
    // Comprehensive zipcode database for major US areas
    private let zipcodeDatabase: [String: (city: String, state: String)] = [
        // New York Metro
        "10003": ("New York", "NY"), "10007": ("New York", "NY"), "10011": ("New York", "NY"),
        "10012": ("New York", "NY"), "10013": ("New York", "NY"), "10014": ("New York", "NY"),
        "10021": ("New York", "NY"), "10022": ("New York", "NY"), "10023": ("New York", "NY"),
        "10024": ("New York", "NY"), "10028": ("New York", "NY"), "10065": ("New York", "NY"),
        "10075": ("New York", "NY"), "11231": ("Brooklyn", "NY"), "10580": ("Rye", "NY"),
        "11962": ("Sagaponack", "NY"), "11976": ("Water Mill", "NY"),
        
        // New Jersey - Hudson County (Correct Mappings)
        // Bayonne
        "07002": ("Bayonne", "NJ"),
        // East Newark
        "07029": ("East Newark", "NJ"),
        // Guttenberg
        "07093": ("Guttenberg", "NJ"),
        // Hoboken
        "07030": ("Hoboken", "NJ"),
        // Jersey City
        "07302": ("Jersey City", "NJ"), "07303": ("Jersey City", "NJ"), "07304": ("Jersey City", "NJ"),
        "07305": ("Jersey City", "NJ"), "07306": ("Jersey City", "NJ"), "07307": ("Jersey City", "NJ"),
        "07308": ("Jersey City", "NJ"), "07309": ("Jersey City", "NJ"), "07311": ("Jersey City", "NJ"),
        // Kearny
        "07032": ("Kearny", "NJ"),
        // North Bergen
        "07047": ("North Bergen", "NJ"),
        // Secaucus
        "07094": ("Secaucus", "NJ"), "07096": ("Secaucus", "NJ"),
        // Union City
        "07086": ("Union City", "NJ"), "07087": ("Union City", "NJ"),
        // Weehawken
        "07085": ("Weehawken", "NJ"), "07088": ("Weehawken", "NJ"),
        // West New York
        "07092": ("West New York", "NJ"),
        
        // New Jersey - Bergen County
        "07078": ("Short Hills", "NJ"), "07620": ("Alpine", "NJ"), "07632": ("Fort Lee", "NJ"),
        "07677": ("Teaneck", "NJ"), "08247": ("Stone Harbor", "NJ"),
        
        // Connecticut
        "06902": ("Stamford", "CT"), "06905": ("Stamford", "CT"), "06830": ("Greenwich", "CT"),
        
        // San Francisco Bay Area
        "94027": ("Atherton", "CA"), "94022": ("Los Altos", "CA"), "94024": ("Los Altos", "CA"),
        "94025": ("Menlo Park", "CA"), "94028": ("Portola Valley", "CA"), "94043": ("Mountain View", "CA"),
        "94089": ("Sunnyvale", "CA"), "94105": ("San Francisco", "CA"), "94107": ("San Francisco", "CA"),
        "94111": ("San Francisco", "CA"), "94118": ("San Francisco", "CA"), "94123": ("San Francisco", "CA"),
        "94970": ("Stinson Beach", "CA"), "94920": ("Belvedere", "CA"),
        
        // Los Angeles Area
        "90210": ("Beverly Hills", "CA"), "90402": ("Santa Monica", "CA"), "90077": ("Bel-Air", "CA"),
        "92661": ("Newport Beach", "CA"), "92657": ("Newport Beach", "CA"), "92662": ("Newport Beach", "CA"),
        "93108": ("Santa Barbara", "CA"),
        
        // Boston Area
        "02199": ("Boston", "MA"), "02116": ("Boston", "MA"), "02445": ("Brookline", "MA"),
        "02138": ("Cambridge", "MA"), "02493": ("Wellesley", "MA"),
        
        // Washington DC Area
        "20007": ("Washington", "DC"), "20008": ("Washington", "DC"), "22207": ("Arlington", "VA"),
        "22101": ("McLean", "VA"), "22030": ("Fairfax", "VA"), "20815": ("Bethesda", "MD"),
        "20817": ("Bethesda", "MD"),
        
        // Other major metros
        "98101": ("Seattle", "WA"), "98102": ("Seattle", "WA"), "98103": ("Seattle", "WA"),
        "33101": ("Miami", "FL"), "33102": ("Miami", "FL"), "33103": ("Miami", "FL"),
        "60601": ("Chicago", "IL"), "60602": ("Chicago", "IL"), "60603": ("Chicago", "IL"),
        "80201": ("Denver", "CO"), "80202": ("Denver", "CO"), "80203": ("Denver", "CO"),
        "78201": ("San Antonio", "TX"), "78202": ("San Antonio", "TX"), "78203": ("San Antonio", "TX"),
        "97201": ("Portland", "OR"), "97202": ("Portland", "OR"), "97203": ("Portland", "OR")
    ]
    
    func lookupZipcode(_ zipcode: String) -> (city: String, state: String)? {
        let cleanedZipcode = zipcode.trimmingCharacters(in: .whitespaces)
        return zipcodeDatabase[cleanedZipcode]
    }
}
