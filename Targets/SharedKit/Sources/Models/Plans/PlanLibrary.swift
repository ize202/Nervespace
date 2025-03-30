import Foundation

public enum PlanLibrary {
    // MARK: - All Plans
    public static let plans: [Plan] = [
        // 3-Day Plan: Beginner's Energize
        Plan(
            name: "Beginner's Energize",
            description: "Introduce beginners to a balanced routine that boosts energy and builds confidence.",
            routines: [
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Morning Boost" }!,
                    day: 1
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Quick Refresh" }!,
                    day: 2,
                    sequenceOrder: 1
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Flex Quick" }!,
                    day: 2,
                    sequenceOrder: 2
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Full Body" }!,
                    day: 3
                )
            ]
        ),
        
        // 3-Day Plan: Somatic Reset
        Plan(
            name: "Somatic Reset",
            description: "Focus on calming the nervous system and promoting relaxation.",
            routines: [
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Somatic Ease" }!,
                    day: 1
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Rapid Relax" }!,
                    day: 2,
                    sequenceOrder: 1
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Evening Calm" }!,
                    day: 2,
                    sequenceOrder: 2
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Posture Reset" }!,
                    day: 3
                )
            ]
        ),
        
        // 5-Day Plan: Balanced Core
        Plan(
            name: "Balanced Core",
            description: "Develop core strength and overall body balance.",
            routines: [
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Core Focus" }!,
                    day: 1
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Morning Boost" }!,
                    day: 2
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Flex Quick" }!,
                    day: 3,
                    sequenceOrder: 1
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Quick Refresh" }!,
                    day: 3,
                    sequenceOrder: 2
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Full Body" }!,
                    day: 4
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Evening Calm" }!,
                    day: 5
                )
            ]
        ),
        
        // 7-Day Plan: Weekly Wellness
        Plan(
            name: "Weekly Wellness",
            description: "A comprehensive plan to enhance wellness and maintain flexibility.",
            routines: [
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Morning Boost" }!,
                    day: 1
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Posture Reset" }!,
                    day: 2
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Core Focus" }!,
                    day: 3
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Energy Surge" }!,
                    day: 4
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Somatic Ease" }!,
                    day: 5
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Quick Refresh" }!,
                    day: 6,
                    sequenceOrder: 1
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Flex Quick" }!,
                    day: 6,
                    sequenceOrder: 2
                ),
                PlanRoutine(
                    routine: RoutineLibrary.routines.first { $0.name == "Evening Calm" }!,
                    day: 7
                )
            ]
        )
    ]
    
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