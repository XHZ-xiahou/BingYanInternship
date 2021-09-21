//
//  albumView.swift
//  这货不是相册
//
//  Created by ChengAng on 2021/3/19.
//

import UIKit



protocol AlbumViewDelegate {
    func onClick(_ albumView:AlbumView,dataSource:PhotoDataSource,at albumIndexPath:IndexPath)
    func newAlbum(_ albumView:AlbumView,havePhoto:Bool)->Photo?
}



class AlbumView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        AlubmsDataSources.shared.photoDataSources.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumViewCell", for:indexPath)as? AlbumViewCell{
            if indexPath.item==AlubmsDataSources.shared.photoDataSources.count{//添加相册的cell
                cell.imgView.image = Photo(systemName: "plus")
                cell.imgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                cell.layer.borderWidth = 1
                return cell
            }
            cell.setDataSource(for: AlubmsDataSources.shared.photoDataSources[indexPath.item])
            cell.didChangeData()
            if cell.photoDataSource.title == "Favorite"{
                cell.tag = 99//99说明为最喜欢相册
                cell.title.isUserInteractionEnabled = false
            }
            
            return cell
        }
        return AlbumViewCell()
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AlbumViewCell
        cell.click()
        if indexPath.item != AlubmsDataSources.shared.photoDataSources.count{
            albumViewDelegate?.onClick(self, dataSource: cell.photoDataSource,at: indexPath)
        }else{
            add!(indexPath, false)
        }
    }
    
    //MARK: 布局相关
    
    private var qtyPerLine:CGFloat{ faceStyle ? 3 : 2 }
    var faceStyle:Bool = true{//true equal to 3*2
        didSet{
            update()
        }
    }
    private var cellSize:CGSize{
        CGSize(width: (frame.size.width-allHorizontalSpacing)/qtyPerLine, height: (frame.size.width-allHorizontalSpacing)/qtyPerLine)
    }
    
    var allHorizontalSpacing: CGFloat { CGFloat(qtyPerLine) * spacing }
    private let spacing: CGFloat = 20
    
    lazy  var collectionView = UICollectionView(frame: .zero,collectionViewLayout: layout)
    lazy var layout = UICollectionViewFlowLayout()
    
    //MARK:数据处理
    var add:((IndexPath,Bool)->Void)?

    
    var albumViewDelegate:AlbumViewDelegate?
    
    func setUpAdd(add:@escaping ((IndexPath,Bool)->Void)){
        self.add = add
    }
    
    
    init() {
        super.init(frame: .zero)
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.clipsToBounds = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: spacing),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing/2),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing/2),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -spacing),
        ])
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        collectionView.register(AlbumViewCell.self, forCellWithReuseIdentifier: "AlbumViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }
    
    func update(){
        
        layout.itemSize = cellSize
        layout.prepare()
        layout.invalidateLayout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: 自定义collectionCell方法
    func indexForCells(cells:[AlbumViewCell])->[IndexPath]{
        cells.compactMap{collectionView.indexPath(for: $0)}
    }
    
    func cellForItemAt(indexPath:IndexPath)->AlbumViewCell?{
        (collectionView.cellForItem(at: indexPath)as! AlbumViewCell)
    }
    
    
    func addCell(at indexPath:IndexPath,havePhoto:Bool){
        let photo = albumViewDelegate?.newAlbum(self, havePhoto: havePhoto)
        AlubmsDataSources.shared.addNewAlbum(with: [photo])
        collectionView.insertItems(at: [indexPath])
        if havePhoto{cellForItemAt(indexPath: indexPath)?.didChangeData()}
    }
    
    func removeCell(at cells:[AlbumViewCell])->((UIViewController)->Void)?{
        if cells.filter({$0.tag == 99}).count != 0{
            return {controller ->Void in//favorite无法删除
                let alertController = UIAlertController(title: "WARNING", message: "Favorite can not be Delete", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel)
                alertController.addAction(ok)
                controller.present(alertController, animated: true)
            }
        }
        
        
        let paths = indexForCells(cells: cells)
        //在数据中删除
        AlubmsDataSources.shared.deleteAlbums(at: paths)
        //删除cell
        collectionView.deleteItems(at: paths)
        //在本地文件夹中删除
        PhotoSourceManager.shared.deleteAlbums(at: cells.compactMap{
            $0.photoDataSource
        })
        
        
        return nil
    }
}




extension AlbumView:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { cellSize }
}



