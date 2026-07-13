import XCTest
@testable import SharedKit

final class RoutineLibraryTests: XCTestCase {
    func testKnownBundledPlanRoutineResolvesByStableIdentifier() throws {
        let plannedRoutine = try XCTUnwrap(PlanLibrary.plans.first?.routines.first?.routine)

        let resolvedRoutine = RoutineLibrary.routine(id: plannedRoutine.id)

        XCTAssertEqual(resolvedRoutine, plannedRoutine)
    }

    func testUnknownRoutineIdentifierReturnsNil() {
        XCTAssertNil(RoutineLibrary.routine(id: "routine-that-does-not-exist"))
    }
}
