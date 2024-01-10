//
//  XCTestCase+Extension.swift
//

import XCTest

extension XCTestCase {

    func execute(

        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line,
        _ task: @escaping (() async throws -> Void)

    ) {

        let expectation = expectation(description: "Wait for completion")

        Task {

            do {

                try await task()

            } catch {

                XCTFail("Unexpected error: \(error)", file: file, line: line)
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    func execute(

        exp: XCTestExpectation,
        file: StaticString = #file,
        line: UInt = #line,
        _ task: @escaping (() async throws -> Void)

    ) {

        Task {

            do {

                try await task()

            } catch {

                XCTFail("Unexpected error: \(error)", file: file, line: line)
            }

            exp.fulfill()
        }
    }

    func expectToThrow<E: Error & Equatable>(

        _ expectedError: E,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line,
        _ task: @escaping (() async throws -> Void)

    ) {

        let expectation = expectation(description: "Wait for completion")

        Task {

            do {

                try await task()

            } catch {

                XCTAssertEqual(error as? E, expectedError, file: file, line: line)
                expectation.fulfill()

                return
            }

            expectation.fulfill()

            XCTFail(

                "Expected to throw: \(expectedError), successfully finished instead.",
                file: file,
                line: line
            )
        }

        wait(for: [expectation], timeout: timeout)
    }

    func trackMemoryLeak(

        for object: AnyObject,
        file: StaticString = #file,
        line: UInt = #line

    ) {

        { [weak object] in

            addTeardownBlock {

                XCTAssertNil(object, file: file, line: line)
            }
        }()
    }
}
