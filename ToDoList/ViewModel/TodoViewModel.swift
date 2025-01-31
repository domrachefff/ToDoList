//
//  TodoViewModel.swift
//  ToDoList
//
//  Created by Алексей on 31.01.2025.
//

import SwiftUI
import CoreData

class TodoViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var searchText: String = ""
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchItems()
    }
    
    func fetchItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.idAPI, ascending: true)]
        
        if !searchText.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR todoDescription CONTAINS[cd] %@", searchText, searchText)
        }
        
        do {
            items = try context.fetch(request)
        } catch {
            print("Error fetching items: \(error.localizedDescription)")
        }
    }
    
    func toggleTaskStatus(_ item: Item) {
        item.completed.toggle()
        saveContext()
    }
    
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            context.delete(item)
        }
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
            fetchItems()
            print("Todos успешно обновлены в Core Data")
        } catch {
            print("Ошибка сохранения в Core Data: \(error.localizedDescription)")
        }
    }
    
    func saveTask(title: String, description: String, date: Date, task: Item? = nil) {
        if let task = task {
            task.title = title
            task.todoDescription = description
            task.completedDate = date
        } else {
            let newTask = Item(context: context)
            newTask.id = UUID()
            newTask.title = title
            newTask.todoDescription = description
            newTask.completedDate = date
            newTask.completed = false
        }
        saveContext()
    }
    
    func updateTodosFromAPI() {
        guard let url = URL(string: "https://dummyjson.com/todos") else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Ошибка загрузки данных: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("Данные отсутствуют")
                    return
                }

                do {
                    let decodedData = try JSONDecoder().decode(Todos.self, from: data)
                    self.saveToCoreData(decodedData.todos)
                } catch {
                    print("Ошибка декодирования JSON: \(error.localizedDescription)")
                }
            }.resume()
        }
    }
    
    private func saveToCoreData(_ todos: [Todo]) {
        context.perform {
            do {
                for todo in todos {
                    let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "idAPI == %d", todo.id)

                    if let existingTodo = try self.context.fetch(fetchRequest).first {
                        existingTodo.title = todo.todo
                        existingTodo.completed = todo.completed
                    } else {
                        let newTodo = Item(context: self.context)
                        newTodo.idAPI = Int16(todo.id)
                        newTodo.title = todo.todo
                        newTodo.completed = todo.completed
                        newTodo.id = UUID()
                    }
                }

                try self.context.save()
                print("Todos успешно обновлены в Core Data")
            } catch {
                print("Ошибка сохранения в Core Data: \(error.localizedDescription)")
            }
        }
    }
}

