//
//  CategoryDetailView.swift
//  AlcoMark
//
//  Created by Aleksandr Khrebtov on 14.10.2024.
//

import SwiftUI
import SwiftData
import CodeScanner

struct CategoryDetailView: View {
    @Bindable var category: DrinkCategory
    @State private var isAddingDrink = false
    @State private var scannedCode: String?
    @State private var isFullBottle = true
    @State private var customVolume: String = ""
    @State private var alcoName: String = ""
    
    var body: some View {
        List {
            ForEach(category.items) { item in
                VStack(alignment: .leading) {
                    Text(item.alcoName)
                        .font(.headline)
                    Text(item.exciseStampCode)
                        .font(.subheadline)
                    Text("\(item.volume) л")
                        .font(.subheadline)
                }
            }
            .onDelete(perform: deleteDrinks)
        }
        .navigationTitle(category.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isAddingDrink = true }) {
                    Label("Добавить", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddingDrink) {
            addDrinkView
        }
    }
    
    private var addDrinkView: some View {
        NavigationView {
            VStack {
                if let scannedCode = scannedCode {
                    Text("Отсканированный код: \(scannedCode)")
                    Toggle("Полная бутылка", isOn: $isFullBottle)
                    if !isFullBottle {
                        TextField("Объем (л)", text: $customVolume)
                            .keyboardType(.decimalPad)
                    }
                    TextField("Название напитка", text: $alcoName)
                        .keyboardType(.default)
                    Button("Сохранить") {
                        saveDrink()
                    }
                } else {
                    CodeScannerView(codeTypes: [.qr, .pdf417, .dataMatrix], showViewfinder: true, completion: handleScan)
                        .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                }
            }
            .navigationTitle("Отсканируйте марку")
            .navigationBarItems(trailing: Button("Отмена") {
                isAddingDrink = false
                scannedCode = nil
            })
        }
    }
    
    private func handleScan(result: Result<ScanResult, ScanError>) {
        isAddingDrink = false
        switch result {
        case .success(let result):
            scannedCode = result.string
            isAddingDrink = true
        case .failure(let error):
            print("Ошибка сканирования: \(error.localizedDescription)")
        }
    }
    
    private func saveDrink() {
        if let code = scannedCode {
            let volume = isFullBottle ? "full" : customVolume
            let alcoName = alcoName
            let newDrink = DrinkItem(exciseStampCode: code, volume: volume, alcoName: alcoName)
            
            category.items.append(newDrink)
        }
        isAddingDrink = false
        scannedCode = nil
    }
    
    private func deleteDrinks(at offsets: IndexSet) {
        category.items.remove(atOffsets: offsets)
    }
    
    
    
}
