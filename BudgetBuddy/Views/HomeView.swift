import SwiftUI

struct HomeView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var monthlyExpensesViewModel: MonthlyExpensesViewModel
    @StateObject private var budgetAnalysisViewModel = BudgetAnalysisViewModel()
    @State private var showSettings = false
    @State private var isEditingExpenses = false
    @State private var showAnalysis = false
    @State private var showNeighborhoodComparison = false
    @State private var tempNetIncome: String = ""
    @State private var isEditingIncome = false
    @State private var showCOLInfo = false
    
    private func calculateTotalExpenses() -> Double {
        let housing = Double(monthlyExpensesViewModel.housing) ?? 0
        let transportation = Double(monthlyExpensesViewModel.transportation) ?? 0
        let carPayment = Double(monthlyExpensesViewModel.carPayment) ?? 0
        let carInsurance = Double(monthlyExpensesViewModel.carInsurance) ?? 0
        let carMaintenance = Double(monthlyExpensesViewModel.carMaintenance) ?? 0
        let groceries = Double(monthlyExpensesViewModel.groceries) ?? 0
        let subscriptions = Double(monthlyExpensesViewModel.subscriptions) ?? 0
        let otherExpenses = Double(monthlyExpensesViewModel.otherExpenses) ?? 0
        let savings = Double(monthlyExpensesViewModel.savings) ?? 0
        let dependent = monthlyExpensesViewModel.showDependentExpenses ? (Double(monthlyExpensesViewModel.dependentExpenses) ?? 0) : 0
        
        return housing + transportation + carPayment + carInsurance + carMaintenance + groceries + subscriptions + otherExpenses + savings + dependent
    }
    
    private func getBalanceInfo() -> (totalExpenses: Double, monthlyNetIncome: Double, remainingBalance: Double, isOverspending: Bool) {
        let totalExpenses = calculateTotalExpenses()
        let monthlyNetIncome = Double(profileViewModel.monthlyNetIncome) ?? 0
        let remainingBalance = monthlyNetIncome - totalExpenses
        let isOverspending = remainingBalance < 0
        
        return (totalExpenses, monthlyNetIncome, remainingBalance, isOverspending)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.96, green: 0.93, blue: 0.91)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: "banknote")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                
                                Text("Your Budget")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            
                            Text("Hi \(authViewModel.currentUser?.firstName ?? "User")!")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                        }
                        
                        Spacer()
                        
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Donut Chart Card
                            VStack(spacing: 20) {
                                DonutChartView(
                                    housing: monthlyExpensesViewModel.housing,
                                    transportation: monthlyExpensesViewModel.transportation,
                                    carPayment: monthlyExpensesViewModel.carPayment,
                                    carInsurance: monthlyExpensesViewModel.carInsurance,
                                    carMaintenance: monthlyExpensesViewModel.carMaintenance,
                                    groceries: monthlyExpensesViewModel.groceries,
                                    subscriptions: monthlyExpensesViewModel.subscriptions,
                                    otherExpenses: monthlyExpensesViewModel.otherExpenses,
                                    savings: monthlyExpensesViewModel.savings
                                )
                                
                                // Legend
                                VStack(alignment: .leading, spacing: 12) {
                                    ExpenseLegendItem(color: Color(red: 0.95, green: 0.70, blue: 0.65), label: "Housing", amount: monthlyExpensesViewModel.housing)
                                    ExpenseLegendItem(color: Color(red: 0.95, green: 0.85, blue: 0.75), label: "Transport", amount: monthlyExpensesViewModel.transportation)
                                    ExpenseLegendItem(color: Color(red: 0.95, green: 0.70, blue: 0.65), label: "Car", amount: monthlyExpensesViewModel.carPayment)
                                    ExpenseLegendItem(color: Color(red: 0.85, green: 0.75, blue: 0.90), label: "Groceries", amount: monthlyExpensesViewModel.groceries)
                                    ExpenseLegendItem(color: Color(red: 0.75, green: 0.90, blue: 0.85), label: "Subscriptions", amount: monthlyExpensesViewModel.subscriptions)
                                    ExpenseLegendItem(color: Color(red: 0.90, green: 0.80, blue: 0.85), label: "Other", amount: monthlyExpensesViewModel.otherExpenses)
                                    
                                    Divider()
                                        .padding(.vertical, 8)
                                    
                                    let balanceForLegend = getBalanceInfo()
                                    
                                    // Warning message if overspending (inside legend)
                                    if balanceForLegend.isOverspending && balanceForLegend.totalExpenses > 0 {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.system(size: 16))
                                                
                                                Text("You spend more than you make")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.red)
                                            }
                                            
                                            Text("Verify your expenses and lower spending to stay within your monthly net income of $\(String(format: "%.2f", balanceForLegend.monthlyNetIncome))")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                        }
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(red: 1, green: 0.9, blue: 0.9))
                                        .cornerRadius(8)
                                    }
                                    
                                    HStack {
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(balanceForLegend.isOverspending ? Color(red: 1, green: 0.85, blue: 0.85) : Color(red: 0.85, green: 0.95, blue: 0.85))
                                                .frame(width: 12, height: 12)
                                            
                                            Text("Remaining")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(balanceForLegend.isOverspending ? .red : Color(red: 0.20, green: 0.60, blue: 0.20))
                                        }
                                        
                                        Spacer()
                                        
                                        Text("$\(String(format: "%.2f", balanceForLegend.remainingBalance))")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(balanceForLegend.isOverspending ? .red : Color(red: 0.20, green: 0.60, blue: 0.20))
                                    }
                                    .padding(12)
                                    .background(balanceForLegend.isOverspending ? Color(red: 1, green: 0.95, blue: 0.95) : Color(red: 0.95, green: 1.0, blue: 0.95))
                                    .cornerRadius(8)
                                }
                                
                                // Edit Expenses Button
                                Button(action: { isEditingExpenses = true }) {
                                    HStack {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.system(size: 18))
                                        
                                        Text("Edit Expenses")
                                            .font(.system(size: 16, weight: .semibold))
                                        
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(16)
                                    .foregroundColor(.white)
                                    .background(Color(red: 0.15, green: 0.20, blue: 0.35))
                                    .cornerRadius(16)
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            
                            // Net Income Editor Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Monthly Net Income")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                        
                                        if isEditingIncome {
                                            HStack {
                                                Text("$")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                                
                                                TextField("0.00", text: $tempNetIncome)
                                                    .keyboardType(.decimalPad)
                                                    .font(.system(size: 16, weight: .semibold))
                                            }
                                            .padding(12)
                                            .background(Color(red: 0.96, green: 0.93, blue: 0.91))
                                            .cornerRadius(8)
                                        } else {
                                            Text(formatCurrency(Double(profileViewModel.monthlyNetIncome) ?? 0))
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if isEditingIncome {
                                        HStack(spacing: 8) {
                                            Button(action: {
                                                if !tempNetIncome.isEmpty, Double(tempNetIncome) != nil {
                                                    profileViewModel.monthlyNetIncome = tempNetIncome
                                                    isEditingIncome = false
                                                }
                                            }) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(Color(red: 0.20, green: 0.60, blue: 0.20))
                                            }
                                            
                                            Button(action: {
                                                isEditingIncome = false
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    } else {
                                        Button(action: {
                                            tempNetIncome = profileViewModel.monthlyNetIncome
                                            isEditingIncome = true
                                        }) {
                                            Image(systemName: "pencil.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            // Savings Health Card
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Savings Health")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text("Based on your age group (\(profileViewModel.userProfile?.age ?? 0)s)")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.90))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                }
                                
                                // Savings Stats
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("You Save")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.90))
                                        
                                        Text(String(format: "%.1f%%", calculateSavingsPercentage()))
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.20, green: 0.25, blue: 0.40))
                                    .cornerRadius(12)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Recommended")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.90))
                                        
                                        Text(String(format: "%.0f%%", getRecommendedSavingsForAge()))
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(Color(red: 0.50, green: 0.90, blue: 0.50))
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.20, green: 0.25, blue: 0.40))
                                    .cornerRadius(12)
                                }
                                
                                // Insight text
                                HStack(spacing: 8) {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(red: 0.50, green: 0.80, blue: 1.0))
                                    
                                    Text("Avg American your age saves ~\(String(format: "%.0f%%", getAverageSavingsForAge()))")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(red: 0.50, green: 0.80, blue: 1.0))
                                }
                            }
                            .padding(20)
                            .background(Color(red: 0.15, green: 0.20, blue: 0.35))
                            .cornerRadius(16)
                            
                            // 50/30/20 Reality Check
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.shield.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                    
                                    Text("50/30/20 Reality Check")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                
                                // Needs (50%)
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Needs (Target 50%)")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                        
                                        Spacer()
                                        
                                        Text(String(format: "%.0f%%", calculateNeedsPercentage()))
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(getNeedsColor())
                                    }
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color(red: 0.90, green: 0.90, blue: 0.95))
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(getNeedsBarColor())
                                                .frame(width: geometry.size.width * CGFloat(getNeedsBarFillPercentage()))
                                        }
                                    }
                                    .frame(height: 8)
                                }
                                
                                // Wants (30%)
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Wants (Target 30%)")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                        
                                        Spacer()
                                        
                                        Text(String(format: "%.0f%%", calculateWantsPercentage()))
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(getWantsColor())
                                    }
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color(red: 0.90, green: 0.90, blue: 0.95))
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(getWantsBarColor())
                                                .frame(width: geometry.size.width * CGFloat(getWantsBarFillPercentage()))
                                        }
                                    }
                                    .frame(height: 8)
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            
                            // Cost of Living Index
                            if let colIndex = profileViewModel.demographicData?.costOfLivingIndex {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(red: 0.50, green: 0.70, blue: 1.0))
                                        
                                        Text("Cost of Living Index")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        Button(action: { showCOLInfo = true }) {
                                            Image(systemName: "info.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(red: 0.50, green: 0.70, blue: 1.0))
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Your Area Index")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                                
                                                Text(String(format: "%.1f", colIndex))
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text("USA Average: 100")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                                
                                                let difference = colIndex - 100
                                                let differenceText = String(format: "%+.1f", difference)
                                                let differenceColor: Color = difference > 0 ? .red : Color(red: 0.20, green: 0.60, blue: 0.20)
                                                
                                                Text(differenceText)
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(differenceColor)
                                            }
                                        }
                                        .padding(12)
                                        .background(Color(red: 0.98, green: 0.96, blue: 0.94))
                                        .cornerRadius(8)
                                        
                                        HStack(spacing: 8) {
                                            Image(systemName: "info.circle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(red: 0.50, green: 0.70, blue: 1.0))
                                            
                                            Text(colIndex > 100 ? "Your area has a higher cost of living than the national average." : "Your area has a lower cost of living than the national average.")
                                                .font(.system(size: 11))
                                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                                .lineLimit(nil)
                                        }
                                        .padding(12)
                                        .background(Color(red: 0.95, green: 0.98, blue: 1.0))
                                        .cornerRadius(8)
                                    }
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                            
                            // AI Analysis Unlock Card
                            VStack(spacing: 16) {
                                VStack(spacing: 12) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(red: 0.50, green: 0.70, blue: 1.0))
                                    
                                    Text("Unlock AI Analysis")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                    
                                    Text("Get personalized grading and tips based on your profile.")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.top, 20)
                                
                                Button(action: { showAnalysis = true }) {
                                    Text("Analyze My Budget")
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(16)
                                        .foregroundColor(.white)
                                        .background(Color(red: 0.15, green: 0.20, blue: 0.35))
                                        .cornerRadius(16)
                                }
                                
                                Text("3 free analysis remaining")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(20)
                            .background(Color(red: 0.98, green: 0.96, blue: 0.94))
                            .cornerRadius(16)
                            
                            // Financial Wisdom Card
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                    
                                    Text("Financial Wisdom")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                }
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    // Tip 1
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("1")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("The 50/30/20 Rule")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                            
                                            Text("suggests spending 50% on Needs, 30% on Wants, and 20% on Savings.")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                        }
                                    }
                                    
                                    // Tip 2
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("2")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("An Emergency Fund")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                            
                                            Text("should cover 3-6 months of essential expenses.")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                        }
                                    }
                                    
                                    // Tip 3
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("3")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("High-interest debt")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                            
                                            Text("(like credit cards) should generally be paid off before aggressive investing.")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                        }
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            
                            // Compare to Neighborhood Card
                            VStack(alignment: .leading, spacing: 12) {
                                Button(action: {
                                    showNeighborhoodComparison = true
                                }) {
                                    HStack {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 16))
                                        
                                        Text("Compare to Neighborhood")
                                            .font(.system(size: 14, weight: .semibold))
                                        
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(14)
                                    .foregroundColor(.white)
                                    .background(Color(red: 0.15, green: 0.20, blue: 0.35))
                                    .cornerRadius(12)
                                }
                                
                                Text("See how you stack up against your area")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        .padding(20)
                    }
                }
                
                // Cost of Living Info Popup (full screen overlay)
                if showCOLInfo {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .transition(.opacity)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("What is Cost of Living Index?")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Button(action: { showCOLInfo = false }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Definition")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                
                                Text("The Cost of Living Index measures the relative expense of living in a specific area compared to a national baseline. An index of 100 represents the national average.")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                    .lineLimit(nil)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Nationwide Average Breakdown")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Housing (28%)")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                                Text("Rent, property prices, home maintenance")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                            }
                                            Spacer()
                                            Text("$1,400/mo")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                        }
                                    }
                                    .padding(10)
                                    .background(Color(red: 0.98, green: 0.96, blue: 0.94))
                                    .cornerRadius(6)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Groceries & Food (12%)")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                                Text("Supermarket items, restaurant prices")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                            }
                                            Spacer()
                                            Text("$600/mo")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                        }
                                    }
                                    .padding(10)
                                    .background(Color(red: 0.98, green: 0.96, blue: 0.94))
                                    .cornerRadius(6)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Transportation (9%)")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                                Text("Gas, public transit, car insurance, maintenance")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                            }
                                            Spacer()
                                            Text("$450/mo")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                        }
                                    }
                                    .padding(10)
                                    .background(Color(red: 0.98, green: 0.96, blue: 0.94))
                                    .cornerRadius(6)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Utilities (8%)")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                                Text("Electricity, water, gas, internet, phone")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                            }
                                            Spacer()
                                            Text("$400/mo")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                        }
                                    }
                                    .padding(10)
                                    .background(Color(red: 0.98, green: 0.96, blue: 0.94))
                                    .cornerRadius(6)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Healthcare (5%)")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                                Text("Doctor visits, prescriptions, insurance")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                            }
                                            Spacer()
                                            Text("$250/mo")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                        }
                                    }
                                    .padding(10)
                                    .background(Color(red: 0.98, green: 0.96, blue: 0.94))
                                    .cornerRadius(6)
                                }
                            }
                            
                            if let colIndex = profileViewModel.demographicData?.costOfLivingIndex, colIndex > 100 {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("What's Higher in Your Area")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                    
                                    let difference = colIndex - 100
                                    let percentageHigher = String(format: "%.1f", difference)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.red)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Your area is \(percentageHigher)% higher than national average")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                                
                                                Text("Primary drivers: Housing and utilities typically cost more in high-cost areas")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                            }
                                        }
                                        .padding(10)
                                        .background(Color(red: 1.0, green: 0.95, blue: 0.95))
                                        .cornerRadius(6)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("How to Interpret")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.35))
                                
                                HStack(spacing: 8) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Index > 100")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.red)
                                        Text("Higher than average")
                                            .font(.system(size: 11))
                                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Index = 100")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.65))
                                        Text("National average")
                                            .font(.system(size: 11))
                                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Index < 100")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color(red: 0.20, green: 0.60, blue: 0.20))
                                        Text("Lower than average")
                                            .font(.system(size: 11))
                                            .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(20)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                    .animation(.easeInOut(duration: 0.3), value: showCOLInfo)
                }
            }
            .sheet(isPresented: $isEditingExpenses) {
                EditExpensesView(
                    monthlyExpensesViewModel: monthlyExpensesViewModel,
                    authViewModel: authViewModel,
                    isPresented: $isEditingExpenses
                )
            }
            .sheet(isPresented: $showAnalysis) {
                BudgetAnalysisView(
                    budgetAnalysisViewModel: budgetAnalysisViewModel,
                    monthlyExpensesViewModel: monthlyExpensesViewModel,
                    profileViewModel: profileViewModel,
                    isPresented: $showAnalysis
                )
            }
            .sheet(isPresented: $showNeighborhoodComparison) {
                NeighborhoodComparisonView(
                    profileViewModel: profileViewModel,
                    monthlyExpensesViewModel: monthlyExpensesViewModel,
                    isPresented: $showNeighborhoodComparison
                )
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    authViewModel: authViewModel,
                    profileViewModel: profileViewModel,
                    isPresented: $showSettings
                )
            }
        }
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                profileViewModel.loadProfile(userId: userId)
                monthlyExpensesViewModel.loadExpenses(userId: userId)
            }
        }
    }
    
    private func calculateRemaining() -> Double {
        let income = Double(profileViewModel.monthlyNetIncome) ?? 0
        let housing = Double(monthlyExpensesViewModel.housing) ?? 0
        let transportation = Double(monthlyExpensesViewModel.transportation) ?? 0
        let carPayment = Double(monthlyExpensesViewModel.carPayment) ?? 0
        let carInsurance = Double(monthlyExpensesViewModel.carInsurance) ?? 0
        let carMaintenance = Double(monthlyExpensesViewModel.carMaintenance) ?? 0
        let groceries = Double(monthlyExpensesViewModel.groceries) ?? 0
        let subscriptions = Double(monthlyExpensesViewModel.subscriptions) ?? 0
        let otherExpenses = Double(monthlyExpensesViewModel.otherExpenses) ?? 0
        let savings = Double(monthlyExpensesViewModel.savings) ?? 0
        
        let totalExpenses = housing + transportation + carPayment + carInsurance + carMaintenance + groceries + subscriptions + otherExpenses + savings
        return max(income - totalExpenses, 0)
    }
    
    private func calculateSavingsPercentage() -> Double {
        let income = Double(profileViewModel.monthlyNetIncome) ?? 0
        let savings = Double(monthlyExpensesViewModel.savings) ?? 0
        
        guard income > 0 else { return 0 }
        return (savings / income) * 100
    }
    
    private func calculateNeedsPercentage() -> Double {
        let income = Double(profileViewModel.monthlyNetIncome) ?? 0
        let housing = Double(monthlyExpensesViewModel.housing) ?? 0
        let transportation = Double(monthlyExpensesViewModel.transportation) ?? 0
        let carPayment = Double(monthlyExpensesViewModel.carPayment) ?? 0
        let carInsurance = Double(monthlyExpensesViewModel.carInsurance) ?? 0
        let carMaintenance = Double(monthlyExpensesViewModel.carMaintenance) ?? 0
        let groceries = Double(monthlyExpensesViewModel.groceries) ?? 0
        
        let needs = housing + transportation + carPayment + carInsurance + carMaintenance + groceries
        guard income > 0 else { return 0 }
        return (needs / income) * 100
    }
    
    private func calculateWantsPercentage() -> Double {
        let income = Double(profileViewModel.monthlyNetIncome) ?? 0
        let subscriptions = Double(monthlyExpensesViewModel.subscriptions) ?? 0
        let otherExpenses = Double(monthlyExpensesViewModel.otherExpenses) ?? 0
        
        let wants = subscriptions + otherExpenses
        guard income > 0 else { return 0 }
        return (wants / income) * 100
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    private func getNeedsColor() -> Color {
        let needs = calculateNeedsPercentage()
        let target = 50.0
        let threshold = 2.0
        
        // Within threshold (48-52%) = yellow
        if abs(needs - target) <= threshold {
            return Color(red: 1.0, green: 0.8, blue: 0.0)  // Yellow
        }
        // Below target = green
        else if needs < target {
            return Color(red: 0.45, green: 0.85, blue: 0.45)  // Green
        }
        // Above target = red
        else {
            return Color.red
        }
    }
    
    private func getWantsColor() -> Color {
        let wants = calculateWantsPercentage()
        let target = 30.0
        let threshold = 2.0
        
        // Within threshold (28-32%) = yellow
        if abs(wants - target) <= threshold {
            return Color(red: 1.0, green: 0.8, blue: 0.0)  // Yellow
        }
        // Below target = green
        else if wants < target {
            return Color(red: 0.45, green: 0.85, blue: 0.45)  // Green
        }
        // Above target = red
        else {
            return Color.red
        }
    }
    
    private func getNeedsBarColor() -> Color {
        let needs = calculateNeedsPercentage()
        let target = 50.0
        let threshold = 2.0
        
        // Within threshold (48-52%) = yellow
        if abs(needs - target) <= threshold {
            return Color(red: 1.0, green: 0.8, blue: 0.0)  // Yellow
        }
        // Below target = green
        else if needs < target {
            return Color(red: 0.45, green: 0.85, blue: 0.45)  // Green
        }
        // Above target = red
        else {
            return Color.red
        }
    }
    
    private func getNeedsBarFillPercentage() -> Double {
        let needs = calculateNeedsPercentage()
        let target = 50.0
        
        // If above target, fill 100%
        if needs >= target {
            return 1.0
        }
        // If below target, fill proportionally (e.g., 25% of target = 50% of bar)
        else {
            return needs / target
        }
    }
    
    private func getWantsBarColor() -> Color {
        let wants = calculateWantsPercentage()
        let target = 30.0
        let threshold = 2.0
        
        // Within threshold (28-32%) = yellow
        if abs(wants - target) <= threshold {
            return Color(red: 1.0, green: 0.8, blue: 0.0)  // Yellow
        }
        // Below target = green
        else if wants < target {
            return Color(red: 0.45, green: 0.85, blue: 0.45)  // Green
        }
        // Above target = red
        else {
            return Color.red
        }
    }
    
    private func getWantsBarFillPercentage() -> Double {
        let wants = calculateWantsPercentage()
        let target = 30.0
        
        // If above target, fill 100%
        if wants >= target {
            return 1.0
        }
        // If below target, fill proportionally (e.g., 15% of target = 50% of bar)
        else {
            return wants / target
        }
    }
    
    private func getRecommendedSavingsForAge() -> Double {
        let age = profileViewModel.userProfile?.age ?? 0
        
        // Age-based savings recommendations
        switch age {
        case 0...25:
            return 15.0  // Young adults should save 15%
        case 26...35:
            return 18.0  // Early career: 18%
        case 36...45:
            return 20.0  // Mid-career: 20%
        case 46...55:
            return 25.0  // Pre-retirement: 25%
        case 56...65:
            return 30.0  // Near retirement: 30%
        default:
            return 25.0  // Retirement: 25%
        }
    }
    
    private func getAverageSavingsForAge() -> Double {
        let age = profileViewModel.userProfile?.age ?? 0
        
        // Average American savings by age group (based on Federal Reserve data)
        switch age {
        case 0...25:
            return 2.0   // Young adults average 2%
        case 26...35:
            return 4.0   // Early career average 4%
        case 36...45:
            return 6.0   // Mid-career average 6%
        case 46...55:
            return 8.0   // Pre-retirement average 8%
        case 56...65:
            return 10.0  // Near retirement average 10%
        default:
            return 7.0   // Retirement average 7%
        }
    }
}

