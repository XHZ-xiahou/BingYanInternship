//
//  ViewController.swift
//  这货不是相册
//
//  Created by XHZ on 2021/3/19.
//
import UIKit

class ViewController: UIViewController{

    
    lazy var rightButton = UIBarButtonItem(image: nil, style: .plain, target: self, action:  #selector(deleteAlbum))
    lazy var leftButton = UIBarButtonItem(image: nil, style: .plain, target: self, action:  #selector(cancelDelete))
    
    
    @objc func cancelDelete(_ sender: Any) {
        if onTrashing{
            onTrashing = false
        }else{
            leftButton.image = UIImage(systemName: albumView.faceStyle ? "square.grid.3x2":"square.grid.2x2")
            albumView.faceStyle.toggle()
        }
    }
    
    
    @objc func deleteAlbum(_ sender: Any) {
        
        if onTrashing && allCellsSelected.count>0{ deleteAlbumCells() }
        
        onTrashing.toggle()
    }
    
    var viewControllerDidChange:(()->Void)?
    lazy var albumView = AlbumView()
    var tempPhoto:Photo!
    
    private var allCells:[AlbumViewCell]{
        albumView.collectionView.visibleCells.compactMap{$0 as? AlbumViewCell}.filter{$0.countView != nil}
    }
    private var allCellsSelected:[AlbumViewCell]{
        allCells.filter{$0.deleteSelected}
    }
    let spacing:CGFloat = 10
    var onTrashing:Bool = false{
        didSet{
            allCells.forEach{$0.onTrashing = onTrashing;if onTrashing{$0.deleteSelected = false}}
                
            leftButton.image = UIImage(systemName: onTrashing ?"checkmark":(!albumView.faceStyle ? "square.grid.3x2":"square.grid.2x2"))
            
            rightButton.image = UIImage(systemName: onTrashing ?"trash.fill" : "square.and.pencil")
        }
    }
    
    
    
    //MARK: 删除cell
    func deleteAlbumCells(){
        let alertController = UIAlertController(title: "Sure?", message: "The Selected Albums Will be Delete", preferredStyle: .alert)
        let delete = UIAlertAction(title: "YES", style: .destructive, handler: { [self]action in
            if let warning = albumView.removeCell(at: allCellsSelected){
                warning(self)//闭包传值
            }
        })
        let cancel = UIAlertAction(title:"NO", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        alertController.addAction(delete)
        self.present(alertController, animated:true, completion:nil)
    }
    
    
    lazy var addButton: UIButton = {
        let i = UIButton()
        i.translatesAutoresizingMaskIntoConstraints = false
        i.setBackgroundImage(UIImage(systemName: "folder.fill.badge.plus"), for: .normal)
        i.setShadow()
        view.addSubview(i)
        NSLayoutConstraint.activate([
            i.widthAnchor.constraint(equalToConstant: view.frame.maxX*0.2),
            i.heightAnchor.constraint(equalTo: i.widthAnchor,multiplier: 0.8),
            i.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -spacing*3),
            i.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -spacing*4),
        ])
        return i
    }()
    
    @objc func importPhotosAction() {
        showBottomAlert()
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        albumView.setUpAdd{ [self]indexPath,havePhoto in
            if !onTrashing {
                albumView.addCell(at: indexPath, havePhoto: havePhoto)
            }
        }
        setup()
        onTrashing = false
    }
    
    func setup(){
        
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.title = "这货不是相册"
        
        albumView.albumViewDelegate = self
        view.addSubview(albumView)
        view.sendSubviewToBack(albumView)
        albumView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            albumView.topAnchor.constraint(equalTo: view.topAnchor, constant: (navigationController?.navigationBar.frame.height)!*2+spacing),
            albumView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: spacing),
            albumView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -spacing),
            albumView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -spacing),
        ])
        
        
        
        addButton.addTarget(self, action: #selector(importPhotosAction), for: .touchUpInside)
        
    }
    
    
    func showBottomAlert(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title:"Cancel", style: .destructive, handler: nil)
        let takingPictures = UIAlertAction(title:"The camera", style: .default){ action in
            self.goCamera()
            
        }
        let localPhoto = UIAlertAction(title:"Photo album", style: .default){ action in
            self.goImage()
            
        }
        alertController.addAction(takingPictures)
        alertController.addAction(localPhoto)
        alertController.addAction(cancel)
        
        
        self.present(alertController, animated:true, completion:nil)
    }
        
        
    func goCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let  cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = .camera
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    func goImage(){
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.allowsEditing = true
        photoPicker.sourceType = .photoLibrary
        self.present(photoPicker, animated: true, completion: nil)
        
    }

}

extension ViewController:UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        tempPhoto = (info[UIImagePickerController.InfoKey.editedImage] as! UIImage)
        //显示设置的照片
        self.dismiss(animated: true){
            self.choseAlbum()
        }
    }
    
    func choseAlbum(){
        let alertController = UIAlertController(title: "Choose Album", message: nil, preferredStyle: .actionSheet)
        for cell in allCells.sorted(by: {$0.title.text! < $1.title.text!}){
            let subAlert = UIAlertAction(title:cell.title.text, style: .default){ [unowned self] action in
                cell.photoDataSource.addData(dataSources: [tempPhoto])
                cell.didChangeData()
            }
            alertController.addAction(subAlert)
        }
        let newAlbum = UIAlertAction(title:"A New Album", style: .default) {[unowned self] action in
            albumView.addCell(at: IndexPath(item: allCells.count, section: 0), havePhoto: true)//添加一个相册到最后一格
        }
        let cancel = UIAlertAction(title:"Cancel", style: .destructive, handler: nil)
        alertController.addAction(newAlbum)
        alertController.addAction(cancel)
        
        self.present(alertController, animated:true)
    }
    
}



extension ViewController:AlbumViewDelegate{
    func newAlbum(_ albumView: AlbumView, havePhoto: Bool) -> Photo? {
        havePhoto ? tempPhoto : nil
    }
    
    
    func onClick(_ albumView: AlbumView,dataSource:PhotoDataSource,at albumIndexPath:IndexPath){
        if onTrashing{
            (albumView.cellForItemAt(indexPath: albumIndexPath)!).deleteSelected.toggle()
        }else{
            let photoViewController = PhotoViewController(dataSource: dataSource, favoriteAlubm:  allCells.filter({$0.title.text == "Favorite"})[0]){
                albumView.cellForItemAt(indexPath: albumIndexPath)?.didChangeData()
            }
            navigationController?.pushViewController(photoViewController, animated: true)
            
        }
    }
}
