//
//  KCKAddPhotoView.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2021/11/6.
//

import UIKit
import SnapKit

// MARK: - KCKAddPhotoCollectionCell.

class KCKAddPhotoCollectionCell: UICollectionViewCell {
    
    // 默认设置 cell 的大小为 100，所有的约束以 100 为基准做比例缩放。
    private let defaultSize: CGFloat = CGFloat.kiriha_horizontalSize(num: 100)
    var aCellSize: CGFloat = CGFloat.kiriha_horizontalSize(num: 100) {
        didSet {
            self.setNeedsLayout()
        }
    }
    private var ratio: CGFloat {
        return self.aCellSize / self.defaultSize
    }
    
    private var addImageView: UIImageView!
    private var titleLabel: KCKUILabel!
    private var photoImageView: UIImageView!
    private var deleteButton: KCKUIButton!
    
    var index: Int!
    var addPhotoView: KCKAddPhotoView!
    
    var removePhotoCallBack: ((_ index: Int) -> Void)?
    
    weak var delegate: KCKAddPhotoViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = UIColor.defaultViewColor
        
        self.addImageView = UIImageView()
        self.addImageView.image = UIImage.kiriha_imageInKirihaBundle(name: "camera_add")
        self.addImageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.addImageView)
        
        self.titleLabel = KCKUILabel()
        self.titleLabel.text = "添加照片"
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = UIColor.kiriha_colorWithHexString("#858B9C")
        self.titleLabel.font = .systemFont(ofSize: CGFloat.kiriha_verticalSize(num: 12) * self.ratio)
        self.contentView.addSubview(self.titleLabel)
        
        self.photoImageView = UIImageView()
        self.photoImageView.isUserInteractionEnabled = true
        self.photoImageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.photoImageView)
        self.photoImageView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        self.photoImageView.isHidden = true
        
        self.deleteButton = KCKUIButton()
        self.deleteButton.setImage(UIImage.kiriha_imageInKirihaBundle(name: "camera_del"), for: .normal)
        self.deleteButton.addTarget(self, action: #selector(self.touchRemoveButton(sender:)), for: .touchUpInside)
        self.contentView.addSubview(self.deleteButton)
        
        self.contentView.layer.cornerRadius = 2
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.contentView.layer.shadowColor = UIColor(red: 197.0 / 255.0, green: 202.0 / 255.0, blue: 213.0 / 255.0, alpha: 0.25).cgColor
        self.contentView.layer.shadowOpacity = 1
        self.contentView.layer.shadowRadius = 10
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor(red: 235.0 / 255.0, green: 235.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0).cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.addImageView != nil {
            self.addImageView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(CGFloat.kiriha_verticalSize(num: 26) * self.ratio)
                make.left.equalToSuperview().offset(CGFloat.kiriha_verticalSize(num: 38) * self.ratio)
                make.right.equalToSuperview().offset(CGFloat.kiriha_verticalSize(num: -38) * self.ratio)
                make.bottom.equalToSuperview().offset(CGFloat.kiriha_verticalSize(num: -50) * self.ratio)
            }
        }
        if self.titleLabel != nil {
            self.titleLabel.font = .systemFont(ofSize: CGFloat.kiriha_verticalSize(num: 12) * self.ratio)
            self.titleLabel.snp.remakeConstraints { make in
                make.left.lessThanOrEqualToSuperview().offset(CGFloat.kiriha_verticalSize(num: 26) * self.ratio)
                make.centerX.equalToSuperview().priority(.high)
                make.right.greaterThanOrEqualToSuperview().offset(CGFloat.kiriha_verticalSize(num: -26) * self.ratio)
                make.top.equalTo(self.addImageView.snp.bottom).offset(CGFloat.kiriha_verticalSize(num: 12) * self.ratio)
                make.bottom.greaterThanOrEqualToSuperview().offset(CGFloat.kiriha_verticalSize(num: -22) * self.ratio)
            }
        }
        if self.photoImageView != nil {
            self.photoImageView.snp.remakeConstraints { make in
                make.left.right.top.bottom.equalToSuperview()
            }
        }
        if self.deleteButton != nil {
            self.deleteButton.snp.makeConstraints { make in
                make.right.equalToSuperview()
                make.top.equalToSuperview()
                make.width.height.equalTo(CGFloat.kiriha_verticalSize(num: 24))
            }
        }
    }
    
    func setImage(image: UIImage?) {
        if image == nil {
            self.photoImageView.image = nil
            self.photoImageView.isHidden = true
            self.deleteButton.isHidden = true
        } else {
            self.photoImageView.image = image
            self.photoImageView.isHidden = false
            self.deleteButton.isHidden = false
        }
    }
    
    @objc private func touchRemoveButton(sender: KCKUIButton) {
        if self.delegate == nil {
            self.setImage(image: nil)
            self.removePhotoCallBack?(self.index)
        } else {
            self.delegate?.addPhotoView?(addPhotoView: self.addPhotoView, didTouchRemoveButtonAt: self.index)
        }
    }
}

// MARK: - KCKAddPhotoViewDelegate.

@objc public protocol KCKAddPhotoViewDelegate {
    
    /**
     如果未实现此方法，则点击相框默认调出相机拍摄相片，拍摄的相片保存在内存中，可以通过 `getPhoto:from:` 方法获取拍摄的相片。
     并且在拍摄照片后会自动在 `maxPhotos` 范围内动态增加空相框。
     如果实现此方法，则默认为空方法，点击相框将无任何效果。可以通过 `addEmptyPhoto:` 方法手动增加空相框。
     */
    @objc optional func addPhotoView(addPhotoView: KCKAddPhotoView, didSelectItemAt index: Int)
    
