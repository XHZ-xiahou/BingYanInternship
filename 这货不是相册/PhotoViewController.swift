//
//  PhotoViewController.swift
//  这货不是相册
//
//  Created by ChengAng on 2021/3/20.
//

import UIKit
class PhotoViewController: UIViewController {


    @IBAction func Localize(_ sender: Any) {
        if photoView.onDetail{
            let activityViewController = UIActivityViewController(activityItems: [(photoView.currentCell.imgView.image)!], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }else if onEdite && !photoView.onDetail{//在多照片视图编辑模式
            
            let activityViewController = UIActivityViewController(activityItems:
            
                allCellsSelected.compactMap{$0.imgView.image}
            
            , applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
            onEdite = false
        }
    }
    @IBAction func moveToFavorite(_ sender: Any) {
        if let favoriteAlubm = FavoriteAlubm{
            if onEdite && !photoView.onDetail{//在多照片视图编辑模式
                
                favoriteAlubm.photoDataSource.addData(dataSources: allCellsSelected.compactMap{$0.imgView.image})
                favoriteAlubm.didChangeData()
                
                
            }else if photoView.onDetail{//单照片
                
                favoriteAlubm.photoDataSource.addData(dataSources: [photoView.currentCell.imgView.image!])
                favoriteAlubm.didChangeData()
                
            }
            photoView.reload()
            onEdite = false
            
            self.saveSuccessful()
        }
    }
    
    @IBAction func photoCuter(_ sender: Any) {
        if photoView.onDetail{
            photoView.onCutting = true
            
            onEdite = true
            
        }
    }
    
    @IBAction func photoFilter(_ sender: Any) {
        if photoView.onDetail{
            photoView.onFilter = true
            onEdite = true
            filterBankView = FilterBankView(frame: .zero, photo: photoView.currentCell.imgView.image!, curCell: photoView.currentCell)
            
            view.addSubview(filterBankView)
            
            filterBankView.addSelftoView()
            
            filterBankView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                filterBankView.heightAnchor.constraint(equalToConstant: view.frame.height*0.13),
                filterBankView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                filterBankView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                filterBankView.bottomAnchor.constraint(equalTo: toolBar.topAnchor),
            ])
            
        }
    }
    
    @IBAction func painting(_ sender: Any) {
        if photoView.onDetail{
            photoView.onPainting = true
            onEdite = true
            
            
        }
        
    }
    @IBAction func SlideShow(_ sender: Any) {
        guard dataSource.dataSource.count != 0 else {
            return 
        }
        slideShow = Slide_Show(frame:view.frame,PH:dataSource.dataSource)
        view.addSubview(slideShow)
        view.bringSubviewToFront(slideShow)
    }
    
