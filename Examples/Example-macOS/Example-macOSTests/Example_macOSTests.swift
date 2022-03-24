//
//  Example_macOSTests.swift
//  Example-macOSTests
//
//  Created by Patrick Dinger on 3/24/22.
//

import XCTest
@testable import Example_macOS

class Example_macOSTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
//        let bundle = NSBundle(forClass: self.dynamicType)
//            let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        
        let abf = NSStoryboard(name: "MainMenu", bundle: nil)
        
//        let b = Bundle.loadNibNamed("MainMenu", owner: self)
        let controller = ShuffleEmoticonViewController(nibName: "MainMenu", bundle: nil)
        controller.loadView()
//        controller.tableView = NSTableView()
//        controller.tableView.delegate = controller
//        controller.tableView.dataSource = controller
//        controller.loadView()
//        controller.loadView()
//        _ = controller.view // Force to load the view
        controller.shufflePress(NSButton())
        
        let state = controller.dataFromTableState()
        XCTAssertEqual(["lol"], state)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
