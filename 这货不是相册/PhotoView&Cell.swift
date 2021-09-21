
import UIKit
//MARK: PhotoViewDelegate
protocol PhotoViewDelegate {
    func onClick(_ photoView:PhotoView,at indexPath:IndexPath)
}


typealias Photos = [UIImage]
typealias Photo = UIImage


class PhotoView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photoDataSource?.dataSource.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoViewCell", for:indexPath)as? PhotoViewCell{
            
            cell.imgView.image = photoDataSource?.dataSource[indexPath.item]
            
            return cell
        }
        return PhotoViewCell()
    }
    //MARK: 点击cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !onDetail{
            delegate?.onClick(self,at: indexPath)
            cellIndex = indexPath.item + 1
        }
    
    }
    

    //MARK: 布局相关
    private var cellIndex:Int = 0 //当前cell的坐标，on detail condition
    
    var currentCell:PhotoViewCell{
        collectionView.cellForItem(at: IndexPath(item: cellIndex-1, section: 0)) as! PhotoViewCell
    }
    var landScapeOrPortrait:UICollectionView.ScrollDirection{//true equal to landeScape
        onDetail ? .horizontal : .vertical
    }
    private var qtyPerLine:CGFloat{ onDetail ? 1 : 3  }
    
    
    var cellSize:CGSize{
        !onDetail ? CGSize(width: (frame.size.width-allHorizontalSpacing)/qtyPerLine, height: (frame.size.width-allHorizontalSpacing)/qtyPerLine):CGSize(width: frame.width, height: frame.height)
    }
    
    var allHorizontalSpacing: CGFloat { CGFloat(qtyPerLine) * spacing }

    var edge:UIEdgeInsets{
        let i = onDetail ? 0 : spacing
        return UIEdgeInsets(top: i, left: i/2, bottom: i, right: i/2)
    }
    
    
    private let spacing: CGFloat = 20
    
    //MARK:控件相关
    var onDetail:Bool = false{
        didSet{
            
            if !onDetail{cellIndex = 0}//返回多照片界面index致零
            
            layout.scrollDirection = landScapeOrPortrait //多照片界面为垂直滑动，详细界面为水平
            
            backgroundColor = onDetail ?.black:.clear //背景变白或者黑
            
//            collectionView.isPagingEnabled = onDetail
            
            layout.minimumLineSpacing = onDetail ? 0:spacing //详细界面无间隔

            
            DispatchQueue.main.async { [self] in
                addOrRemovePinchGesture()//添加或移除放大手势
            }
            
        }
    }
    var onFilter:Bool = false{//只会在详细界面界面中启用
        didSet{
            
        }
    }
    var onCutting:Bool = false{//只会在详细界面界面中启用
        didSet{
            if onCutting && oldValue==false{
                
                transform = .identity
                addOrRemovePinchGesture()

                

                preIMGSize = currentCell.imgView.image?.size

                onEditeIMG = UIImageView()
                
                let proportion = preIMGSize.height/preIMGSize.width
                onEditeIMG.frame.size = CGSize(width:(superview?.frame.width)!, height: (superview?.frame.width)!*proportion)
                onEditeIMG.center = self.convertedCenter(to: collectionView)
                onEditeIMG.fullBorder(width: 3, borderColor: UIColor.white)
                collectionView.addSubview(onEditeIMG)
                collectionView.bringSubviewToFront(onEditeIMG)
                rotationGes = UIRotationGestureRecognizer(target: self, action: #selector(rotation))
                pinchGes = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
                currentCell.addGestureRecognizer(pinchGes)
                currentCell.addGestureRecognizer(rotationGes)
                
            }else if !onCutting{
                onEditeIMG.removeFromSuperview()
                DispatchQueue.main.async { [self] in
                    addOrRemovePinchGesture()
                }
                currentCell.transform = .identity
                currentCell.removeGestureRecognizer(pinchGes)
                currentCell.removeGestureRecognizer(rotationGes)
            }
        }
    }
    var onPainting:Bool = false{//只会在详细界面界面中启用
        didSet{
            
        }
    }
    
    //MARK:————————————————————
    
    
    
    private var allCells:[PhotoViewCell]{
        collectionView.visibleCells.compactMap{$0 as? PhotoViewCell}
    }
    var preRotation:CGFloat!
    var preIMGSize:CGSize!
    private var preScale:CGFloat!
    lazy var collectionView = UICollectionView(frame: .zero,collectionViewLayout: layout)
    lazy var layout = UICollectionViewFlowLayout()
    var photoDataSource:PhotoDataSource?
    var pinchGes:UIPinchGestureRecognizer!
    var rotationGes:UIRotationGestureRecognizer!
    var delegate:PhotoViewDelegate?//设置代理
    var onEditeIMG:UIImageView!
    
    init(frame:CGRect,dataSource:PhotoDataSource) {
        super.init(frame: frame)
        self.photoDataSource = dataSource
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.clipsToBounds = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        collectionView.register(PhotoViewCell.self, forCellWithReuseIdentifier: "PhotoViewCell")
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
    
    
    
    //MARK:裁剪和旋转，滤镜等
    func photoCutter(){
        if onDetail && onCutting{
            
        }
        if !onCutting{
            
        }
    }
    func addOrRemovePinchGesture(){
        
        preScale = nil
        preRotation = nil
        if onFilter || onCutting || onPainting{
            self.removeGestureRecognizer(pinchGes)
        }else if onDetail{
            
            pinchGes = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
            self.addGestureRecognizer(pinchGes)
        }
    }
    @objc func pinch(_ sender:UIPinchGestureRecognizer){
        
        
        
        if onCutting{
            currentCell.imgView.transform = currentCell.imgView.transform.scaledBy(x: sender.scale, y: sender.scale)
        }else{
            self.transform = self.transform.scaledBy(x: sender.scale, y: sender.scale)

        }
        sender.scale = 1 //复原
        
        
    
    }
    @objc func rotation(_ sender:UIRotationGestureRecognizer){
        
        
        currentCell.imgView.transform = currentCell.imgView.transform.rotated(by: sender.rotation)
        
        sender.rotation = 0
        
    }
    
    
    
    
    
    //MARK: 自定义collectionCell方法
    func reload() {
        allCells.forEach{$0.onTrashing = false}
        collectionView.reloadData()
        
    }
    func indexesForCells(cells:[PhotoViewCell])->[IndexPath]{
        cells.compactMap{collectionView.indexPath(for: $0)}
    }
    
    func cellsForItemAt(indexPaths:[IndexPath])->[PhotoViewCell?]{
        indexPaths.compactMap{
            collectionView.cellForItem(at: $0) as? PhotoViewCell
        }
    }
    func removeCells(at indexPaths:[IndexPath]){
        var datas:Photos = []
        indexPaths.forEach{datas.append(photoDataSource![$0.item])}
        
        photoDataSource?.deleteData(dataSources: datas)
        
        collectionView.deleteItems(at: indexPaths)
        
    }
    func addCell(photos:Photos){
        self.photoDataSource?.addData(dataSources: photos)
        photos.forEach{_ in collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])}
    }
    
    
}
extension PhotoView:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { cellSize }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { edge }
}
extension PhotoView:UIScrollViewDelegate{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if onDetail{
            self.transform = .identity//移动视图变回原型
            preScale = nil
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        DispatchQueue.main.async{[self] in
            if onDetail{
                let x = scrollView.panGestureRecognizer.translation(in: scrollView).x
                //拖动时手势禁止
                scrollView.panGestureRecognizer.isEnabled = false
                
                //滑动距离判断
                cellIndex += (x>0 && cellIndex>1) ? -1 :(x<0 && cellIndex<(photoDataSource?.dataSource.count)! ? 1 :0)
                
                //滑动
                UIView.animate(withDuration:  0.2, animations: {[self] in
                    collectionView.scrollToItem(at: IndexPath(item: cellIndex-1, section: 0), at: .centeredHorizontally, animated: false)
                }){[self]_ in
                    collectionView.panGestureRecognizer.isEnabled = true
                }
            }
        }
        
    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        DispatchQueue.main.async {
//            Self.currentCell = self.curCell
//        }
//    }
}
extension PhotoView:UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {//设置多手势
        true
    }
}


//MARK: cell
class PhotoViewCell: UICollectionViewCell{
    lazy var imgView = UIImageView()
    lazy var selectView = UIImageView()
    
    override func prepareForReuse() {
        imgView.image = nil
    }
    var beSelected:Bool = false{
        didSet{
            if onTrashing{
                selectView.image = UIImage(systemName: beSelected ? "checkmark.square":"square")
            }
        }
    }
    var onTrashing:Bool = false{
        didSet{
            selectView.isHidden = !onTrashing
            selectView.isUserInteractionEnabled = onTrashing
        }
    }
    
    
    override init(frame:CGRect){
        super.init(frame: frame)
        setup()
        self.setShadow()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        addSubview(imgView)
        
        imgView.contentMode = .scaleAspectFit
        
        imgView.layer.masksToBounds = true
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: topAnchor),
            imgView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imgView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        
        
        addSubview(selectView)
        selectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            selectView.heightAnchor.constraint(equalTo: selectView.widthAnchor),
            selectView.centerXAnchor.constraint(equalTo: leadingAnchor),
            selectView.topAnchor.constraint(equalTo: topAnchor, constant: -10),
        ])
    }
    
}