    @objc func left(_ sender: Any) {
        if photoView.onDetail{
            
            if !onEdite{//从单照片返回到多照片
                photoView.transform = .identity
                let cell = photoView.currentCell
                self.photoView.onDetail = false
                let imgView = cell.imgView.copy() as! UIImageView
                view.addSubview(imgView)
                imgView.frame = cell.convertedFrame(to: view)
                photoView.alpha = 0
                UIView.animate(withDuration: 0.43, animations: {
                    self.view.backgroundColor = .white
                    imgView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    imgView.alpha = 0
                    self.photoView.alpha = 1
                }){ _ in
                    
                    imgView.removeFromSuperview()
                }
                
            }else{
                if photoView.onCutting{
                    photoView.currentCell.imgView.transform = .identity
                    photoView.onCutting = false

                }else if photoView.onFilter {
                    
                    
                    filterBankView.removeFromSuperview()
                    filterBankView = nil
                    photoView.onFilter = false

                }else if photoView.onPainting{
                        
                    photoView.onPainting = false

                }
                onEdite = false
            }
        }else if onEdite{
            onEdite = false
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func right(_ sender: Any) {
        if !photoView.onDetail{
            if onEdite && allCellsSelected.count>0{ delete_photo() }

            onEdite.toggle()
        }else if onEdite{//在编辑模式下，点击右侧勾勾，说明完成编辑，保存图片
            if photoView.onCutting{
                photoView.currentCell.imgView.transform = .identity
                photoView.onCutting = false

            }else if photoView.onFilter {
                
                let i = filterBankView.haveChoosenFilter
                filterBankView.removeFromSuperview()
                filterBankView = nil
                photoView.onFilter = false
                
                if i {
                    photoView.photoDataSource?.addData(dataSources: [photoView.currentCell.imgView.image!])
                    cellDidChangeData!()
                    photoView.reload()
                }
                
            }else if photoView.onPainting{
                    
                photoView.onPainting = false

            }
//            UIGraphicsBeginImageContextWithOptions(photoView.onEditeIMG.frame.size, false, 0)
//            photoView.onEditeIMG.drawHierarchy(in: photoView.onEditeIMG.bounds, afterScreenUpdates: false)
//
//            if let newphoto:Photo = UIGraphicsGetImageFromCurrentImageContext(){
//                photoView.addCell(photos: [newphoto])
//            }
//            UIGraphicsEndImageContext()
            
            
//            var PH:Photo!
//            DispatchQueue.main.async { [self] in
//                PH = PhotoView.currentCell.imgView.asImage().cropToSize(rect: photoView.onEditeIMG.frame)
//
//            }
            
//            photoView.addCell(photos: [photoView.currentCell.imgView.image!.cropToSize(rect: photoView.collectionView.convert(photoView.onEditeIMG.frame, to: view))])
//            photoView.onEditeIMG.removeFromSuperview()
            
            
            if let v = photoView.onEditeIMG{
                v.removeFromSuperview()
            }
            onEdite = false
        }
    }
    
    
    lazy var rightButton = UIBarButtonItem(image: nil, style: .plain, target: self, action:  #selector(right))
    lazy var leftButton = UIBarButtonItem(image: nil, style: .plain, target: self, action:  #selector(left))
    
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    var filterBankView:FilterBankView!
    var FavoriteAlubm:AlbumViewCell?
    var slideShow:Slide_Show!
    var cellDidChangeData:(()->Void)?
    var dataSource:PhotoDataSource!
    init(dataSource:PhotoDataSource,favoriteAlubm:AlbumViewCell,cellDidChangeData:@escaping ()->Void) {
        self.FavoriteAlubm = favoriteAlubm
        self.dataSource = dataSource
        self.cellDidChangeData = cellDidChangeData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var photoView = PhotoView(frame:.zero, dataSource: dataSource)
    private let spacing:CGFloat = 10
    
    
    private var allCells:[PhotoViewCell]{
        photoView.collectionView.visibleCells.compactMap{$0 as? PhotoViewCell}
    }
    private var allCellsSelected:[PhotoViewCell]{
        allCells.filter{$0.beSelected}
    }
    
    var onEdite:Bool = false{
        didSet{
            if !photoView.onDetail{//多视图下
                allCells.forEach{
                    $0.onTrashing = onEdite
                    
                    if onEdite{$0.beSelected = false}//多照片视图下退出编辑模式时重制cell选中
                    
                }
            }else if onEdite{//如果在单照片且在编辑
                toolBar.isUserInteractionEnabled = false//无法使用其他tools
                
                if photoView.onDetail{//如果单照片视图下且在编辑，无法滚动
                    photoView.collectionView.isScrollEnabled = false
                }
            }else{
                toolBar.isUserInteractionEnabled = true//可使用其他tools
                photoView.collectionView.isScrollEnabled = true
            }
            
            
            
            leftButton.image = UIImage(systemName: onEdite && !photoView.onDetail ?"checkmark":"chevron.backward")
            rightButton.image = UIImage(systemName: onEdite ? (photoView.onDetail ? "checkmark":"trash.fill") : "square.and.pencil")

        }
        
    }
    
    //MARK: 删除cell
    func delete_photo(){
        let alertController = UIAlertController(title: "Sure?", message: "The Selected Photos Will be Delete", preferredStyle: .alert)
        let delete = UIAlertAction(title: "YES", style: .destructive, handler: { [self]action in
            photoView.removeCells(at: photoView.indexesForCells(cells: allCellsSelected))
            cellDidChangeData!()
        })
        let cancel = UIAlertAction(title:"NO", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        alertController.addAction(delete)
        self.present(alertController, animated:true, completion:nil)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoView.delegate = self
        
        navigationItem.title = dataSource.title//大标题
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem = leftButton
        
        
        onEdite = false//非编辑状态下
        
        view.addSubview(photoView)
        view.sendSubviewToBack(photoView)
        photoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: view.topAnchor,constant:(navigationController?.navigationBar.frame.height)!*2+spacing),
            photoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photoView.bottomAnchor.constraint(equalTo: toolBar.topAnchor),
        ])
    }



}

extension PhotoViewController:PhotoViewDelegate{

    func onClick(_ photoView: PhotoView, at indexPath: IndexPath) {
        if onEdite{
            (photoView.cellsForItemAt(indexPaths: [indexPath]))[0]!.beSelected.toggle()
        }else if !photoView.onDetail {
            let cell = photoView.collectionView.cellForItem(at: indexPath) as! PhotoViewCell
            let imgView = cell.imgView.copy() as! UIImageView
            view.addSubview(imgView)
            imgView.frame = cell.convertedFrame(to: view)
            photoView.alpha = 0
            UIView.animate(withDuration: 0.4, animations: {[self] in
                imgView.frame = photoView.convertedFrame(to: view)
                view.backgroundColor = .black
            }){_ in
                imgView.removeFromSuperview()
                photoView.alpha = 1
                
                photoView.onDetail = true
                photoView.collectionView.contentOffset = CGPoint(x: indexPath.item*Int(photoView.cellSize.width), y: 0)
                
            }
            
        }else{
            
        }

    }
    
    
}



