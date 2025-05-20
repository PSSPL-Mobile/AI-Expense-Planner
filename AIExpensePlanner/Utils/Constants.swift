//
//  Constants.swift
//  AIExpensePlanner
//
//  Created on 09/05/25.
//

import Foundation

/// Centralized constants for the AIExpensePlanner.
enum Constants {
    // MARK: - UserDefaults Keys
    /// Key for storing expense entries in UserDefaults.
    static let userDefaultsKey = "ExpenseEntries"
    
    // MARK: - API Configuration
    /// Endpoint for the Gemini API.
    static let geminiEndpoint = "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent"
    /// Placeholder for the Gemini API key (replace with actual key).
    static let geminiApiKey = "AIzaSyA9pUM-t2ZRbEecFdJ2or01IO3t8RPP03I"
    
    // MARK: - Categories
    /// List of expense categories.
    static let expenseCategories = ["Food", "Transport", "Housing", "Shopping", "Others"]
    /// Default category for income entries.
    static let incomeCategory = "Income"
    
    // MARK: - Entry Types
    /// List of entry types for the AddEntryScreen picker.
    static let entryTypes = ["Income", "Expense"]
    
    // MARK: - UI Text
    /// Title for the dashboard screen.
    static let dashboardTitle = "Dashboard"
    /// Title for the add entry screen.
    static let addEntryTitle = "Add Entry"
    /// Title for the history screen.
    static let historyTitle = "History"
    /// Label for the expense distribution section.
    static let expenseDistributionLabel = "Expense Distribution:"
    /// Label for the budget tips section.
    static let budgetTipsLabel = "Smart Budget Tips:"
    /// Label for the entry type picker.
    static let entryTypeLabel = "Entry Type"
    /// Placeholder for expense description field.
    static let expenseDescriptionPlaceholder = "What did you spend on?"
    /// Placeholder for amount field.
    static let amountPlaceholder = "Enter amount"
    /// Label for income amount field.
    static let incomeAmountLabel = "Income Amount"
    /// Label for expense amount field.
    static let expenseAmountLabel = "Expense Amount"
    /// Label for income date field.
    static let incomeDateLabel = "Income Date"
    /// Label for expense date field.
    static let expenseDateLabel = "Expense Date"
    /// Label for expense category field.
    static let expenseCategoryLabel = "Expense Category"
    /// Default description for income entries.
    static let incomeDescription = "Salary"
}
