//
//  HistoryScreen.swift
//  AIExpensePlanner
//
//  Created on 09/05/25.
//

import SwiftUI

// MARK: - History Screen

/// Displays a list of all financial entries.
struct HistoryScreen: View {
    /// The view model managing financial data.
    @ObservedObject var viewModel: FinanceViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // MARK: - Entry List
                /// Displays each entry with date, category, description, and amount.
                ForEach(viewModel.entries) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(entry.date, style: .date)
                                .font(.caption)
                            Text("\(entry.category) - \(entry.description)")
                                .font(.subheadline)
                        }
                        Spacer()
                        Text(entry.isIncome ? "+$\(String(format: "%.2f", entry.amount))" : "-$\(String(format: "%.2f", entry.amount))")
                            .foregroundColor(entry.isIncome ? .green : .red)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 50)
        }
        .navigationTitle(Constants.historyTitle)
        .onAppear {
            viewModel.loadEntries()
        }
    }
}
