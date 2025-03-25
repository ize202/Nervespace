import SwiftUI
import SharedKit

/// Routine Card Model
struct RoutineCard: Identifiable, Hashable {
    var id: UUID = .init()
    var title: String
    var duration: String
    var image: String = "figure.flexibility" // Default placeholder, will be replaced with actual illustrations
    
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
        .init(title: "Wake Up", duration: "4 MINUTES"),
        .init(title: "Sleep", duration: "10 MINUTES"),
        .init(title: "Full Body", duration: "15 MINUTES")
    ]
}



