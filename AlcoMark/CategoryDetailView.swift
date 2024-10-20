//
//  CategoryDetailView.swift
//  AlcoMark
//
//  Created by Aleksandr Khrebtov on 14.10.2024.
//

import SwiftUI
import SwiftData
import CodeScanner
import UniformTypeIdentifiers
import AVFoundation

struct CategoryDetailView: View {
    
    @Bindable var category: DrinkCategory
    @State private var isAddingDrink = false
    @State private var scannedCode: String?
    @State private var isFullBottle = false
    @State private var customVolume: String = ""
    @State private var alcoName: String = ""
    @State private var sortOption: SortOption = .recent
    @State private var showingExportSheet = false
    @State private var isFlashlightOn = false
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var overwriteDrink = false
    
    enum SortOption {
        case alphabetical
        case recent
    }
    
    private var sortedItems: [DrinkItem] {
        switch sortOption {
        case .alphabetical:
            return category.items.sorted { $0.alcoName.localizedCaseInsensitiveCompare($1.alcoName) == .orderedAscending }
        case .recent:
            return category.items.reversed()
        }
    }
    
    var body: some View {
        List {
            ForEach(sortedItems) { item in // Заменяем category.items на sortedItems
                VStack(alignment: .leading) {
                    Text(item.alcoName)
                        .font(.headline)
                    Text(item.exciseStampCode)
                        .font(.system(size: 10))
                        .fontWeight(.light)
                        .foregroundColor(.secondary)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = item.exciseStampCode
                            }) {
                                Text("Скопировать марку")
                                Image(systemName: "doc.on.doc")
                            }
                        }
                    
                    
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
            
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button(action: { sortOption = .recent }) {
                        Label("По времени добавления", systemImage: "clock")
                    }
                    Button(action: { sortOption = .alphabetical }) {
                        Label("По алфавиту", systemImage: "textformat.abc")
                    }
                    
                    
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                ShareLink(
                    item: generateCSVFile(from: sortedItems),
                    preview: SharePreview(
                        "Экспорт \(category.name).csv",
                        image: "doc.text"
                    )
                ) {
                    Label("Экспорт", systemImage: "square.and.arrow.up")
                }
                
            }
            
            
        }
        
        .sheet(isPresented: $isAddingDrink) {
            addDrinkView
            
        }
    }
    
    private var addDrinkView: some View {
        NavigationView {
            VStack { if overwriteDrink {
                Text("Этот код уже был отсканирован. При сохранении старый код перезапишется")
                    .padding()
                    .foregroundColor(.red)
            }
                
              
                
                if let scannedCode = scannedCode {
                    Text("Отсканированный код: \(scannedCode)")
                        .padding()
                    
                    Spacer()
                    
                    TextField("Название напитка", text: $alcoName)
                        .keyboardType(.default)
                        .padding()
                    
                    
                    Toggle("Полная бутылка", isOn: $isFullBottle)
                        .padding()
                    
                    
                    if !isFullBottle {
                        
                        TextField("Объем (л)", text: $customVolume)
                            .keyboardType(.decimalPad)
                            .onAppear {
                                customVolume = "0,"
                                
                            }
                            .padding()
                    }
                    
                    else {
                        Text("Полная")
                            .padding()
                    }
                    
                        
                    
                    Spacer()
                    HStack {
                        Button("Сохранить и выйти") {
                            saveDrink()
                        }
                        .frame(maxWidth: 150, minHeight: 50)
                        .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .cornerRadius(10)
                        Button("Сохранить и добавить") {
                            saveDrink()
                            isAddingDrink = true
                        }
                        .frame(maxWidth: 150, minHeight: 50)
                        .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .cornerRadius(10)
                    }}
                else {
                    CodeScannerView(codeTypes: [.qr, .pdf417, .dataMatrix], showViewfinder: true, isTorchOn: isFlashlightOn, completion: handleScan)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                      
                }
            }
            .navigationTitle("Отсканируйте марку")
            .navigationBarItems(leading: Button(action: {
              isFlashlightOn.toggle()
            }) {
                Image(systemName: isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isFlashlightOn ? .yellow : .gray)
                    .padding()
            })
            
            .navigationBarItems(trailing: Button("Отмена") {
                isAddingDrink = false
                scannedCode = nil
                if isFlashlightOn {
                    isFlashlightOn = false
                }
            })
        }
    }
    
    private func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            scannedCode = result.string
            if category.items.contains(where: { $0.exciseStampCode == result.string }) {
                overwriteDrink = true
            }
        case .failure(let error):
            alertMessage = "Ошибка сканирования: \(error.localizedDescription)"
            isShowingAlert = true
        }
    }
    
    private func saveDrink() {
        if let code = scannedCode {
            let volume = isFullBottle ? "full" : customVolume
            let alcoName = alcoName
            let newDrink = DrinkItem(exciseStampCode: code, volume: volume, alcoName: alcoName)
            if overwriteDrink {
                if let index = category.items.firstIndex(where: { $0.exciseStampCode == code }) {
                    category.items.remove(at: index)
                }
            }
            category.items.append(newDrink)
        }
        isAddingDrink = false
        scannedCode = nil
    }
    
    private func deleteDrinks(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { sortedItems[$0] }
        itemsToDelete.forEach { item in
            if let index = category.items.firstIndex(where: { $0.id == item.id }) {
                category.items.remove(at: index)
            }
        }
    }
    
    private func generateCSVFile(from drinks: [DrinkItem]) -> URL {
        DrinkExporter.generateCSVFile(from: drinks, categoryName: category.name)
    }
    
   
 

}
