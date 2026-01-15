import Foundation

struct BudgetRule {
    let name: String
    let isBreached: Bool
    let currentPercentage: Double
    let targetPercentage: Double
    let suggestion: String
    let tier: Int // 1 = Standard, 2 = HCOL
    let isWarning: Bool // True if at or very close to limit (within 1%)
}

struct BudgetAnalysisResult {
    let rules: [BudgetRule]
    let breachedRules: [BudgetRule]
    let overallScore: Double // 0-100
    let summary: String
    let isHCOL: Bool
    let tier: Int // 1 = Standard, 2 = HCOL
}

class BudgetAnalysisService {
    static let shared = BudgetAnalysisService()
    
    func analyzeBudget(
        monthlyNetIncome: Double,
        housing: Double,
        transportation: Double,
        carPayment: Double,
        carInsurance: Double,
        carMaintenance: Double,
        groceries: Double,
        subscriptions: Double,
        otherExpenses: Double,
        savings: Double,
        zipcode: String = "",
        city: String = "",
        isHCOLOverride: Bool? = nil
    ) -> BudgetAnalysisResult {
        guard monthlyNetIncome > 0 else {
            return BudgetAnalysisResult(
                rules: [],
                breachedRules: [],
                overallScore: 0,
                summary: "Please enter a valid monthly net income.",
                isHCOL: false,
                tier: 1
            )
        }
        
        // Determine if user is in HCOL area
        let isHCOL = isHCOLOverride ?? HCOLService.shared.isHCOLArea(zipcode: zipcode, city: city)
        let tier = isHCOL ? 2 : 1
        
        var rules: [BudgetRule] = []
        
        // Calculate totals
        let needs = housing + groceries + transportation
        let wants = subscriptions + otherExpenses
        let carTotal = carPayment + carInsurance + carMaintenance
        
        // Calculate percentages
        let needsPercentage = (needs / monthlyNetIncome) * 100
        let wantsPercentage = (wants / monthlyNetIncome) * 100
        let savingsPercentage = (savings / monthlyNetIncome) * 100
        let housingPercentage = (housing / monthlyNetIncome) * 100
        let carPaymentPercentage = (carPayment / monthlyNetIncome) * 100
        let carTotalPercentage = (carTotal / monthlyNetIncome) * 100
        
        // Determine thresholds based on tier
        let needsTarget = isHCOL ? 55 : 50
        let housingTarget = isHCOL ? 30 : 25
        let housingMax = isHCOL ? 35 : 30
        
        // Rule 1: Needs (Tier 1: ≤ 50%, Tier 2: ≤ 55%)
        // Warning if 50-51% (Tier 1) or 55-60% (Tier 2), Breach if > 51% (Tier 1) or > 60% (Tier 2)
        let needsWarning = isHCOL ? (needsPercentage > 55.0 && needsPercentage <= 60.0) : (needsPercentage > 50.0 && needsPercentage <= 51.0)
        let needsBreached = isHCOL ? (needsPercentage > 60) : (needsPercentage > 51.0)
        let needsSuggestion: String
        if isHCOL {
            if needsPercentage <= 55 {
                needsSuggestion = "Your Needs are \(String(format: "%.0f", needsPercentage))% of NMI, which is acceptable for a high-cost area. Try to keep this under 55% if possible."
            } else if needsPercentage <= 60 {
                needsSuggestion = "Your Needs are \(String(format: "%.0f", needsPercentage))% of NMI, which is high for a major metropolitan area. To maintain a 20% savings rate, your Lifestyle (Wants) spending must be strictly limited to 20% of NMI."
            } else {
                needsSuggestion = "Your Needs exceed 60% of NMI, which is unsustainable even for high-cost areas. You must reduce essential expenses or increase income to maintain adequate savings."
            }
        } else {
            needsSuggestion = needsBreached
                ? "Your Needs are \(String(format: "%.0f", needsPercentage))% of NMI, which is high. Try to reduce essential expenses to the recommended 50%. Focus on Housing, Groceries, and Transportation."
                : "Your Needs are \(String(format: "%.0f", needsPercentage))% of NMI, which is within the recommended 50% target. Great job!"
        }
        rules.append(BudgetRule(
            name: "Needs Budget",
            isBreached: needsBreached,
            currentPercentage: needsPercentage,
            targetPercentage: Double(needsTarget),
            suggestion: needsSuggestion,
            tier: tier,
            isWarning: needsWarning
        ))
        
        // Rule 2: Wants (Tier 1: ≤ 30%, Tier 2: ≤ 20% if Needs > 55%)
        let wantsTarget = (isHCOL && needsPercentage > 55.0) ? 20 : 30
        let wantsBreached = wantsPercentage > Double(wantsTarget)
        let wantsSuggestion: String
        if isHCOL && needsPercentage > 55.0 {
            wantsSuggestion = wantsBreached
                ? "Your Wants are \(String(format: "%.0f", wantsPercentage))% of NMI. Since your Needs are elevated, you must strictly limit Wants to 20% to preserve the 20% minimum savings rate."
                : "Your Wants are \(String(format: "%.0f", wantsPercentage))% of NMI, which appropriately accommodates your higher housing costs while maintaining savings."
        } else {
            wantsSuggestion = wantsBreached
                ? "Your Wants are \(String(format: "%.0f", wantsPercentage))% of NMI, which exceeds the recommended 30%. Consider reducing Subscriptions or Other Expenses."
                : "Your Wants are \(String(format: "%.0f", wantsPercentage))% of NMI, which is within the recommended 30% target. Excellent!"
        }
        rules.append(BudgetRule(
            name: "Wants Budget",
            isBreached: wantsBreached,
            currentPercentage: wantsPercentage,
            targetPercentage: Double(wantsTarget),
            suggestion: wantsSuggestion,
            tier: tier,
            isWarning: false
        ))
        
        // Rule 3: Savings (≥ 20% for Tier 1, ≥ 20% for Tier 2)
        let savingsTarget = 20
        let savingsBreached = savingsPercentage < 20.0
        let savingsSuggestion: String
        if isHCOL && needsPercentage > 55.0 {
            savingsSuggestion = savingsBreached
                ? "Your Savings are \(String(format: "%.0f", savingsPercentage))% of NMI. Given your elevated housing costs, you must prioritize reaching 20% savings (\(String(format: "$%.0f", monthlyNetIncome * 0.20))) by reducing Wants."
                : "Your Savings are \(String(format: "%.0f", savingsPercentage))% of NMI, which maintains the critical 20% minimum despite higher housing costs. Excellent!"
        } else {
            savingsSuggestion = savingsBreached
                ? "Your Savings are \(String(format: "%.0f", savingsPercentage))% of NMI, which is below the recommended 20%. Try to increase your monthly savings to \(String(format: "$%.0f", monthlyNetIncome * 0.20))."
                : "Your Savings are \(String(format: "%.0f", savingsPercentage))% of NMI, which meets the recommended 20% target. Outstanding!"
        }
        rules.append(BudgetRule(
            name: "Savings Target",
            isBreached: savingsBreached,
            currentPercentage: savingsPercentage,
            targetPercentage: Double(savingsTarget),
            suggestion: savingsSuggestion,
            tier: tier,
            isWarning: false
        ))
        
        // Rule 4: Housing Max (Tier 1: ≤ 25%, Tier 2: ≤ 30% ideal, ≤ 35% acceptable)
        let housingBreached = isHCOL ? (housingPercentage > 35) : (housingPercentage > 25)
        let housingWarning = isHCOL && housingPercentage > 30
        let housingSuggestion: String
        if isHCOL {
            if housingPercentage <= 30 {
                housingSuggestion = "Your Housing is \(String(format: "%.0f", housingPercentage))% of NMI, which is ideal for a high-cost area. Excellent!"
            } else if housingPercentage <= 35 {
                housingSuggestion = "Your Housing is \(String(format: "%.0f", housingPercentage))% of NMI, which is acceptable for a major metropolitan area but at the upper limit. Consider if you can reduce to 30%."
            } else {
                housingSuggestion = "Your Housing is \(String(format: "%.0f", housingPercentage))% of NMI, which exceeds the acceptable range even for high-cost areas. You must reduce housing costs to \(String(format: "$%.0f", monthlyNetIncome * 0.35)) or less."
            }
        } else {
            housingSuggestion = housingBreached
                ? "Your Housing is \(String(format: "%.0f", housingPercentage))% of NMI, which is high. Try to reduce this cost to the recommended 25% or \(String(format: "$%.0f", monthlyNetIncome * 0.25))."
                : "Your Housing is \(String(format: "%.0f", housingPercentage))% of NMI, which is within the recommended 25% target. Perfect!"
        }
        rules.append(BudgetRule(
            name: "Housing Max",
            isBreached: housingBreached,
            currentPercentage: housingPercentage,
            targetPercentage: Double(housingTarget),
            suggestion: housingSuggestion,
            tier: tier,
            isWarning: false
        ))
        
        // Rule 5: Car Payment Max (≤ 10%) - Non-negotiable across all tiers
        // Warning if 10-11%, Breach if > 11%
        let carPaymentWarning = carPaymentPercentage > 10.0 && carPaymentPercentage <= 11.0
        let carPaymentBreached = carPaymentPercentage > 11.0
        let carPaymentSuggestion: String
        if carPaymentBreached {
            carPaymentSuggestion = "Your Car Payment is \(String(format: "%.0f", carPaymentPercentage))% of NMI, which exceeds the recommended 10%. Consider refinancing or choosing a less expensive vehicle."
        } else if carPaymentWarning {
            carPaymentSuggestion = "Your Car Payment is \(String(format: "%.0f", carPaymentPercentage))% of NMI, which is slightly above the recommended 10%. This needs work. Consider refinancing to lower your monthly payment."
        } else {
            carPaymentSuggestion = "Your Car Payment is \(String(format: "%.0f", carPaymentPercentage))% of NMI, which is within the recommended 10% target. Good!"
        }
        rules.append(BudgetRule(
            name: "Car Payment Max",
            isBreached: carPaymentBreached,
            currentPercentage: carPaymentPercentage,
            targetPercentage: 10,
            suggestion: carPaymentSuggestion,
            tier: tier,
            isWarning: carPaymentWarning
        ))
        
        // Rule 6: Total Car Cost Max (≤ 15%) - Non-negotiable across all tiers
        // Warning if 15-16%, Breach if > 16%
        let carTotalWarning = carTotalPercentage > 15.0 && carTotalPercentage <= 16.0
        let carTotalBreached = carTotalPercentage > 16.0
        let carTotalSuggestion: String
        if carTotalBreached {
            carTotalSuggestion = "Your Total Car Costs (Payment + Transportation) are \(String(format: "%.0f", carTotalPercentage))% of NMI, which exceeds the recommended 15%. Try to reduce either your car payment or transportation costs."
        } else if carTotalWarning {
            carTotalSuggestion = "Your Total Car Costs are \(String(format: "%.0f", carTotalPercentage))% of NMI, which is slightly above the recommended 15%. This needs work. Consider reducing transportation or car payment expenses."
        } else {
            carTotalSuggestion = "Your Total Car Costs are \(String(format: "%.0f", carTotalPercentage))% of NMI, which is within the recommended 15% target. Excellent!"
        }
        rules.append(BudgetRule(
            name: "Total Car Cost Max",
            isBreached: carTotalBreached,
            currentPercentage: carTotalPercentage,
            targetPercentage: 15,
            suggestion: carTotalSuggestion,
            tier: tier,
            isWarning: carTotalWarning
        ))
        
        // Rule 7: Annual Savings Target (≥ 15%) - Non-negotiable across all tiers
        // Warning if 14-15%, Breach if < 14%
        let annualSavingsWarning = savingsPercentage >= 14.0 && savingsPercentage < 15.0
        let annualSavingsBreached = savingsPercentage < 14.0
        let annualSavingsSuggestion: String
        if annualSavingsBreached {
            annualSavingsSuggestion = "Your Savings are \(String(format: "%.0f", savingsPercentage))% of NMI, which is below the recommended 15% for long-term goals. Aim to save at least \(String(format: "$%.0f", monthlyNetIncome * 0.15)) monthly."
        } else if annualSavingsWarning {
            annualSavingsSuggestion = "Your Savings are \(String(format: "%.0f", savingsPercentage))% of NMI, which is close to the 15% target. This needs work. Try to reach \(String(format: "$%.0f", monthlyNetIncome * 0.15)) monthly."
        } else {
            annualSavingsSuggestion = "Your Savings are \(String(format: "%.0f", savingsPercentage))% of NMI, which meets the recommended 15% annual savings target. Great!"
        }
        rules.append(BudgetRule(
            name: "Annual Savings Target",
            isBreached: annualSavingsBreached,
            currentPercentage: savingsPercentage,
            targetPercentage: 15,
            suggestion: annualSavingsSuggestion,
            tier: tier,
            isWarning: annualSavingsWarning
        ))
        
        // Calculate breached rules
        let breachedRules = rules.filter { $0.isBreached }
        
        // Calculate overall score (0-100)
        let totalRules = rules.count
        let passedRules = totalRules - breachedRules.count
        let overallScore = (Double(passedRules) / Double(totalRules)) * 100
        
        // Generate summary
        let summary: String
        let tierLabel = isHCOL ? " (High-Cost Area)" : ""
        if breachedRules.isEmpty {
            summary = "Excellent! Your budget is perfectly aligned with all financial guidelines\(tierLabel). Keep up the great work!"
        } else if breachedRules.count <= 2 {
            summary = "Good progress! You're following most guidelines\(tierLabel). Focus on the \(breachedRules.count) area(s) that need adjustment."
        } else {
            summary = "Your budget needs attention in \(breachedRules.count) areas\(tierLabel). Review the suggestions below to get back on track."
        }
        
        return BudgetAnalysisResult(
            rules: rules,
            breachedRules: breachedRules,
            overallScore: overallScore,
            summary: summary,
            isHCOL: isHCOL,
            tier: tier
        )
    }
}
