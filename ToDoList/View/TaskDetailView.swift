//
//  TaskDetailView.swift
//  ToDoList
//
//  Created by Алексей on 31.01.2025.
//

import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TodoViewModel
    @State private var title: String
    @State private var description: String
    @State private var date: Date
    
    var task: Item?
    
    init(viewModel: TodoViewModel, task: Item? = nil) {
        self.viewModel = viewModel
        _title = State(initialValue: task?.title ?? "")
        _description = State(initialValue: task?.todoDescription ?? "")
        _date = State(initialValue: task?.completedDate ?? Date())
        self.task = task
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Название", text: $title)
                    .font(.title2)
                DatePicker("Дата", selection: $date, displayedComponents: .date)
                TextEditor(text: $description)
                    .frame(minHeight: 250, maxHeight: .infinity)
            }
            .navigationTitle(task == nil ? "Новая задача" : "Редактировать")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        viewModel.saveTask(title: title, description: description, date: date, task: task)
                        dismiss()
                    }
                }
            }
        }
    }
}
