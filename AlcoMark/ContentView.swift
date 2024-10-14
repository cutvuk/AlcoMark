//
//  ContentView.swift
//  AlcoMark
//
//  Created by Aleksandr Khrebtov on 14.10.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [DrinkCategory]
    @State private var isAddingCategory = false
    @State private var newCategoryName = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryDetailView(category: category)) {
                        Text(category.name)
                    }
                }
                .onDelete(perform: deleteCategories)
            }
            .navigationTitle("Категории напитков")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { isAddingCategory = true }) {
                        Label("Добавить категорию", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingCategory) {
                addCategoryView
            }
        }
    }

    private var addCategoryView: some View {
        NavigationView {
            Form {
                TextField("Название категории", text: $newCategoryName)
                Button("Добавить") {
                    addCategory()
                }
            }
            .navigationTitle("Новая категория")
            .navigationBarItems(trailing: Button("Отмена") {
                isAddingCategory = false
            })
        }
    }

    private func addCategory() {
        withAnimation {
            let newCategory = DrinkCategory(name: newCategoryName)
            modelContext.insert(newCategory)
        }
        newCategoryName = ""
        isAddingCategory = false
    }

    private func deleteCategories(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(categories[index])
            }
        }
    }
}

