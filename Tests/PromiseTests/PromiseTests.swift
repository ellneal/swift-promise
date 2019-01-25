@testable import Promise
import XCTest

class PromiseTests: XCTestCase {
    typealias TestPromise = Promise<String, String>

    func testResolvedThenCallback() {
        let promise = TestPromise { resolve, _ in
            resolve("Value")
        }

        let expectation = self.expectation(description: "Handler called")

        promise.then { result in
            expectation.fulfill()
            XCTAssertEqual(result, "Value")
        }

        waitForExpectations(timeout: 0.1)
    }

    func testRejectedCatchCallback() {
        let promise = TestPromise { _, reject in
            reject("Error")
        }

        let expectation = self.expectation(description: "Handler called")

        promise.catch { error in
            expectation.fulfill()
            XCTAssertEqual(error, "Error")
        }

        waitForExpectations(timeout: 0.1)
    }

    func testRejectedThenCallback() {
        let promise = TestPromise { _, reject in
            reject("Error")
        }

        promise.then { _ in
            XCTFail("Then block should never execute")
        }
    }

    func testResolvedCatchCallback() {
        let promise = TestPromise { resolve, _ in
            resolve("Value")
        }

        promise.catch { _ in
            XCTFail("Catch block should never execute")
        }
    }

    func testNotExecutedWithNoHandlers() {
        _ = TestPromise { _, _ in
            XCTFail("Promise should never execute")
        }
    }

    func testFullfilledPromiseThenCallback() {
        let promise = TestPromise { resolve, _ in
            resolve("Value")
        }

        let expectation = self.expectation(description: "Second handler called")

        promise.then { _ in
            _ = promise.then { result in
                expectation.fulfill()
                XCTAssertEqual(result, "Value")
            }
        }

        waitForExpectations(timeout: 0.1)
    }

    func testFullfilledPromiseCatchCallback() {
        let promise = TestPromise { _, reject in
            reject("Error")
        }

        let expectation = self.expectation(description: "Second handler called")

        promise.catch { _ in
            _ = promise.catch { error in
                expectation.fulfill()
                XCTAssertEqual(error, "Error")
            }
        }

        waitForExpectations(timeout: 0.1)
    }

    func testThenCallbackOrder() {
        let promise = TestPromise { resolve, _ in
            resolve("Value")
        }

        let expectation = self.expectation(description: "Second handler called")

        var index = 0
        promise.then { result in
            XCTAssertEqual(result, "Value")
            XCTAssertEqual(index, 0)
            index += 1
        }.then { result in
            expectation.fulfill()
            XCTAssertEqual(result, "Value")
            XCTAssertEqual(index, 1)
        }

        waitForExpectations(timeout: 0.1)
    }

    func testCatchCallbackOrder() {
        let promise = TestPromise { _, reject in
            reject("Error")
        }

        let expectation = self.expectation(description: "Second handler called")

        var index = 0
        promise.catch { error in
            XCTAssertEqual(error, "Error")
            XCTAssertEqual(index, 0)
            index += 1
        }.catch { error in
            expectation.fulfill()
            XCTAssertEqual(error, "Error")
            XCTAssertEqual(index, 1)
        }

        waitForExpectations(timeout: 0.1)
    }

    func testResolvedPromiseChaining() {
        let promise = TestPromise { resolve, _ in
            resolve("Value")
        }

        let expectation = self.expectation(description: "Second handler called")

        promise.then { _ in
            return Promise<Int, String> { resolve, _ in
                resolve(2)
            }
        }.then { result in
            expectation.fulfill()
            XCTAssertEqual(result, 2)
        }

        waitForExpectations(timeout: 0.1)
    }

    func testRejectedPromiseChaining() {
        let promise = TestPromise { resolve, _ in
            resolve("Value")
        }

        let expectation = self.expectation(description: "Second handler called")

        promise.then { _ in
            return Promise<Int, String> { _, reject in
                reject("Error")
            }
        }.catch { error in
            expectation.fulfill()
            XCTAssertEqual(error, "Error")
        }

        waitForExpectations(timeout: 0.1)
    }
}

extension String: Error { }
