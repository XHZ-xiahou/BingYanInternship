
import UIKit

class PhotoSourceManager{
    
    
    static var shared = PhotoSourceManager()
    lazy var manager = FileManager.default
    
    //MARK: 仅单例模式
    private init(){}
    
    func didFavoriteAlbumExist()->Bool{
        let filePath:String = NSHomeDirectory() + "/Documents/这货不是相册"
        if let subpath = manager.subpaths(atPath: filePath)?.filter({$0 != ".DS_Store"}){
            if subpath.contains("Favorite"){
                return true
            }
        }
        return false
    }
    func createAlbumDirectory(datasource:PhotoDataSource){
        let filePath:String = NSHomeDirectory() + "/Documents/这货不是相册/\(datasource.title!)"
        try! manager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
        for (i,photo) in datasource.dataSource.enumerated(){
//            let data = photo.jpegData(compressionQuality: 1)
            let data = photo.pngData()
            try? data?.write(to: URL(fileURLWithPath: filePath+"/\(i)"))
            
        }
    }
    
    
    func updateData(datasource:PhotoDataSource){//include add & delete
        let filePath:String = NSHomeDirectory() + "/Documents/这货不是相册/\(datasource.title!)"
        if let subpath = manager.subpaths(atPath: filePath)?.filter({$0 != ".DS_Store"}){
            for file in subpath{
                try! manager.removeItem(atPath: filePath+"/"+file)
            }
        }
        for (i,photo) in datasource.dataSource.enumerated(){
            let data = photo.pngData()
            try? data?.write(to: URL(fileURLWithPath: filePath+"/\(i)"))
        }
    }
    
    func deleteAlbums(at datasources:[PhotoDataSource]){
        datasources.forEach{
            try! manager.removeItem(atPath: NSHomeDirectory() + "/Documents/这货不是相册/\($0.title!)")
        }
    }
    
    
    func changeTitle(datasource:PhotoDataSource,oldValue:String){
        try! manager.removeItem(atPath: NSHomeDirectory() + "/Documents/这货不是相册/\(oldValue)")
        createAlbumDirectory(datasource: datasource)
    }
    
    
    func read()->[PhotoDataSource]{
        var datas:[PhotoDataSource] = []
        let filePath:String = NSHomeDirectory() + "/Documents/这货不是相册"
//        print(filePath)
        let contentPaths = (try? manager.contentsOfDirectory(atPath: filePath))?.filter{$0 != ".DS_Store"}
        if contentPaths == nil{
            return []
        }
        
        for path in contentPaths!{
            let title = path
            let contentpaths = try? manager.contentsOfDirectory(atPath: filePath+"/\(title)").sorted(by: <)
            
            datas.append(PhotoDataSource(in: String(title), with: (contentpaths?.compactMap{
                let readHandler = try! FileHandle(forReadingFrom:URL(fileURLWithPath: filePath+"/\(title)/"+$0))
                return UIImage(data: readHandler.readDataToEndOfFile(), scale: 1)
            })!))
        }
        datas.sort{ $0.title! < $1.title! }
        return datas
    }
    
    func name(newValue:String)->String{
        let filePath:String = NSHomeDirectory() + "/Documents/这货不是相册"
        if let contentPaths = (try? manager.contentsOfDirectory(atPath: filePath))?.filter({$0 != ".DS_Store"}){
            return naming(nam: newValue, followScript: 0, contentPaths: contentPaths)
        }
        return "Unnamed"
    }
    
    //MARK:递归取名
    private func naming(nam:String,followScript:Int,contentPaths:[String])->String{
        if contentPaths.contains(nam+"\(followScript)") || (contentPaths.contains(nam) && followScript==0){
            return naming(nam: nam, followScript: followScript+1, contentPaths: contentPaths)
        }
        if followScript==0{return nam}
        return nam+"\(followScript)" 
    }
}

