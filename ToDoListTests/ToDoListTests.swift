//
//  ToDoListTests.swift
//  ToDoListTests
//
//  Created by Алексей on 31.01.2025.
//

import XCTest
import CoreData
@testable import ToDoList

final class ToDoListTests: XCTestCase {

    var viewModel: TodoViewModel!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        viewModel = TodoViewModel(context: context)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        context = nil
        try super.tearDownWithError()
    }

    func testFetchItems() throws {
         // Add a test task to Core Data
         let task = Item(context: context)
         task.title = "Test Task"
         task.completed = false
        task.completedDate = Date()
         try context.save()
         
         viewModel.fetchItems()
         
         XCTAssertEqual(viewModel.items.count, 1)
         XCTAssertEqual(viewModel.items.first?.title, "Test Task")
     }

    func testToggleTaskStatus() throws {
        let task = Item(context: context)
        task.title = "Test Task"
        task.completed = false
        task.completedDate = Date()
        try context.save()
        
        viewModel.fetchItems()
        
        if let task = viewModel.items.first {
            viewModel.toggleTaskStatus(task)
        }
        
        XCTAssertEqual(viewModel.items.first?.completed, true)
    }
    
    func testDeleteItems() throws {
        let task = Item(context: context)
        task.title = "Test Task"
        task.completed = false
        task.completedDate = Date()
        try context.save()
        
        viewModel.fetchItems()
        
        viewModel.deleteItems(at: IndexSet(integer: 0))
        
        XCTAssertEqual(viewModel.items.count, 0)
    }
    
    func testSaveTask() throws {
        viewModel.saveTask(title: "New Task", description: "New Description", date: Date())
        
        viewModel.fetchItems()
        
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.items.first?.title, "New Task")
        XCTAssertEqual(viewModel.items.first?.todoDescription, "New Description")
    }

}
