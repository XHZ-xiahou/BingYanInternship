
import UIKit

class FilterBankView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterBankViewCell", for:indexPath) as? FilterBankViewCell{
            cell.setupCell(type: dataSources[indexPath.item])
            
            return cell
        }
        return FilterBankViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        currentCell.imgView.image = dataSources[indexPath.item].photo//把当前cell的imgview置换成filtedPhoto
        haveChoosenFilter = true
    }//点击cell选择滤镜
    
    var haveChoosenFilter:Bool = false
    var cellSize:CGSize{
        CGSize(width: frame.height-spacing, height: frame.height-spacing)
    }
    var allHorizontalSpacing: CGFloat { CGFloat(dataSources.count) * spacing }
    lazy var collectionView = UICollectionView(frame: .zero,collectionViewLayout: layout)
    lazy var layout = UICollectionViewFlowLayout()
    var dataSources:[FilterDataSource]!
    var currentCell:PhotoViewCell!
    init(frame:CGRect,photo:Photo,curCell:PhotoViewCell) {
        super.init(frame: frame)

        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        self.currentCell = curCell
        dataSources = Filter.shared.filting(photo: photo)
        setup()
    }
    private let spacing: CGFloat = 20
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSelftoView(){
        alpha = 0.3
        transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        superview?.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: {[self] in
            alpha = 1
            transform = .identity
        }){[self] _ in
            superview!.isUserInteractionEnabled = true
        }
    }
    
    func setup(){
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(collectionView)
        bringSubviewToFront(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        
        collectionView.register(FilterBankViewCell.self, forCellWithReuseIdentifier: "FilterBankViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout.itemSize = cellSize
        layout.prepare()
        layout.invalidateLayout()
        
    }
    
}

class Filter :CIFilterProtocol{
    var outputImage: CIImage?
    
    static var shared = Filter()
    private init(){}
    
    func filting(photo:Photo) -> [FilterDataSource]? {
        var res:[FilterDataSource] = []
        for i in 0...10{
            res.append(FilterDataSource(photo: photo, name: "test\(i)"))
        }
        return res
    }
}





struct FilterDataSource {
    var photo:Photo
    var name:String
}
class FilterBankViewCell: UICollectionViewCell {
    lazy var imgView = UIImageView()
    lazy var title = UILabel()
    override init(frame:CGRect){
        super.init(frame: frame)
        layer.cornerRadius = 20
        layer.masksToBounds = false
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        
        addSubview(imgView)
        imgView.contentMode = .scaleAspectFit
        imgView.layer.cornerRadius = 20
        imgView.layer.masksToBounds = false
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: topAnchor),
            imgView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imgView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        
        addSubview(title)
        bringSubviewToFront(title)
        
        title.textColor = .red
        
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.widthAnchor.constraint(equalTo: widthAnchor),
            title.heightAnchor.constraint(equalTo: title.widthAnchor, multiplier: 0.13),
            title.centerXAnchor.constraint(equalTo: centerXAnchor),
            title.topAnchor.constraint(equalTo: imgView.bottomAnchor,constant: -7),
        ])
    }
    func setupCell(type:FilterDataSource){
        title.text = type.name
        imgView.image = type.photo
    }
    
}