// MARK: - Donut Chart View
struct DonutChartView: View {
    let housing: String
    let transportation: String
    let carPayment: String
    let carInsurance: String
    let carMaintenance: String
    let groceries: String
    let subscriptions: String
    let otherExpenses: String
    let savings: String
    
    @State private var rotation: Double = 0
    @State private var isDragging = false
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // 3D Shadow effect behind the pie
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.25),
                                Color.black.opacity(0.08),
                                Color.black.opacity(0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(height: 240)
                    .blur(radius: 8)
                    .offset(y: 12)
                
                // Background circle
                Circle()
                    .fill(Color(red: 0.96, green: 0.93, blue: 0.91))
                
                // Donut segments with enhanced colors and shadow effect
                ForEach(getSegments(), id: \.id) { segment in
                    Circle()
                        .trim(from: segment.start, to: segment.end)
                        .stroke(segment.color, lineWidth: 28)
                        .rotationEffect(.degrees(rotation - 90))
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 2, y: 2)
                }
                
                // Inner circle (white)
                Circle()
                    .fill(Color.white)
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
                
                // Center content
                VStack(spacing: 6) {
                    Text("TOTAL BUDGET")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50))
                    
                    Text(formatCurrency(calculateTotal()))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .frame(height: 240)
            .padding(.vertical, 12)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let translation = value.translation.width
                        rotation += translation / 10
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            .contentShape(Circle())
            .onAppear {
                startClockwiseAnimation()
            }
        }
    }
    
    private func startClockwiseAnimation() {
        isAnimating = true
        withAnimation(.easeInOut(duration: 2.5)) {
            rotation = 360
        }
        
        // Reset rotation after animation completes to allow continuous interaction
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            rotation = 0
            isAnimating = false
        }
    }
    
    private func getSegments() -> [PieSegment] {
        let housing = Double(housing) ?? 0
        let transportation = Double(transportation) ?? 0
        let carPayment = Double(carPayment) ?? 0
        let carInsurance = Double(carInsurance) ?? 0
        let carMaintenance = Double(carMaintenance) ?? 0
        let groceries = Double(groceries) ?? 0
        let subscriptions = Double(subscriptions) ?? 0
        let otherExpenses = Double(otherExpenses) ?? 0
        let savings = Double(savings) ?? 0
        
        let total = housing + transportation + carPayment + carInsurance + carMaintenance + groceries + subscriptions + otherExpenses + savings
        
        guard total > 0 else { return [] }
        
        var segments: [PieSegment] = []
        var currentStart: Double = 0
        
        // Enhanced color palette with better variation
        let colors: [Color] = [
            Color(red: 0.92, green: 0.45, blue: 0.45),      // Housing - Deep Red
            Color(red: 0.95, green: 0.70, blue: 0.55),      // Transportation - Coral
            Color(red: 0.88, green: 0.60, blue: 0.75),      // Car Payment - Mauve
            Color(red: 0.75, green: 0.88, blue: 0.65),      // Car Insurance - Sage Green
            Color(red: 0.65, green: 0.85, blue: 0.90),      // Car Maintenance - Sky Blue
            Color(red: 0.95, green: 0.85, blue: 0.60),      // Groceries - Warm Yellow
            Color(red: 0.85, green: 0.75, blue: 0.95),      // Subscriptions - Lavender
            Color(red: 0.90, green: 0.80, blue: 0.75),      // Other - Beige
            Color(red: 0.45, green: 0.85, blue: 0.45)       // Remaining - Green
        ]
        
        let amounts = [housing, transportation, carPayment, carInsurance, carMaintenance, groceries, subscriptions, otherExpenses]
        
        for (index, amount) in amounts.enumerated() {
            let percentage = amount / total
            let end = currentStart + percentage
            segments.append(PieSegment(
                id: index,
                start: currentStart,
                end: end,
                color: colors[index]
            ))
            currentStart = end
        }
        
        // Add remaining as green segment
        if currentStart < 1.0 {
            segments.append(PieSegment(
                id: 8,
                start: currentStart,
                end: 1.0,
                color: colors[8]
            ))
        }
        
        return segments
    }
    
    private func calculateTotal() -> Double {
        let housing = Double(housing) ?? 0
        let transportation = Double(transportation) ?? 0
        let carPayment = Double(carPayment) ?? 0
        let carInsurance = Double(carInsurance) ?? 0
        let carMaintenance = Double(carMaintenance) ?? 0
        let groceries = Double(groceries) ?? 0
        let subscriptions = Double(subscriptions) ?? 0
        let otherExpenses = Double(otherExpenses) ?? 0
        let savings = Double(savings) ?? 0
        
        return housing + transportation + carPayment + carInsurance + carMaintenance + groceries + subscriptions + otherExpenses + savings
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

struct PieSegment {
    let id: Int
    let start: Double
    let end: Double
    let color: Color
}

// MARK: - Expense Legend Item
struct ExpenseLegendItem: View {
    let color: Color
    let label: String
    let amount: String
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text(formatCurrency(Double(amount) ?? 0))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

#Preview {
    HomeView(
        authViewModel: AuthViewModel(),
        profileViewModel: ProfileViewModel(),
        monthlyExpensesViewModel: MonthlyExpensesViewModel()
    )
}
