import SwiftUI
import SharedKit

/// Routine Card Model
struct RoutineCard: Identifiable, Hashable {
    var id: UUID = .init()
    var title: String
    var duration: String
    var image: String = "figure.flexibility" // Default placeholder, will be replaced with actual illustrations
    var imageUrl: String? // URL for the vector image
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RoutineCard, rhs: RoutineCard) -> Bool {
        lhs.id == rhs.id
    }
}

/// Sample Cards
extension RoutineCard {
    static var sampleCards: [RoutineCard] = [
        .init(title: "Wake Up", duration: "4 MINUTES", imageUrl: "wake-up-illustration"),
        .init(title: "Sleep", duration: "10 MINUTES", imageUrl: "sleep-illustration"),
        .init(title: "Full Body", duration: "15 MINUTES", imageUrl: "full-body-illustration")
    ]
}



