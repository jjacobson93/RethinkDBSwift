import XCTest
@testable import RethinkDBTests

XCTMain([
    testCase(ConnectionTests.allTests),
    testCase(DatesAndTimesTests.allTests),
    testCase(InsertTests.allTests),
    testCase(MathAndLogicTests.allTests),
    testCase(PseudoTypesTests.allTests),
    testCase(QueryTests.allTests),
    testCase(UpdateTests.allTests)
])
