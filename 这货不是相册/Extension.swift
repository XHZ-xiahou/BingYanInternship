//
//  Extension.swift
//  这货不是相册
//
//  Created by ChengAng on 2021/3/21.
//

import UIKit

extension UIImageView{
    open override func copy() -> Any {
        let i = UIImageView(image: self.image)
        i.layer.cornerRadius = self.layer.cornerRadius
        i.layer.masksToBounds = self.layer.masksToBounds
        i.contentMode = self.contentMode
        return i
    }
}
extension UIView{
    func setCornerRadius() {
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
    }
    func setShadow(){
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 3.0
    }
    func click(){
        UIView.animate(withDuration: 0.12) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12){
        UIView.animate(withDuration: 0.12) {
            self.transform = .identity
            }
        }
    }
}
extension Int{
    func random() -> Self {
        Int(arc4random_uniform(UInt32(self)))
    }
}
extension UIView {
    func contains(_ view: UIView) -> Bool {
        return self.frame.contains(view.convertedFrame(to: self.superview!))
    }

    func containsCenter(of view: UIView) -> Bool {
        self.frame.contains(view.convertedCenter(to: self.superview!))
    }

    func convertedCenter(to view: UIView) -> CGPoint {
        superview!.convert(self.center, to: view)
    }

    func convertedFrame(to view: UIView) -> CGRect {
        superview!.convert(self.frame, to: view)
    }
}






//MARK:Slide Show

public class Slide_Show: UIView {
    private var photos:Photos = []
    private var imageViews:[UIImageViewExtension] = []
    var speed:Double = 0.5
    init(frame:CGRect,PH:Photos,spead:Double = 0.5) {
        super.init(frame: frame)
        self.photos = PH
        self.speed = spead
        backgroundColor = .black
        initialImagesViews()
        stopGes()
        guard self.speed > 0.3 else {
            self.speed = 0.4
            return
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
    func stopGes(){
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stop)))
        isUserInteractionEnabled = true
    }
    
    @objc func stop(){
        self.removeFromSuperview()
    }
    func initialImagesViews(){
        guard photos.count > 0 else {
            return
        }
        for photo in photos {
            let imgView = UIImageViewExtension()
            addSubview(imgView)
            
            imgView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                imgView.centerYAnchor.constraint(equalTo: centerYAnchor),
                imgView.centerXAnchor.constraint(equalTo: centerXAnchor),
                imgView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.1),
                imgView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.1),
            ])
            imgView.image = photo
            imgView.contentMode = .scaleAspectFit
            imgView.layer.opacity = 0
            imageViews.append(imgView)
        }
        let num = imageViews.count
        let sepNum = num*4
        var count = 0
        Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [self] (timer) in
            if count%4 == 0{
                let index = count%sepNum/4
                self.imageViews[num-index-1].addMoreScaleAnimationGroupAnimation(time: self.speed)
            }else if count%4 == 1 && count != 1{
                //0-1-2-3-4
                let index = (count-1)%sepNum/4
                let sIndex = num-index-1 == num-1 ? 0 : num-index
                self.imageViews[sIndex].layer.removeAllAnimations()
                self.sendSubviewToBack(self.imageViews[sIndex])
                imageViews[sIndex].layer.opacity = 0
            }
            count += 1
            
        }

    }
}

class UIImageViewExtension: UIImageView{
    func addMoreScaleAnimationGroupAnimation(time:CFTimeInterval? = 0.5) {
        self.layer.opacity = 1
        self.layer.removeAllAnimations()
        //透明度
        let opacity: CABasicAnimation = CABasicAnimation.init(keyPath: "opacity")
        opacity.fromValue = 1
        opacity.toValue = 0
        opacity.duration = time!
        opacity.beginTime = 4*time!
        //缩放
        let scale = CABasicAnimation.init(keyPath: "transform.scale")
        scale.duration = 5*time!
        scale.fromValue = 1.05
        scale.toValue = 0.95
        let group = CAAnimationGroup.init()
        group.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeIn)
        group.duration = 5*time!
        group.autoreverses = false
        group.animations = [scale,opacity]
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        group.repeatCount = 1
        self.layer.add(group, forKey: nil)
       }

}

extension UIViewController{
    func saveSuccessful(){
        let alertController = UIAlertController(title: "Success!",
                                                message: nil, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.7) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
}


extension UIView {
    
    //画线
    private func drawBorder(rect:CGRect,color:UIColor){
        let line = UIBezierPath(rect: rect)
        let lineShape = CAShapeLayer()
        lineShape.path = line.cgPath
        lineShape.fillColor = color.cgColor
        self.layer.addSublayer(lineShape)
    }
    
    //设置全边框
    func fullBorder(width:CGFloat,borderColor:UIColor){
        rightBorder(width: width, borderColor: borderColor)
        leftBorder(width: width, borderColor: borderColor)
        topBorder(width: width, borderColor: borderColor)
        buttomBorder(width: width, borderColor: borderColor)
    }
    
    //设置右边框
    func rightBorder(width:CGFloat,borderColor:UIColor){
        let rect = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        drawBorder(rect: rect, color: borderColor)
    }
    //设置左边框
    func leftBorder(width:CGFloat,borderColor:UIColor){
        let rect = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        drawBorder(rect: rect, color: borderColor)
    }
    
    //设置上边框
    func topBorder(width:CGFloat,borderColor:UIColor){
        let rect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        drawBorder(rect: rect, color: borderColor)
    }
    
    
    //设置底边框
    func buttomBorder(width:CGFloat,borderColor:UIColor){
        let rect = CGRect(x: 0, y: self.frame.size.height-width, width: self.frame.size.width, height: width)
        drawBorder(rect: rect, color: borderColor)
    }
}


extension UIImage{
    func cropToSize(rect: CGRect) -> UIImage {
            var newRect = rect
            newRect.origin.x *= self.scale
            newRect.origin.y *= self.scale
            newRect.size.width *= self.scale
            newRect.size.height *= self.scale
            let cgimage = self.cgImage?.cropping(to: newRect)
            let resultImage = UIImage(cgImage: cgimage!, scale: self.scale, orientation: self.imageOrientation)
            return resultImage
        }
}


extension UIView {
   func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: frame.size)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}

extension UIImage {
    func crop(ratio: CGFloat) -> UIImage {
        var newSize:CGSize!
        if size.width/size.height > ratio {
            newSize = CGSize(width: size.height * ratio, height: size.height)
        }else{
            newSize = CGSize(width: size.width, height: size.width / ratio)
        }
     
        var rect = CGRect.zero
        rect.size.width  = size.width
        rect.size.height = size.height
        rect.origin.x    = (newSize.width - size.width ) / 2.0
        rect.origin.y    = (newSize.height - size.height ) / 2.0
         
        
        UIGraphicsBeginImageContext(newSize)
        draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
         
        return scaledImage!
    }
}
