import Foundation
import XCTest
@testable import LocalDataKit

final class CompletionHistoryTests: XCTestCase {
    func testSectionsUseActivityDaysAndSortDaysAndCompletionsNewestFirst() {
        let previousDayID = UUID(uuidString: "aaaaaaaa-1111-1111-1111-111111111111")!
        let earlyID = UUID(uuidString: "aaaaaaaa-2222-2222-2222-222222222222")!
        let lateID = UUID(uuidString: "aaaaaaaa-3333-3333-3333-333333333333")!
        let sections = CompletionHistory.sections(
            from: [
                completion(id: earlyID, minutes: 5, at: testDate(2026, 7, 13, 5)),
                completion(id: previousDayID, minutes: 7, at: testDate(2026, 7, 13, 3, 30)),
                completion(id: lateID, minutes: 8, at: testDate(2026, 7, 13, 9)),
            ],
            calendar: testCalendar(),
            rolloverHour: 4
        )

        XCTAssertEqual(sections.map(\.activityDay), [
            testDate(2026, 7, 13),
            testDate(2026, 7, 12),
        ])
        XCTAssertEqual(sections[0].completions.map(\.id), [lateID, earlyID])
        XCTAssertEqual(sections[1].completions.map(\.id), [previousDayID])
    }
}
