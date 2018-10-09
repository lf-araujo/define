import XCTest

import DefineTests

var tests = [XCTestCaseEntry]()
tests += DefineTests.allTests()
XCTMain(tests)