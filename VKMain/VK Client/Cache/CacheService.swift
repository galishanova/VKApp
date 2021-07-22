//
//  CacheService.swift
//  VK Client
//
//  Created by Regina Galishanova on 16.04.2021.
//

import Foundation
import Alamofire

class CacheService {
    

    private let cacheLifeTime: TimeInterval = 30 * 24 * 60 * 60 //время в течение которого кеш считается актуальным (дней, часов, минут и секунд)
    
    private static let pathName: String = {

        let pathName = "images" //имя папки, в которой будут сохраняться изображения

        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return pathName
            
        } //создание кэша

        let url = cachesDirectory.appendingPathComponent(pathName, isDirectory: true)

        if !FileManager.default.fileExists(atPath: url.path) { //проверка, существует ли папка
            
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil) //Если папка не существует, она будет создана.
            
        }
        return pathName
        
    }()
    

    private func getFilePath(url: String) -> String? { //возвращает путь к файлу для сохранения или загрузк
        
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }

        let hashName = url.split(separator: "/").last ?? "default"

        return cachesDirectory.appendingPathComponent(CacheService.pathName + "/" + hashName).path
    }
    

    private func saveImageToCache(url: String, image: UIImage) { //сохраняет изображение в файловой системе
        
        guard let fileName = getFilePath(url: url),
              
        let data = image.pngData() else { return }
        
        FileManager.default.createFile(atPath: fileName, contents: data, attributes: nil)
    }
    
    
    private func getImageFromCache(url: String) -> UIImage? {
        guard
        
            let fileName = getFilePath(url: url),
                
            let info = try? FileManager.default.attributesOfItem(atPath: fileName), //вернёт всю техническую информацию о файле, если он существует
                
            let modificationDate = info[FileAttributeKey.modificationDate] as? Date
            
            else { return nil }
        
        let lifeTime = Date().timeIntervalSince(modificationDate)
        
        guard
            lifeTime <= cacheLifeTime, //проверка если файл устарел, то не загружаем заново его из сети
                let image = UIImage(contentsOfFile: fileName) else { return nil }
        
        DispatchQueue.main.async {
            self.images[url] = image
        }
        
        return image
        
    }
        
    private var images = [String: UIImage]() //словарь в котором будут храниться загруженные и извлеченные из файловой системы изображения
 
    private func loadPhoto(atIndexpath indexPath: IndexPath, byUrl url: String) { //загружает изображение, сохраняет его на диске и в словаре images
        
        AF.request(url).responseData(queue: DispatchQueue.global()) { [weak self] response in
            guard
                let data = response.data,
                let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.images[url] = image
            }
                
            self?.saveImageToCache(url: url, image: image)
                
            DispatchQueue.main.async {
                self?.container.reloadRow(atIndexpath: indexPath)
                
            }
        }
        
    }

    func photo(atIndexpath indexPath: IndexPath, byUrl url: String) -> UIImage? { //предоставляет изображение по URL
    
        var image: UIImage?
    
        if let photo = images[url] { //ищем изображение в кеше оперативной памяти
            
            image = photo
            
        } else if let photo = getImageFromCache(url: url) { //ищем в файловой системе
   
            image = photo
            
        } else {
    
            loadPhoto(atIndexpath: indexPath, byUrl: url) //загружаем из сети если нет в кеше и файловой системе
        }
        return image
    }


    private let container: DataReloadable

        init(container: UITableView) {
            self.container = Table(table: container)
        }
    
        init(container: UICollectionView) {
            self.container = Collection(collection: container)
        }
    }


    fileprivate protocol DataReloadable {
        
        func reloadRow(atIndexpath indexPath: IndexPath)
    }


extension CacheService {

    private class Table: DataReloadable {
        
        let table: UITableView

        init(table: UITableView) {
            self.table = table

        }
        
        func reloadRow(atIndexpath indexPath: IndexPath) {
            
            table.reloadRows(at: [indexPath], with: .none)
            
        }
        
    }


    private class Collection: DataReloadable {
        
        let collection: UICollectionView

        init(collection: UICollectionView) {
            self.collection = collection
        }

        func reloadRow(atIndexpath indexPath: IndexPath) {
            collection.reloadItems(at: [indexPath])
        }
    }
}
