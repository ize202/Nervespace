import Foundation
import Supabase

public class SupabasePlanService: PlanService {
    private let client: SupabaseClient
    
    public init(client: SupabaseClient) {
        self.client = client
    }
    
    public func fetchPlans() async throws -> [Plan] {
        return try await client.database
            .from("plans")
            .select()
            .execute()
            .value
    }
    
    public func fetchPlan(id: UUID) async throws -> Plan {
        let plans: [Plan] = try await client.database
            .from("plans")
            .select()
            .eq("id", value: id)
            .execute()
            .value
        
        guard let plan = plans.first else {
            throw NSError(domain: "PlanService", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Plan not found"
            ])
        }
        
        return plan
    }
    
    public func createPlan(_ plan: Plan) async throws -> Plan {
        let plans: [Plan] = try await client.database
            .from("plans")
            .insert(plan)
            .execute()
            .value
        
        guard let created = plans.first else {
            throw NSError(domain: "PlanService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create plan"
            ])
        }
        
        return created
    }
    
    public func updatePlan(_ plan: Plan) async throws -> Plan {
        let plans: [Plan] = try await client.database
            .from("plans")
            .update(plan)
            .eq("id", value: plan.id)
            .execute()
            .value
        
        guard let updated = plans.first else {
            throw NSError(domain: "PlanService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to update plan"
            ])
        }
        
        return updated
    }
    
    public func deletePlan(id: UUID) async throws {
        try await client.database
            .from("plans")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    public func fetchPlanRoutines(planId: UUID) async throws -> [PlanRoutine] {
        return try await client.database
            .from("plan_routines")
            .select()
            .eq("plan_id", value: planId)
            .order("day")
            .execute()
            .value
    }
    
    public func addRoutineToPlan(
        planId: UUID,
        routineId: UUID,
        day: Int
    ) async throws -> PlanRoutine {
        let planRoutine = PlanRoutine(
            planId: planId,
            routineId: routineId,
            day: day
        )
        
        let planRoutines: [PlanRoutine] = try await client.database
            .from("plan_routines")
            .insert(planRoutine)
            .execute()
            .value
        
        guard let created = planRoutines.first else {
            throw NSError(domain: "PlanService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to add routine to plan"
            ])
        }
        
        return created
    }
    
    public func updatePlanRoutine(_ planRoutine: PlanRoutine) async throws -> PlanRoutine {
        let planRoutines: [PlanRoutine] = try await client.database
            .from("plan_routines")
            .update(planRoutine)
            .eq("id", value: planRoutine.id)
            .execute()
            .value
        
        guard let updated = planRoutines.first else {
            throw NSError(domain: "PlanService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to update plan routine"
            ])
        }
        
        return updated
    }
    
    public func removeRoutineFromPlan(planId: UUID, routineId: UUID) async throws {
        try await client.database
            .from("plan_routines")
            .delete()
            .eq("plan_id", value: planId)
            .eq("routine_id", value: routineId)
            .execute()
    }
    
    public func fetchPremiumPlans() async throws -> [Plan] {
        return try await client.database
            .from("plans")
            .select()
            .eq("is_premium", value: true)
            .execute()
            .value
    }
    
    public func fetchFreePlans() async throws -> [Plan] {
        return try await client.database
            .from("plans")
            .select()
            .eq("is_premium", value: false)
            .execute()
            .value
    }
} 