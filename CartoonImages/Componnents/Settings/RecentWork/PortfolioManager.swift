import Foundation
import UIKit

class PortfolioManager {
    static let shared = PortfolioManager()
    
    private struct ImageRecord {
        let fileName: String
        let date: Date
    }
    
    private var images: [ImageRecord] = []
    private let calendar = Calendar.current
    private let maxDays = 30
    private let fileManager = FileManager.default
    private let directoryURL: URL
    
    private init() {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        directoryURL = documentsURL.appendingPathComponent("Images")

        // 创建 Images 文件夹（如果不存在）
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create Images directory: \(error)")
            }
        }

        loadImages()
        removeExpiredImages()
    }
    
    func saveImage(_ image: UIImage) {
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = directoryURL.appendingPathComponent(fileName)
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            do {
                try imageData.write(to: fileURL)
                images.append(ImageRecord(fileName: fileName, date: Date()))
                removeExpiredImages()
                saveImages()
            } catch {
                print("Failed to save image: \(error)")
            }
        }
    }
    
    func deleteImage(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            if let record = images.first(where: { imageFromFile(named: $0.fileName)?.jpegData(compressionQuality: 0.8) == imageData }) {
                let fileURL = directoryURL.appendingPathComponent(record.fileName)
                do {
                    try fileManager.removeItem(at: fileURL)
                } catch {
                    print("Failed to delete image: \(error)")
                }
                images.removeAll { $0.fileName == record.fileName }
                saveImages()
            }
        }
    }
    
    func getRecentImages() -> [UIImage] {
        removeExpiredImages()
        return images.sorted { $0.date > $1.date }.compactMap { imageFromFile(named: $0.fileName) }
    }
    
    private func imageFromFile(named fileName: String) -> UIImage? {
        let fileURL = directoryURL.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    private func removeExpiredImages() {
        let expirationDate = calendar.date(byAdding: .day, value: -maxDays, to: Date())!
        images.removeAll { record in
            if record.date < expirationDate {
                let fileURL = directoryURL.appendingPathComponent(record.fileName)
                try? fileManager.removeItem(at: fileURL)
                return true
            }
            return false
        }
        saveImages()
    }
    
    private func saveImages() {
        let data = images.map { ["fileName": $0.fileName, "date": $0.date.timeIntervalSince1970] }
        UserDefaults.standard.setValue(data, forKey: "PortfolioImages")
    }
    
    private func loadImages() {
        guard let storedData = UserDefaults.standard.array(forKey: "PortfolioImages") as? [[String: Any]] else { return }
        images = storedData.compactMap {
            guard let fileName = $0["fileName"] as? String,
                  let dateInterval = $0["date"] as? TimeInterval else { return nil }
            return ImageRecord(fileName: fileName, date: Date(timeIntervalSince1970: dateInterval))
        }
    }
}
