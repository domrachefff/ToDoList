//
//  ContentView.swift
//  ToDoList
//
//  Created by Алексей on 30.01.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var viewModel = TodoViewModel(context: PersistenceController.shared.container.viewContext)
    
    @State private var isShowingAddTask = false
    @State private var selectedTask: Item?
    
    var body: some View {
            NavigationView {
                VStack {
                    SearchBar(text: $viewModel.searchText)
                    List {
                        ForEach(viewModel.items) { item in
                            NavigationLink(destination: TaskDetailView(viewModel: viewModel, task: item)) {
                                HStack {
                                    Button(action: {
                                        viewModel.toggleTaskStatus(item)
                                    }) {
                                        Image(systemName: item.completed ? "checkmark.circle" : "circle")
                                            .font(.system(size: 24))
                                            .foregroundColor(item.completed ? .yellow : .gray)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    VStack(alignment: .leading) {
                                        Text(item.title ?? "")
                                            .font(.headline)
                                            .strikethrough(item.completed, color: .gray)
                                        Text(item.todoDescription ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(item.completed ? .gray : .primary)
                                            .lineLimit(2)
                                        Text(item.completedDate != nil ? itemFormatter.string(from: item.completedDate!) : "")
                                            .font(.caption)
                                            .foregroundColor(.gray)

                                    }
                                }
                            }
                        }
                        .onDelete(perform: viewModel.deleteItems)
                    }
                    .refreshable {
                        viewModel.updateTodosFromAPI()
                        viewModel.fetchItems()
                     }
                    .navigationTitle("Задачи")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                selectedTask = nil
                                isShowingAddTask = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $isShowingAddTask) {
                        TaskDetailView(viewModel: viewModel, task: selectedTask)
                    }
                }
            }
            .onAppear(perform: {
                viewModel.updateTodosFromAPI()
                viewModel.fetchItems()
            })
            .onChange(of: viewModel.searchText) {
                viewModel.fetchItems()
            }
        }
        
        private var itemFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter
        }
}

#Preview {
    ContentView()
}

