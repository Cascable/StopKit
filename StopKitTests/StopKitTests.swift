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

    struct FractionAndExpectedOuput {
        let numerator: Int
        let denominator: Int
        let output: String
        let duration: TimeInterval
    }

    func testExtendedNikonShutterSpeeds() throws {

        let values: [FractionAndExpectedOuput] = [
            FractionAndExpectedOuput(numerator: 60, denominator: 1, output: "60", duration: 60),
            FractionAndExpectedOuput(numerator: 90, denominator: 1, output: "90", duration: 90),
            FractionAndExpectedOuput(numerator: 120, denominator: 1, output: "120", duration: 120),
            FractionAndExpectedOuput(numerator: 180, denominator: 1, output: "180", duration: 180),
            FractionAndExpectedOuput(numerator: 240, denominator: 1, output: "240", duration: 240),
            FractionAndExpectedOuput(numerator: 300, denominator: 1, output: "300", duration: 300),
            FractionAndExpectedOuput(numerator: 480, denominator: 1, output: "480", duration: 480),
            FractionAndExpectedOuput(numerator: 600, denominator: 1, output: "600", duration: 600),
            FractionAndExpectedOuput(numerator: 720, denominator: 1, output: "720", duration: 720),
            FractionAndExpectedOuput(numerator: 900, denominator: 1, output: "900", duration: 900),
        ]

        for testCase in values {
            let decimalSpeed: Double = Double(testCase.numerator) / Double(testCase.denominator)
            let stops: Double = log(decimalSpeed) / log(2.0)
            let speed = ShutterSpeedValue(stopsFromASecond: ExposureStops(fromDecimalValue: stops))
            XCTAssertEqual(speed.localizedDisplayValue, testCase.output)
            XCTAssertEqual(speed.approximateTimeInterval, testCase.duration, accuracy: 0.01)
            XCTAssertEqual(Int(speed.upperFractionalValue), testCase.numerator)
            XCTAssertEqual(Int(speed.lowerFractionalValue), testCase.denominator)
        }
    }

    func testSecureCodingRoundTrip() throws {

        let stops = ExposureStops(wholeStops: 1, fraction: .oneHalf, isNegative: false)
        let encodedStops = try NSKeyedArchiver.archivedData(withRootObject: stops, requiringSecureCoding: true)
        let decodedStops = try NSKeyedUnarchiver.unarchivedObject(ofClass: ExposureStops.self, from: encodedStops)
        XCTAssertEqual(stops, decodedStops)

        let shutterSpeed = ShutterSpeedValue.oneSecondShutterSpeed
        let encodedSpeed = try NSKeyedArchiver.archivedData(withRootObject: shutterSpeed, requiringSecureCoding: true)
        let decodedSpeed = try NSKeyedUnarchiver.unarchivedObject(ofClass: ShutterSpeedValue.self, from: encodedSpeed)
        XCTAssertEqual(shutterSpeed, decodedSpeed)

        let shutterIndeterminateSpeed = IndeterminateShutterSpeedValue(name: "Hello")!
        let encodedIndeterminateSpeed = try NSKeyedArchiver.archivedData(withRootObject: shutterIndeterminateSpeed, requiringSecureCoding: true)
        let decodedIndeterminateSpeed = try NSKeyedUnarchiver.unarchivedObject(ofClass: ShutterSpeedValue.self, from: encodedIndeterminateSpeed)
        XCTAssertEqual(shutterIndeterminateSpeed, decodedIndeterminateSpeed)

        let aperture = ApertureValue.f2Point8
        let encodedAperture = try NSKeyedArchiver.archivedData(withRootObject: aperture, requiringSecureCoding: true)
        let decodedAperture = try NSKeyedUnarchiver.unarchivedObject(ofClass: ApertureValue.self, from: encodedAperture)
        XCTAssertEqual(aperture, decodedAperture)

        let apertureIndeterminate = AutoApertureValue.automaticAperture
        let encodedIndeterminateAperture = try NSKeyedArchiver.archivedData(withRootObject: apertureIndeterminate, requiringSecureCoding: true)
        let decodedIndeterminateAperture = try NSKeyedUnarchiver.unarchivedObject(ofClass: ApertureValue.self, from: encodedIndeterminateAperture)
        XCTAssertEqual(apertureIndeterminate, decodedIndeterminateAperture)

        let isoSpeed = ISOValue.iso1600
        let encodedISO = try NSKeyedArchiver.archivedData(withRootObject: isoSpeed, requiringSecureCoding: true)
        let decodedISO = try NSKeyedUnarchiver.unarchivedObject(ofClass: ISOValue.self, from: encodedISO)
        XCTAssertEqual(isoSpeed, decodedISO)

        let isoIndeterminate = AutoISOValue.automaticISO
        let encodedIndeterminateISO = try NSKeyedArchiver.archivedData(withRootObject: isoIndeterminate, requiringSecureCoding: true)
        let decodedIndeterminateISO = try NSKeyedUnarchiver.unarchivedObject(ofClass: ISOValue.self, from: encodedIndeterminateISO)
        XCTAssertEqual(isoIndeterminate, decodedIndeterminateISO)

        let ev = ExposureCompensationValue.zeroEV
        let encodedEv = try NSKeyedArchiver.archivedData(withRootObject: ev, requiringSecureCoding: true)
        let decodedEv = try NSKeyedUnarchiver.unarchivedObject(ofClass: ExposureCompensationValue.self, from: encodedEv)
        XCTAssertEqual(ev, decodedEv)
    }
}
