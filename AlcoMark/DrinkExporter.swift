//
//  DrinkExporter.swift
//  AlcoMark
//
//  Created by Aleksandr Khrebtov on 18.10.2024.
//


import SwiftUI
import UniformTypeIdentifiers

class DrinkExporter {
    static func generateCSVFile(from drinks: [DrinkItem], categoryName: String) -> URL {
        // Создаем временную директорию для файла
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        
        
        
        // Формируем имя файла, заменяя недопустимые символы на подчеркивания
        let safeCategoryName = categoryName.replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        
        let fileName = "\(safeCategoryName).csv"
        let fileURL = tempDirectoryURL.appendingPathComponent(fileName)
        
        // Создаем содержимое CSV
        var csvString = "Название;Акцизная марка;Объем\n"
        
        for drink in drinks {
            let volume = drink.volume
            csvString += "\(drink.alcoName);\(drink.exciseStampCode);\(volume)\n"
        }
        
        // Записываем в файл
        try? csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        
        return fileURL
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
