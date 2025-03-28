import Foundation

public protocol PlanService {
    func fetchPlans() async throws -> [Plan]
    func fetchPlan(id: UUID) async throws -> Plan
    func createPlan(_ plan: Plan) async throws -> Plan
    func updatePlan(_ plan: Plan) async throws -> Plan
    func deletePlan(id: UUID) async throws
    
    // Plan Routine methods
    func fetchPlanRoutines(planId: UUID) async throws -> [PlanRoutine]
    func addRoutineToPlan(planId: UUID, routineId: UUID, day: Int) async throws -> PlanRoutine
    func updatePlanRoutine(_ planRoutine: PlanRoutine) async throws -> PlanRoutine
    func removeRoutineFromPlan(planId: UUID, routineId: UUID) async throws
    
    // Premium content
    func fetchPremiumPlans() async throws -> [Plan]
    func fetchFreePlans() async throws -> [Plan]
} 