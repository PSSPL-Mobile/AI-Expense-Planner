//
//  ExpenseModel.swift
//  AIExpensePlanner
//
//  Created on 09/05/25.
//

import Foundation

// MARK: - Models

/// Represents a single financial entry, either income or expense.
struct ExpenseEntry: Identifiable, Codable {
    /// Unique identifier for the entry.
    var id = UUID()
    /// Date of the transaction.
    let date: Date
    /// Category of the transaction (e.g., Food, Income).
    let category: String
    /// Description of the transaction.
    let description: String
    /// Amount of the transaction.
    let amount: Double
    /// Indicates whether the entry is income (true) or expense (false).
    let isIncome: Bool
}

// MARK: - Gemini API Response Models

/// Represents the top-level response from the Gemini API.
struct GeminiResponse: Codable {
    /// Array of candidate responses, if available.
    let candidates: [Candidate]?
    /// Error details, if the API request fails.
    let error: ErrorResponse?
}

/// Represents a candidate response from the Gemini API.
struct Candidate: Codable {
    /// Content of the candidate response.
    let content: Content
}

/// Represents the content of a candidate response.
struct Content: Codable {
    /// Array of parts containing text data.
    let parts: [Part]
}

/// Represents a single part of the content, containing text.
struct Part: Codable {
    /// Text content of the part.
    let text: String
}

/// Represents an error response from the Gemini API.
struct ErrorResponse: Codable {
    /// Error message describing the issue.
    let message: String
    /// Optional error code for further details.
    let code: String?
}
