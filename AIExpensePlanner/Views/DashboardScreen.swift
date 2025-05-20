//
//  DashboardScreen.swift
//  AIExpensePlanner
//
//  Created on 09/05/25.
//

import SwiftUI

// MARK: - Dashboard Screen

/// The main dashboard screen displaying financial summaries, expense distribution, and budget tips.
struct DashboardScreen: View {
    /// The view model managing financial data.
    @StateObject private var viewModel = FinanceViewModel()
    /// Controls the visibility of the AddEntryScreen.
    @State private var isShowingAddEntryScreen = false
    
    /// Callback to refresh budget tips after a new entry is added.
    private func onEntryAdded() {
        viewModel.fetchBudgetTips {}
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Summary Cards
                        /// Displays total income and expenses in summary cards.
                        HStack(spacing: 15) {
                            SummaryCard(title: Constants.entryTypes[0], amount: viewModel.getTotalIncome(), icon: "dollarsign.circle.fill", color: .green)
                            SummaryCard(title: Constants.entryTypes[1], amount: viewModel.getTotalExpenses(), icon: "cart.fill", color: .red)
                        }
                        .padding(.horizontal)
                        
                        // MARK: - Expense Distribution
                        /// Shows a pie chart of expense distribution by category.
                        VStack(alignment: .leading) {
                            Text(Constants.expenseDistributionLabel)
                                .font(.headline)
                                .padding(.horizontal)
                            PieChartView(distribution: viewModel.getExpenseDistribution())
                                .frame(height: 250)
                                .padding()
                        }
                        
                        // MARK: - Smart Budget Tips
                        /// Lists dynamically fetched budget tips or a loading indicator.
                        VStack(alignment: .leading, spacing: 10) {
                            Text(Constants.budgetTipsLabel)
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if viewModel.isLoadingTips {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(1.5)
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                ForEach(viewModel.budgetTips, id: \.self) { tip in
                                    VStack {
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("•")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            Text(tip)
                                                .font(.subheadline)
                                                .lineLimit(nil)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                        }
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 10)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.05))
                                    .cornerRadius(5)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        Spacer()
                            .frame(height: 50)
                    }
                }
                .refreshable {
                    await withCheckedContinuation { continuation in
                        viewModel.fetchBudgetTips {
                            continuation.resume()
                        }
                    }
                }
                .navigationTitle(Constants.dashboardTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: HistoryScreen(viewModel: viewModel)) {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .onAppear {
                    viewModel.loadEntries()
                    viewModel.fetchBudgetTips {}
                }
                
                // MARK: - Floating Button
                /// Floating button to navigate to the AddEntryScreen.
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: AddEntryScreen(viewModel: viewModel, onEntryAdded: onEntryAdded), isActive: $isShowingAddEntryScreen) {
                            EmptyView()
                        }
                        Button(action: {
                            isShowingAddEntryScreen = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Helper Views

/// A card displaying a financial summary (e.g., income or expenses).
struct SummaryCard: View {
    /// The title of the card (e.g., Income, Expenses).
    let title: String
    /// The amount to display.
    let amount: Double
    /// The SF Symbol icon for the card.
    let icon: String
    /// The color of the icon and text.
    let color: Color
    
    var body: some View {
        VStack {
            Label(title, systemImage: icon)
                .foregroundColor(color)
            Text("$\(String(format: "%.2f", amount))")
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

/// A pie chart view showing expense distribution by category.
struct PieChartView: View {
    /// A dictionary mapping categories to their percentage of total expenses.
    let distribution: [String: Double]
    
    /// Computes the start and end angles for each pie chart slice.
    private var slices: [(category: String, startAngle: Angle, endAngle: Angle)] {
        let total = distribution.values.reduce(0, +)
        var currentAngle: Double = 0
        var result: [(category: String, startAngle: Angle, endAngle: Angle)] = []
        
        for category in distribution.keys.sorted() {
            let percentage = (distribution[category] ?? 0) / 100
            let angle = 360 * percentage
            let startAngle = Angle.degrees(currentAngle)
            let endAngle = Angle.degrees(currentAngle + angle)
            result.append((category: category, startAngle: startAngle, endAngle: endAngle))
            currentAngle += angle
        }
        
        return result
    }
    
    /// Groups categories into pairs for the legend.
    private var categoryPairs: [[String]] {
        let sortedCategories = distribution.keys.sorted()
        var pairs: [[String]] = []
        var currentPair: [String] = []
        
        for category in sortedCategories {
            currentPair.append(category)
            if currentPair.count == 2 {
                pairs.append(currentPair)
                currentPair = []
            }
        }
        
        if !currentPair.isEmpty {
            pairs.append(currentPair)
        }
        
        return pairs
    }
    
    var body: some View {
        VStack {
            // MARK: - Pie Chart
            GeometryReader { geometry in
                ZStack {
                    ForEach(slices, id: \.category) { slice in
                        PieChartSlice(startAngle: slice.startAngle, endAngle: slice.endAngle, color: colorForCategory(slice.category))
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
            .frame(height: 200)
            
            // MARK: - Legend
            /// Displays categories and their percentages in a two-column legend.
            VStack(alignment: .leading, spacing: 5) {
                ForEach(categoryPairs, id: \.self) { pair in
                    HStack(spacing: 20) {
                        ForEach(pair, id: \.self) { category in
                            HStack {
                                Circle()
                                    .fill(colorForCategory(category))
                                    .frame(width: 10, height: 10)
                                Text("\(category) (\(String(format: "%.0f", distribution[category] ?? 0))%)")
                                    .font(.caption)
                            }
                        }
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    /// Returns a color for a given category.
    /// - Parameter category: The category name.
    /// - Returns: The corresponding color for the category.
    func colorForCategory(_ category: String) -> Color {
        switch category {
        case Constants.expenseCategories[0]: return .red // Food
        case Constants.expenseCategories[3]: return .cyan // Shopping
        case Constants.expenseCategories[1]: return .yellow // Transport
        case Constants.expenseCategories[2]: return .gray // Housing
        default: return .orange
        }
    }
}

/// A single slice of the pie chart.
struct PieChartSlice: View {
    /// The starting angle of the slice.
    let startAngle: Angle
    /// The ending angle of the slice.
    let endAngle: Angle
    /// The color of the slice.
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                path.move(to: center)
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}
