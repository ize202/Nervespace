import Foundation
import XCTest
@testable import LocalDataKit

final class RoutineCompletionCodingTests: XCTestCase {
    func testISO8601RoundTripPreservesIdentifierAndDate() throws {
        let expected = RoutineCompletion(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            routineID: "morning_boost",
            durationMinutes: 12,
            completedAt: testDate(2026, 7, 13, 8, 15, 30)
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = try encoder.encode(expected)
        let decoded = try decoder.decode(RoutineCompletion.self, from: data)

        XCTAssertEqual(decoded, expected)
        XCTAssertEqual(decoded.id, expected.id)
        XCTAssertEqual(decoded.completedAt, expected.completedAt)
    }
}