//MARK: Cell
class AlbumViewCell: UICollectionViewCell,UITextFieldDelegate {
    
    
    override func prepareForReuse() {
        photoDataSource = nil
        tag = 0
    }
    
    lazy var imgView = UIImageView()
    lazy var title = UITextField()
    lazy var selectView = UIImageView()
    var photoDataSource:PhotoDataSource!
    var deleteSelected:Bool = false{
        didSet{
            if onTrashing{
                selectView.image = UIImage(systemName: deleteSelected ? "checkmark.square":"square")
            }
        }
    }
    var onTrashing:Bool = false{
        didSet{
            selectView.isHidden = !onTrashing
            selectView.isUserInteractionEnabled = onTrashing
        }
    }
    
    deinit {
    }
    
    var countView: UIView!
    private var countLabel: UILabel!
    private let spacing: CGFloat = 20
    var qty: Int = 0 {
        didSet {
            self.countLabel.text = "\(qty)"
            UIView.animate(withDuration: 1.0) {
                self.countView.transform = self.qty>0 ? .identity : CGAffineTransform(scaleX: 0, y: 0)
            }
        }
    }
    
    func didChangeData(){
        qty = photoDataSource.dataSource.count
        
        if photoDataSource.dataSource.count != 0{
            imgView.image = photoDataSource.dataSource[0]
        }else{
            imgView.image = UIImage(systemName: "photo")
        }
    }
    
    func setDataSource(for dataSource:PhotoDataSource){
        photoDataSource = dataSource
        
        setup()
    }
    
    
    override init(frame:CGRect){
        super.init(frame: frame)
        layer.cornerRadius = 20
        layer.masksToBounds = false
        layer.shadowOpacity = 0.75
        layer.shadowRadius = 4.0
        backgroundColor = UIColor.black.withAlphaComponent(0.1)
        addSubview(imgView)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: topAnchor,constant: spacing),
            imgView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -spacing),
            imgView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -spacing),
            imgView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: spacing)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if countView == nil{
            imgView.center = CGPoint(x: bounds.width/2, y: bounds.width/2)
            return
        }
        countView.layer.cornerRadius = countView.frame.width / 2
        
    }
    
    func setup(){
        
        imgView.contentMode = .scaleAspectFit
        imgView.layer.cornerRadius = 20
        imgView.layer.masksToBounds = true
        
        
        
        countView = UIView()
        countView.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        addSubview(countView)
        countView.translatesAutoresizingMaskIntoConstraints = false
        
        countLabel = UILabel()
        countLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        countLabel.textAlignment = .center
        countLabel.font = .systemFont(ofSize: 18, weight: .medium)
        countLabel.textColor = .white
        countLabel.sizeToFit()
        countView.addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            countView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            countView.heightAnchor.constraint(equalTo: countView.widthAnchor),
            countView.centerXAnchor.constraint(equalTo: trailingAnchor),
            countView.topAnchor.constraint(equalTo: topAnchor, constant: -10),
        ])
        
        
        title.borderStyle = .none
        title.keyboardType = .asciiCapable
        title.text = photoDataSource.title
        title.adjustsFontSizeToFitWidth = true
        title.clearButtonMode = .whileEditing
        title.returnKeyType = .default
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        title.delegate = self
        addSubview(title)
        
        NSLayoutConstraint.activate([
            title.widthAnchor.constraint(equalTo: widthAnchor),
            title.heightAnchor.constraint(equalTo: title.widthAnchor, multiplier: 0.13),
            title.centerXAnchor.constraint(equalTo: centerXAnchor),
            title.topAnchor.constraint(equalTo: imgView.bottomAnchor,constant: spacing/2),
        ])
        
        
        addSubview(selectView)
        selectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            selectView.heightAnchor.constraint(equalTo: countView.widthAnchor),
            selectView.centerXAnchor.constraint(equalTo: leadingAnchor),
            selectView.topAnchor.constraint(equalTo: topAnchor, constant: -10),
        ])
    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        title.text = PhotoSourceManager.shared.name(newValue: textField.text ?? "Unnamed")
//        photoDataSource.title = title.text
//        textField.resignFirstResponder()
//    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        title.text = PhotoSourceManager.shared.name(newValue: textField.text ?? "Unnamed")
        photoDataSource.title = title.text
        textField.resignFirstResponder()
        return true
    }
    
}

