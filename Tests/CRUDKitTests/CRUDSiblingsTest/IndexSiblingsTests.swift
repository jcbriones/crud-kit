@testable import CRUDKit
import XCTVapor

final class IndexSiblingsTests: ApplicationXCTestCase {
    func testIndexWithoutID() throws {
        try routes()
        try seed()
        
        try app.test(.GET, "/planets/1/tags/", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertNotEqual(res.status, .notFound)
            // By design fallback to IndexAll
        })
    }
    
    func testIndexForGivenID() throws {
        try seed()
        try routes()

        let id = 1
        try app.test(.GET, "/planets/1/tags/\(id)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertNotEqual(res.status, .notFound)
            XCTAssertContent(Tag.Public.self, res) {
                XCTAssertEqual($0.id, id)
                XCTAssertNotEqual($0.id, 2)
                XCTAssertContains($0.title, "Todo")
            }
        })
    }
    
    func testIndexForFakeID() throws {
        try seed()
        try routes()
        
        let fakeId1 = 150
        try app.test(.GET, "/planets/1/tags/\(fakeId1)", afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertNotEqual(res.status, .ok)
        })
        
        let fakeId2 = "1a"
        try app.test(.GET, "/planets/1/tags/\(fakeId2)", afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertNotEqual(res.status, .ok)
        })
    }
}
