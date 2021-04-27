import Foundation


import Foundation
import HttpExecuter
import XCTest

@testable import SQLHttp

class SQLHttpClientTests: XCTestCase {
    
    let client = SQLHttpClient(
        endpoint: "http://localhost:8083/",
        dataSourceReference: .direct(
            .init(
                jdbcURL: "jdbc:mysql://sql-http-swift-mysql:3306/test_db",
               credentials: .init(username: "test_user", password: .init("test_password"))
            )
        )
    )
    
    override func setUp() {
        super.setUp()
        let lock = NSLock()
        lock.lock()
        self.client.write(
            "DROP TABLE IF EXISTS test_table"
        ).execute { _, _ in
            self.client.write(
                """
                CREATE TABLE `test_table` (
                    `first_name` VARCHAR(255) NOT NULL,
                    `age` INT NOT NULL,
                    `created_at` DATETIME(6) NOT NULL,
                    `favorite_quote` VARCHAR(255) NULL
                )
                """
            ).execute { _, err in
                lock.unlock()
            }
        }
        lock.lock()
    }
    
    
    func testWriteAndRead() {
        let exp = expectation(description: "write and read")
        let now = Date()
        client.write(
            """
            INSERT INTO test_table (
                first_name,
                age,
                created_at,
                favorite_quote
            ) VALUES (
                :first_name,
                :age,
                :created_at,
                :favorite_quote
            )
            """
        )
        .addParam("first_name", .string("Bob"))
        .addParam("age", .int(22))
        .addParam("created_at", .date(now))
        .addParam("favorite_quote", .null)
        .execute { rs, err in
            self.client.query(
                "SELECT * FROM test_table WHERE first_name = :first_name"
            )
            .addParam("first_name", .string("Bob"))
            .execute { rows, _ in
                XCTAssertEqual(rows![0]["first_name"].string, "Bob")
                XCTAssertEqual(rows![0]["age"].int, 22)
                XCTAssertTrue(rows![0]["favorite_quote"].isNull)
                let createdAtEpoch = rows![0]["created_at"].date.timeIntervalSince1970
                XCTAssertTrue(abs(now.timeIntervalSince1970 - createdAtEpoch) < 0.01)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 5)
    }
    
    
    func testBatchWrite() {
        let exp = expectation(description: "write")
        let now = Date()
        client.batchWrite(
            """
            INSERT INTO test_table (
                first_name,
                age,
                created_at
            ) VALUES (
                :first_name,
                :age,
                :created_at
            )
            """
        ).addBatch([
            "first_name": .string("Bob"),
            "age": .int(22),
            "created_at": .date(now)
        ])
        .addBatch([
            "first_name": .string("Susan"),
            "age": .int(23),
            "created_at": .date(now)
        ])
        .execute { rs, err in
            XCTAssertEqual(rs!.numberOfAffectedRows.count, 2)
            XCTAssertEqual(rs!.numberOfAffectedRows[0], 1)
            XCTAssertEqual(rs!.numberOfAffectedRows[1], 1)
            self.client.query(
                "SELECT * FROM test_table"
            )
            .execute { rows, err in
                let set = Set(rows!.map { $0["first_name"].string })
                XCTAssertEqual(set, ["Bob", "Susan"])
                exp.fulfill()
            }
            
            

        }
        waitForExpectations(timeout: 5)
    }
    
}
