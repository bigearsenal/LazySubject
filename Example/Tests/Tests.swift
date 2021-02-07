import XCTest
import LazySubject
import RxSwift

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLazyVariable() throws {
        // This is an example of a functional test case.
        let delay: UInt32 = 1
        
        // In case of success
        let expectation = self.expectation(description: "LoadingSuccessfully")
        let request = Single<String>.just("Test")
            .delay(.seconds(Int(delay)), scheduler: MainScheduler.instance)
            .do(afterSuccess: {_ in
                expectation.fulfill()
            })
        let subject = LazySubject(value: "", request: request)
        
        XCTAssertEqual(subject.state, .initializing)
        XCTAssertEqual(subject.value, "")
        
        subject.reload()
        
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(subject.state, .loaded)
        XCTAssertEqual(subject.value, "Test")
        
        // In case of failure
        let expectation2 = self.expectation(description: "LoadingFailed")
        enum Error: Swift.Error {
            case test
        }
        let error = Error.test
        let errorRequest = Single<String>.error(Error.test)
            .delay(.seconds(Int(delay)), scheduler: MainScheduler.instance)
            .do(afterError: {_ in
                expectation2.fulfill()
            })
        
        subject.request = errorRequest
        
        subject.reload()
        
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(subject.state, .error(error))
    }
}
