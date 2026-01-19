import SwiftUI

struct BudgetAnalysisView: View {
    @ObservedObject var budgetAnalysisViewModel: BudgetAnalysisViewModel
    @ObservedObject var monthlyExpensesViewModel: MonthlyExpensesViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var headerView: some View {
        HStack {
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text("Budget Analysis")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: {
                performAnalysis()
            }) {
                if budgetAnalysisViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.15, green: 0.20, blue: 0.35)))
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                }
            }
        }
        .padding(16)
        .background(Color.white)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.93, blue: 0.91)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            if let result = budgetAnalysisViewModel.analysisResult {
                                analysisContentView(result)
                            } else if let error = budgetAnalysisViewModel.errorMessage {
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.red)
                                    
                                    Text("Error")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.black)
                                    
                                    Text(error)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(12)
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(red: 0.50, green: 0.70, blue: 1.0))
                                    
                                    Text("Run Analysis")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.black)
                                    
                                    Text("Click the refresh button to analyze your budget")
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
        .onAppear {
            performAnalysis()
        }
    }
    
    func analysisContentView(_ result: BudgetAnalysisResult) -> some View {
        return VStack(spacing: 20) {
            // Overall Score Card
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Budget Score")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                        
                        Text(String(format: "%.0f", result.overallScore))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(scoreColor(result.overallScore))
                        
                        Text(scoreLabel(result.overallScore))
                            .font(.system(size: 12))
                            .foregroundColor(scoreColor(result.overallScore))
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.90, green: 0.90, blue: 0.95))
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(result.overallScore / 100))
                            .stroke(scoreColor(result.overallScore), lineWidth: 4)
                            .rotationEffect(.degrees(-90))
                        
                        Text(String(format: "%.0f%%", result.overallScore))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(width: 80, height: 80)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            
            // Tier Badge
            if result.isHCOL {
                HStack(spacing: 8) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                    
                    Text("High-Cost Area Tier")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                    
                    Spacer()
                    
                    Text("Flexible rules applied")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                }
                .padding(12)
                .background(Color(red: 1.0, green: 0.95, blue: 0.90))
                .cornerRadius(8)
            }
            
            // Summary
            VStack(alignment: .leading, spacing: 12) {
                Text("Summary")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(result.summary)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                    .lineLimit(nil)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            
            // Breached Rules (if any)
            if !result.breachedRules.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                        
                        Text("Areas to Improve")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(result.breachedRules, id: \.name) { rule in
                            BudgetRuleCard(rule: rule, isBreach: true)
                        }
                    }
                }
                .padding(16)
                .background(Color(red: 1.0, green: 0.95, blue: 0.95))
                .cornerRadius(12)
            }
            
            // Budget Categories (sorted by overage)
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.20, green: 0.60, blue: 0.20))
                    
                    Text("Budget Categories")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(result.categories, id: \.name) { category in
                        BudgetCategoryCard(category: category)
                    }
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
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(generateInsights(), id: \.self) { insight in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                .padding(.top, 2)
                            
                            Text(insight)
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                .lineLimit(nil)
                        }
                        .padding(12)
                        .background(Color(red: 1.0, green: 0.98, blue: 0.95))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    private func performAnalysis() {
        let zipcode = profileViewModel.userProfile?.zipCode ?? ""
        let city = profileViewModel.userProfile?.location ?? ""
        
        budgetAnalysisViewModel.analyzeBudget(
            monthlyNetIncome: profileViewModel.monthlyNetIncome,
            housing: monthlyExpensesViewModel.housing,
            transportation: monthlyExpensesViewModel.transportation,
            carPayment: monthlyExpensesViewModel.carPayment,
            carInsurance: monthlyExpensesViewModel.carInsurance,
            carMaintenance: monthlyExpensesViewModel.carMaintenance,
            groceries: monthlyExpensesViewModel.groceries,
            subscriptions: monthlyExpensesViewModel.subscriptions,
            otherExpenses: monthlyExpensesViewModel.otherExpenses,
            savings: monthlyExpensesViewModel.savings,
            zipcode: zipcode,
            city: city
        )
    }
    
    private func scoreColor(_ score: Double) -> Color {
        if score >= 80 {
            return Color(red: 0.20, green: 0.60, blue: 0.20)
        } else if score >= 60 {
            return Color(red: 0.95, green: 0.70, blue: 0.65)
        } else {
            return Color.red
        }
    }
    
    private func scoreLabel(_ score: Double) -> String {
        if score >= 80 {
            return "Excellent"
        } else if score >= 60 {
            return "Good"
        } else {
            return "Needs Work"
        }
    }
    
    private func generateInsights() -> [String] {
        guard let result = budgetAnalysisViewModel.analysisResult else { return [] }
        
        var insights: [String] = []
        
        // Check for housing overspending
        if let housingRule = result.rules.first(where: { $0.name == "Housing Max" }), housingRule.isBreached {
            insights.append("Your housing costs are significantly higher than recommended. Consider finding more affordable housing.")
        }
        
        // Check for car payment overspending
        if let carRule = result.rules.first(where: { $0.name == "Car Payment Max" }), carRule.isBreached {
            insights.append("Your car payment exceeds the recommended limit. Consider refinancing or choosing a less expensive vehicle.")
        }
        
        // Check for wants overspending
        if let wantsRule = result.rules.first(where: { $0.name == "Wants Budget" }), wantsRule.isBreached {
            insights.append("Your lifestyle spending is above target. Look for opportunities to reduce subscriptions and discretionary expenses.")
        }
        
        // Check for savings shortfall
        if let savingsRule = result.rules.first(where: { $0.name == "Savings Target" }), savingsRule.isBreached {
            insights.append("Your savings rate is below the recommended 20%. Prioritize building an emergency fund.")
        }
        
        // Check for needs overspending
        if let needsRule = result.rules.first(where: { $0.name == "Needs Budget" }), needsRule.isBreached {
            insights.append("Your essential expenses are consuming too much of your income. Review housing, food, and transportation costs.")
        }
        
        // If no breaches, provide positive feedback
        if insights.isEmpty {
            insights.append("Great job! Your budget is well-balanced and aligned with financial best practices.")
        }
        
        return insights
    }
}

