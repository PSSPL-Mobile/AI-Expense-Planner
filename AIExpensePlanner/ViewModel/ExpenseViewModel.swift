//
//  ExpenseViewModel.swift
//  AIExpensePlanner
//
//  Created on 09/05/25.
//

import Foundation

// MARK: - ViewModel

/// Manages the financial data and interactions with the Gemini API for budget tips.
class FinanceViewModel: ObservableObject {
    /// Array of financial entries (income and expenses).
    @Published var entries: [ExpenseEntry] = []
    /// Array of budget tips fetched from the Gemini API.
    @Published var budgetTips: [String] = []
    /// Indicates whether budget tips are currently being fetched.
    @Published var isLoadingTips: Bool = false
    
    /// Initializes the view model and loads saved entries.
    init() {
        loadEntries()
    }
    
    /// Adds a new financial entry and saves it to UserDefaults.
    /// - Parameters:
    ///   - date: The date of the transaction.
    ///   - category: The category of the transaction (e.g., Food, Income).
    ///   - description: A description of the transaction.
    ///   - amount: The amount of the transaction.
    ///   - isIncome: Indicates whether the entry is income (true) or expense (false).
    func addEntry(date: Date, category: String, description: String, amount: Double, isIncome: Bool) {
        let entry = ExpenseEntry(date: date, category: category, description: description, amount: amount, isIncome: isIncome)
        entries.append(entry)
        saveEntries()
    }
    
    /// Loads saved entries from UserDefaults.
    func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: Constants.userDefaultsKey),
           let savedEntries = try? JSONDecoder().decode([ExpenseEntry].self, from: data) {
            entries = savedEntries
        }
    }
    
    /// Saves the current entries to UserDefaults.
    func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: Constants.userDefaultsKey)
        }
    }
    
    /// Calculates the total income from all entries.
    /// - Returns: The sum of all income amounts.
    func getTotalIncome() -> Double {
        entries.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    /// Calculates the total expenses from all entries.
    /// - Returns: The sum of all expense amounts.
    func getTotalExpenses() -> Double {
        entries.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    /// Calculates the percentage distribution of expenses by category.
    /// - Returns: A dictionary mapping categories to their percentage of total expenses.
    func getExpenseDistribution() -> [String: Double] {
        let expenses = entries.filter { !$0.isIncome }
        let totalExpenses = getTotalExpenses()
        var distribution: [String: Double] = [:]
        
        for entry in expenses {
            distribution[entry.category, default: 0] += entry.amount
        }
        
        return distribution.mapValues { totalExpenses > 0 ? ($0 / totalExpenses) * 100 : 0 }
    }
    
    /// Fetches budget tips from the Gemini API based on financial data.
    /// - Parameter completion: A closure called when the fetch is complete.
    func fetchBudgetTips(completion: @escaping () -> Void) {
        isLoadingTips = true
        
        let totalIncome = getTotalIncome()
        let totalExpenses = getTotalExpenses()
        let savings = totalIncome - totalExpenses
        let distribution = getExpenseDistribution()
        
        let distributionText = distribution.map { "\($0.key): \($0.value)%" }.joined(separator: ", ")
        let prompt = """
                Based on the following financial summary, provide concise financial tips as plain text sentences, one per line, without using Markdown formatting. Include a mix of budget tips and investment suggestions:

                - Budget Tips: Focus on high-spending categories, mention the percentage of total income spent on that category, and provide a practical suggestion for reducing expenses. Format like: "Housing Dominates: your housing costs 47% of your income are excessively high, you can explore other housing options, cheaper house, a roommate".

                - Investment Tips: Based on the savings or financial surplus, suggest ways to grow wealth or save for the future. Tailor the advice to the data, e.g., "With $X in savings, consider allocating Y% to a low-risk investment like a savings account or bonds".

                Use the data provided to make the tips specific and actionable:
                - Total Income: $\(totalIncome)
                - Total Expenses: $\(totalExpenses)
                - Savings: $\(savings)
                - Expense Distribution: \(distributionText)
                """
        
        guard let url = URL(string: "\(Constants.geminiEndpoint)?key=\(Constants.geminiApiKey)") else {
            budgetTips = ["Error: Invalid API URL"]
            isLoadingTips = false
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            budgetTips = ["Error: Failed to serialize request body"]
            isLoadingTips = false
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingTips = false
                
                if let error = error {
                    self.budgetTips = ["Error: Network error - \(error.localizedDescription)"]
                    completion()
                    return
                }
                
                guard let data = data else {
                    self.budgetTips = ["Error: No data received from API"]
                    completion()
                    return
                }
                
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(rawResponse)")
                } else {
                    print("Raw API Response: Unable to decode as UTF-8")
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        self.budgetTips = ["Error: HTTP \(httpResponse.statusCode)"]
                        completion()
                        return
                    }
                }
                
                do {
                    let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                    
                    if let error = geminiResponse.error {
                        self.budgetTips = ["Error: API error - \(error.message)"]
                        completion()
                        return
                    }
                    
                    guard let candidates = geminiResponse.candidates, !candidates.isEmpty else {
                        self.budgetTips = ["Error: No candidates found in response"]
                        completion()
                        return
                    }
                    
                    if let firstCandidate = candidates.first,
                       let firstPart = firstCandidate.content.parts.first {
                        let tips = firstPart.text.split(separator: "\n").map { String($0) }
                        self.budgetTips = tips.map { tip in
                            var cleanedTip = tip.replacingOccurrences(of: "^\\d+\\.\\s*", with: "", options: .regularExpression)
                            cleanedTip = cleanedTip.replacingOccurrences(of: "\\*\\*", with: "")
                            cleanedTip = cleanedTip.replacingOccurrences(of: "\\*", with: "")
                            return cleanedTip.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    } else {
                        self.budgetTips = ["Error: No tips found in response"]
                    }
                } catch {
                    self.budgetTips = ["Error: Failed to parse response - \(error.localizedDescription)"]
                }
                completion()
            }
        }.resume()
    }
}
