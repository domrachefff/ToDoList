//
//  TodoModel.swift
//  ToDoList
//
//  Created by Алексей on 30.01.2025.
//

import Foundation

struct Todo: Codable {
    var id: Int
    var todo: String
    var completed: Bool
}

struct Todos: Codable {
    var todos: [Todo]
}