// MARK: - Budget Rule Card
struct BudgetRuleCard: View {
    let rule: BudgetRule
    let isBreach: Bool
    
    var statusColor: Color {
        if isBreach {
            return .red
        } else if rule.isWarning {
            return Color(red: 1.0, green: 0.80, blue: 0.0) // Yellow/Orange
        } else {
            return Color(red: 0.20, green: 0.60, blue: 0.20) // Green
        }
    }
    
    var backgroundColor: Color {
        if isBreach {
            return Color(red: 1.0, green: 0.95, blue: 0.95) // Light red
        } else if rule.isWarning {
            return Color(red: 1.0, green: 0.95, blue: 0.85) // Light yellow
        } else {
            return Color(red: 0.95, green: 1.0, blue: 0.95) // Light green
        }
    }
    
    var statusIcon: String {
        if isBreach {
            return "xmark.circle.fill"
        } else if rule.isWarning {
            return "exclamationmark.circle.fill"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 14))
                        .foregroundColor(statusColor)
                    
                    Text(rule.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.0f%%", rule.currentPercentage))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(statusColor)
                    
                    Text("Target: \(String(format: "%.0f%%", rule.targetPercentage))")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                }
            }
            
            Text(rule.suggestion)
                .font(.system(size: 12))
                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                .lineLimit(nil)
        }
        .padding(12)
        .background(backgroundColor)
        .cornerRadius(8)
    }
}

// MARK: - Budget Category Card
struct BudgetCategoryCard: View {
    let category: BudgetCategory
    
    var categoryColor: Color {
        if category.overagePercentage > 10 {
            return .red
        } else if category.overagePercentage > 0 {
            return Color(red: 1.0, green: 0.8, blue: 0.0) // Yellow/Orange
        } else {
            return Color(red: 0.20, green: 0.60, blue: 0.20) // Green
        }
    }
    
    var backgroundColor: Color {
        if category.overagePercentage > 10 {
            return Color(red: 1.0, green: 0.95, blue: 0.95) // Light red
        } else if category.overagePercentage > 0 {
            return Color(red: 1.0, green: 0.95, blue: 0.85) // Light yellow
        } else {
            return Color(red: 0.95, green: 1.0, blue: 0.95) // Light green
        }
    }
    
    var categoryIcon: String {
        if category.overagePercentage > 10 {
            return "xmark.circle.fill"
        } else if category.overagePercentage > 0 {
            return "exclamationmark.circle.fill"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: categoryIcon)
                        .font(.system(size: 14))
                        .foregroundColor(categoryColor)
                    
                    Text(category.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                if category.overagePercentage > 0 {
                    Text(String(format: "+%.0f%%", category.overagePercentage))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(categoryColor)
                } else {
                    Text("On Track")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(categoryColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(category.rules, id: \.name) { rule in
                    HStack {
                        Text(rule.name)
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                        
                        Spacer()
                        
                        Text(String(format: "%.0f%%", rule.currentPercentage))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                    }
                }
            }
            .padding(8)
            .background(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.5))
            .cornerRadius(6)
        }
        .padding(12)
        .background(backgroundColor)
        .cornerRadius(8)
    }
}

#Preview {
    BudgetAnalysisView(
        budgetAnalysisViewModel: BudgetAnalysisViewModel(),
        monthlyExpensesViewModel: MonthlyExpensesViewModel(),
        profileViewModel: ProfileViewModel(),
        isPresented: .constant(true)
    )
}