    @objc optional func addPhotoView(addPhotoView: KCKAddPhotoView, didTouchRemoveButtonAt index: Int)
}

// MARK: - KCKAddPhotoView.

open class KCKAddPhotoView: KCKUIView {
    
    private var photoCollectionView: KCKUICollectionView!
    
    open var photos: [UIImage?] = [nil]
    
    open var maxPhotos: Int = 10
    
    /// 设置每个相框的边长。
    open var itemEdge: CGFloat = CGFloat.kiriha_verticalSize(num: 100) {
        didSet {
            (self.photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: self.itemEdge, height: self.itemEdge)
        }
    }
    
    private var currentSelectIndex: Int = 0
    
    open weak var delegate: KCKAddPhotoViewDelegate?
    
    /// 如果需要动态拓展视图高度，可以用此属性计算视图高度来对视图做约束。
    open var viewHeight: CGFloat {
        get {
            let count: Int = self.photos.count
            let row: Int = (count - 1) / 3 + 1
            return (self.itemEdge + CGFloat.kiriha_verticalSize(num: 10)) * CGFloat(row) + CGFloat.kiriha_verticalSize(num: 10)
        }
    }
    
    open var enableScroll: Bool = false {
        didSet {
            self.photoCollectionView.isScrollEnabled = self.enableScroll
        }
    }
    
    private func initialize() {
        self.backgroundColor = UIColor.defaultViewColor
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.itemEdge, height: self.itemEdge)
        layout.sectionInset.left = CGFloat.kiriha_horizontalSize(num: 10)
        layout.sectionInset.right = CGFloat.kiriha_horizontalSize(num: 10)
        layout.sectionInset.top = CGFloat.kiriha_verticalSize(num: 10)
        layout.sectionInset.bottom = CGFloat.kiriha_verticalSize(num: 10)
        layout.minimumInteritemSpacing = CGFloat.kiriha_horizontalSize(num: 10)
        layout.minimumLineSpacing = CGFloat.kiriha_verticalSize(num: 10)
        self.photoCollectionView = KCKUICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.photoCollectionView.backgroundColor = UIColor.defaultViewColor
        self.photoCollectionView.register(KCKAddPhotoCollectionCell.self, forCellWithReuseIdentifier: "PhotoCell")
        self.photoCollectionView.dataSource = self
        self.photoCollectionView.delegate = self
        self.photoCollectionView.isScrollEnabled = false
        self.addSubview(self.photoCollectionView)
        self.photoCollectionView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(self.viewHeight)
            make.bottom.equalToSuperview()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialize()
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        
        self.photoCollectionView.snp.updateConstraints { make in
            make.height.equalTo(self.viewHeight)
        }
    }
    
    /**
     获取指定序号的相片。
     
     - Parameters:
        - from: 序号。
     
     - Returns: 返回存储在内存中的相片原片。若返回 `nil`，则代表指定的是一个空相框或该序号是一个无效的序号。
     */
    open func getPhoto(from index: Int) -> UIImage? {
        return self.photos[index]
    }
    
    /**
     增加一个空相框。
     
     - Important: 若调用该方法时，照片数量 + 空相框数量 = `maxPhotos`，则调用此方法不会有任何效果。
     */
    open func addEmptyPhoto() {
        if self.photos.count < self.maxPhotos {
            self.photos.append(nil)
            self.photoCollectionView.reloadData()
            self.updateConstraints()
        }
    }
    
    /**
     手动添加一张照片。
     
     - Important: 调用该方法会在末尾的位置添加一张照片，并会自动添加一个空相框。
     */
    public func addPhoto(image: UIImage) {
        let addIndex: Int = self.photos.count - 1
        self.photos[addIndex] = image
        self.addEmptyPhoto()
    }
    
    /**
     手动更新照片。
     */
    public func updatePhotos(indexs: [Int]) {
        var indexPaths: [IndexPath] = []
        for item in indexs {
            indexPaths.append(IndexPath(item: item, section: 0))
        }
        self.photoCollectionView.reloadItems(at: indexPaths)
    }
}

// MARK: - UICollectionViewDataSource.

extension KCKAddPhotoView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: KCKAddPhotoCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! KCKAddPhotoCollectionCell
        cell.addPhotoView = self
        cell.index = indexPath.row
        cell.aCellSize = self.itemEdge
        cell.setImage(image: self.photos[indexPath.row])
        cell.removePhotoCallBack = { [weak self] index in
            guard let strongSelf = self else { return }
            let full: Bool = strongSelf.photos.last! != nil
            strongSelf.photos.remove(at: index)
            DispatchQueue.main.async {
                if full {
                    strongSelf.addEmptyPhoto()
                    strongSelf.photoCollectionView.reloadData()
                } else {
                    strongSelf.photoCollectionView.reloadData()
                }
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate.

extension KCKAddPhotoView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.delegate != nil {
            self.delegate?.addPhotoView?(addPhotoView: self, didSelectItemAt: indexPath.row)
        } else {
            self.currentSelectIndex = indexPath.row
            let imagePicker: UIImagePickerController = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.isEditing = true
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.modalPresentationStyle = .fullScreen
            imagePicker.cameraCaptureMode = .photo
            UIViewController.kiriha_currentActivityViewController()?.present(imagePicker, animated: true, completion: nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate.

extension KCKAddPhotoView: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image: UIImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        self.photos[self.currentSelectIndex] = image
        if self.currentSelectIndex == self.photos.count - 1 && self.currentSelectIndex < self.maxPhotos - 1 {
            self.addEmptyPhoto()
        } else {
            self.photoCollectionView.reloadItems(at: [IndexPath(item: self.currentSelectIndex, section: 0)])
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
