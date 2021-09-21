
import Foundation


//MARK: 相册资源
class AlubmsDataSources{
    static var shared = AlubmsDataSources()
    
    //MARK: 仅单例模式
    var photoDataSources:[PhotoDataSource] = []
    private init() {
        if !PhotoSourceManager.shared.didFavoriteAlbumExist(){
            let Favorite = PhotoDataSource(in: "Favorite")
            Favorite.save()
        }
        
        photoDataSources.append(contentsOf: PhotoSourceManager.shared.read())
        
    }
    func deleteAlbums(at paths:[IndexPath]){
        
        let titles = paths.map{photoDataSources[$0.item].title}
        photoDataSources = photoDataSources.filter{!(titles.contains($0.title))}
        
    }
    
    func addNewAlbum(with photos:[Photo?]){
        let p = photos.compactMap{$0}
        if p.count != 0{
            let pd = PhotoDataSource(in: PhotoSourceManager.shared.name(newValue: "Unnamed"),with:p)
            pd.save()
            photoDataSources.append(pd)
        }else{
            let pd = PhotoDataSource(in: PhotoSourceManager.shared.name(newValue: "Unnamed"))
            pd.save()
            photoDataSources.append(pd)
        }
    }
    
    subscript(index:Int)->PhotoDataSource{
        self.photoDataSources[index]
    }
}


//MARK: 每个相册的照片资源
class PhotoDataSource{
    var title:String?{
        didSet{
            if oldValue != title{
                PhotoSourceManager.shared.changeTitle(datasource: self, oldValue: oldValue!)
            }
        }
    }
    var dataSource:Photos = []
    {
        didSet{
            PhotoSourceManager.shared.updateData(datasource: self)
        }
    }
    init(in title:String){
        self.title = title
    }
    init(in title:String,with dataSources:Photos) {
        self.title = title
        self.dataSource.append(contentsOf: dataSources)//先创建文件夹再添加
    }
    
    func save(){
        PhotoSourceManager.shared.createAlbumDirectory(datasource: self)
    }
    
    func addData(dataSources:Photos){
        self.dataSource.insert(contentsOf: dataSources, at: 0)
    }
    
    
    func deleteData(dataSources:Photos){
        self.dataSource = dataSource.filter{
            !dataSources.contains($0)
        }
    }
    //MARK: Subscript
    subscript(index:Int)->Photo{
        self.dataSource[index]
    }
}





