import Foundation

public enum PlanLibrary {
    // MARK: - All Plans
    public static let plans: [Plan] = {
        // Debug logging
        print("Available routines: \(RoutineLibrary.routines.map { $0.name })")
        
        return [
            // 3-Day Plan: Beginner's Energize
            Plan(
                name: "Beginner's Energize",
                description: "Introduce beginners to a balanced routine that boosts energy and builds confidence.",
                routines: {
                    let routineNames = ["Morning Boost", "Quick Refresh", "Flex Quick", "Full Body"]
                    var planRoutines: [PlanRoutine] = []
                    
                    for (index, name) in routineNames.enumerated() {
                        if let routine = RoutineLibrary.routines.first(where: { $0.name == name }) {
                            planRoutines.append(PlanRoutine(
                                routine: routine,
                                day: (index / 2) + 1,
                                sequenceOrder: (index % 2) + 1
                            ))
                        } else {
                            print("⚠️ Warning: Could not find routine named '\(name)'")
                        }
                    }
                    
                    return planRoutines
                }()
            ),
            
            // 3-Day Plan: Somatic Reset
            Plan(
                name: "Somatic Reset",
                description: "Focus on calming the nervous system and promoting relaxation.",
                routines: {
                    let routineNames = ["Somatic Ease", "Rapid Relax", "Evening Calm", "Posture Reset"]
                    var planRoutines: [PlanRoutine] = []
                    
                    for (index, name) in routineNames.enumerated() {
                        if let routine = RoutineLibrary.routines.first(where: { $0.name == name }) {
                            planRoutines.append(PlanRoutine(
                                routine: routine,
                                day: (index / 2) + 1,
                                sequenceOrder: (index % 2) + 1
                            ))
                        } else {
                            print("⚠️ Warning: Could not find routine named '\(name)'")
                        }
                    }
                    
                    return planRoutines
                }()
            ),
            
            // 5-Day Plan: Balanced Core
            Plan(
                name: "Balanced Core",
                description: "Develop core strength and overall body balance.",
                routines: {
                    let routineNames = ["Core Focus", "Morning Boost", "Flex Quick", "Quick Refresh", "Full Body", "Evening Calm"]
                    var planRoutines: [PlanRoutine] = []
                    
                    for (index, name) in routineNames.enumerated() {
                        if let routine = RoutineLibrary.routines.first(where: { $0.name == name }) {
                            planRoutines.append(PlanRoutine(
                                routine: routine,
                                day: (index / 2) + 1,
                                sequenceOrder: (index % 2) + 1
                            ))
                        } else {
                            print("⚠️ Warning: Could not find routine named '\(name)'")
                        }
                    }
                    
                    return planRoutines
                }()
            ),
            
            // 7-Day Plan: Weekly Wellness
            Plan(
                name: "Weekly Wellness",
                description: "A comprehensive plan to enhance wellness and maintain flexibility.",
                routines: {
                    let routineNames = ["Morning Boost", "Posture Reset", "Core Focus", "Energy Surge", "Somatic Ease", "Quick Refresh", "Flex Quick", "Evening Calm"]
                    var planRoutines: [PlanRoutine] = []
                    
                    for (index, name) in routineNames.enumerated() {
                        if let routine = RoutineLibrary.routines.first(where: { $0.name == name }) {
                            planRoutines.append(PlanRoutine(
                                routine: routine,
                                day: (index / 2) + 1,
                                sequenceOrder: (index % 2) + 1
                            ))
                        } else {
                            print("⚠️ Warning: Could not find routine named '\(name)'")
                        }
                    }
                    
                    return planRoutines
                }()
            )
        ]
    }()
    
    // MARK: - Premium Status
    public static var freePlans: [Plan] {
        plans.filter { !$0.isPremium }
    }
    
    public static var premiumPlans: [Plan] {
        plans.filter { $0.isPremium }
    }
    
    // MARK: - Duration Helpers
    public static var shortPlans: [Plan] {
        plans.filter { $0.totalDays <= 7 } // Week or less
    }
    
    public static var mediumPlans: [Plan] {
        plans.filter { $0.totalDays > 7 && $0.totalDays <= 14 } // 1-2 weeks
    }
    
    public static var longPlans: [Plan] {
        plans.filter { $0.totalDays > 14 } // More than 2 weeks
    }
    
    // MARK: - Search Helpers
    public static func plan(withId id: String) -> Plan? {
        plans.first { $0.id == id }
    }
    
    public static func search(_ query: String) -> [Plan] {
        let terms = query.lowercased().split(separator: " ").map(String.init)
        return plans.filter { plan in
            terms.contains { term in
                plan.name.lowercased().contains(term) ||
                plan.description.lowercased().contains(term) ||
                plan.routines.contains { 
                    $0.routine.name.lowercased().contains(term) ||
                    $0.routine.exercises.contains {
                        $0.exercise.name.lowercased().contains(term) ||
                        $0.exercise.categories.contains { $0.rawValue.lowercased().contains(term) }
                    }
                }
            }
        }
    }
    
    // MARK: - Category Helpers
    public static func plans(containing category: ExerciseCategory) -> [Plan] {
        plans.filter { plan in
            plan.routines.contains { planRoutine in
                planRoutine.routine.exercises.contains {
                    $0.exercise.categories.contains(category)
                }
            }
        }
    }
    
    public static var somaticPlans: [Plan] {
        plans(containing: .somatic)
    }
    
    public static var mobilityPlans: [Plan] {
        plans(containing: .mobility)
    }
} 