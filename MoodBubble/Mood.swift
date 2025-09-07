import Foundation
import FirebaseFirestore
import SwiftUI

struct Mood: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var userName: String
    var color: String
    var emoji: String
    var description: String
    var timestamp: Date
    
    var colorValue: Color {
        switch color {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        default: return .gray
        }
    }
}

struct MoodColor: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

let moodColors = [
    MoodColor(name: "red", color: .red),
    MoodColor(name: "orange", color: .orange),
    MoodColor(name: "yellow", color: .yellow),
    MoodColor(name: "green", color: .green),
    MoodColor(name: "blue", color: .blue),
    MoodColor(name: "purple", color: .purple)
]

let moodEmojis = ["😊", "😔", "😴", "😎", "🤗", "😰", "😡", "🥳", "😌", "🤔", "❤️", "✨"]
