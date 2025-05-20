//
//  AddEntryScreen.swift
//  AIExpensePlanner
//
//  Created on 09/05/25.
//

import SwiftUI

// MARK: - Add Entry Screen

/// A form for adding new income or expense entries.
struct AddEntryScreen: View {
    /// The view model managing financial data.
    @ObservedObject var viewModel: FinanceViewModel
    /// The selected entry type (Income or Expense).
    @State private var entryType = Constants.entryTypes[0]
    /// The amount of the entry.
    @State private var amount: String = ""
    /// The description of the expense.
    @State private var expenseDescription: String = ""
    /// The selected expense category.
    @State private var selectedCategory = Constants.expenseCategories[0]
    /// The date of the entry.
    @State private var selectedDate = Date()
    /// Environment variable to control presentation.
    @Environment(\.presentationMode) var presentationMode
    /// Callback to refresh budget tips after adding an entry.
    let onEntryAdded: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Entry Type Picker
                /// Allows switching between Income and Expense forms.
                Picker(Constants.entryTypeLabel, selection: $entryType) {
                    ForEach(Constants.entryTypes, id: \.self) { type in
                        Text(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // MARK: - Form Fields
                /// Displays fields based on the selected entry type.
                if entryType == Constants.entryTypes[0] { // Income
                    VStack(alignment: .leading, spacing: 10) {
                        Text(Constants.incomeAmountLabel)
                            .font(.headline)
                        TextField(Constants.amountPlaceholder, text: $amount)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        
                        Text(Constants.incomeDateLabel)
                            .font(.headline)
                        DatePicker(Constants.incomeDateLabel, selection: $selectedDate, displayedComponents: .date)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                } else { // Expense
                    VStack(alignment: .leading, spacing: 10) {
                        Text(Constants.expenseCategoryLabel)
                            .font(.headline)
                        Menu {
                            ForEach(Constants.expenseCategories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedCategory)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        Text(Constants.expenseDescriptionPlaceholder)
                            .font(.headline)
                        TextField(Constants.expenseDescriptionPlaceholder, text: $expenseDescription)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        
                        Text(Constants.expenseAmountLabel)
                            .font(.headline)
                        TextField(Constants.amountPlaceholder, text: $amount)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        
                        Text(Constants.expenseDateLabel)
                            .font(.headline)
                        DatePicker(Constants.expenseDateLabel, selection: $selectedDate, displayedComponents: .date)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - Add Entry Button
                /// Submits the form and adds the entry.
                Button(action: {
                    if let entryAmount = Double(amount), entryAmount > 0 {
                        if entryType == Constants.entryTypes[0] { // Income
                            viewModel.addEntry(date: selectedDate, category: Constants.incomeCategory, description: Constants.incomeDescription, amount: entryAmount, isIncome: true)
                        } else { // Expense
                            viewModel.addEntry(date: selectedDate, category: selectedCategory, description: expenseDescription, amount: entryAmount, isIncome: false)
                        }
                        amount = ""
                        expenseDescription = ""
                        selectedCategory = Constants.expenseCategories[0]
                        selectedDate = Date()
                        onEntryAdded()
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Add \(entryType)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(entryType == Constants.entryTypes[0] ? Color.green : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 50)
            }
            .padding(.top, 20)
        }
        .navigationTitle(Constants.addEntryTitle)
    }
}
