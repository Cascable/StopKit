//
//  StopKitTests.swift
//  StopKitTests
//
//  Created by Daniel Kennett on 2022-07-07.
//  Copyright © 2022 Cascable AB. All rights reserved.
//

import XCTest
@testable import StopKit

class StopKitTests: XCTestCase {

    struct DurationAndExpectedOuput {
        let duration: TimeInterval
        let output: String
    }

    func testExtendedSonyShutterSpeeds() throws {

        let values: [DurationAndExpectedOuput] = [
            DurationAndExpectedOuput(duration: 1.0/32000.0, output: "1/32000"),
            DurationAndExpectedOuput(duration: 1.0/25600.0, output: "1/25600"),
            DurationAndExpectedOuput(duration: 1.0/24000.0, output: "1/24000"),
            DurationAndExpectedOuput(duration: 1.0/20000.0, output: "1/20000"),
            DurationAndExpectedOuput(duration: 1.0/16000.0, output: "1/16000"),
            DurationAndExpectedOuput(duration: 1.0/12800.0, output: "1/12800"),
            DurationAndExpectedOuput(duration: 1.0/12000.0, output: "1/12000"),
            DurationAndExpectedOuput(duration: 1.0/10000.0, output: "1/10000"),
        ]

        for testCase in values {
            let shutterSpeed = try XCTUnwrap(ShutterSpeedValue(approximateDuration: testCase.duration))
            XCTAssertEqual(shutterSpeed.fractionalRepresentation, testCase.output)
        }
    }
}
