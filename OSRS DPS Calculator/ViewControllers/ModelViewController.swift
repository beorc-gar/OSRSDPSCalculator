//
//  File.swift
//  OSRS DPS Calculator
//
//  Created by Bronson Graansma on 2018-03-15.
//  Copyright © 2018 Bronson Graansma. All rights reserved.
//

import Foundation
import UIKit

class ModelViewController: OSRSViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var collection: UICollectionView? = nil
    
    var cellSize = CGSize()
    
    var models: [Model] = [] // reinit in subclass
    var images: [UIImage] = []
    var imageViews: [UIImageView] = []
    var highlight: UIImage = UIImage()
    let cellId: String = "collectionCell"
    
    var modelsPerLine: CGFloat = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var i = 0
        cellSize = CGSize(width:(UIScreen.main.bounds.width-40)/modelsPerLine, height:(UIScreen.main.bounds.width-40)/modelsPerLine)
        highlight = Utilities.resizeImage(#imageLiteral(resourceName: "highlight"), width: cellSize.width, height: cellSize.height)
        
        for model in models {
            var image: UIImage = UIImage()
            let img = #imageLiteral(resourceName: model.name)
            
            if img.size.width > img.size.height {
                let ratio = cellSize.width / img.size.width
                image = Utilities.resizeImage(img, width: cellSize.width*0.75, height: (img.size.height*ratio)*0.75)
            } else {
                let ratio = cellSize.height / img.size.height
                image = Utilities.resizeImage(img, width: (img.size.width*ratio)*0.75, height: cellSize.height*0.75)
            }
            images.append(image)
            imageViews.append(UIImageView(image: image))
            i += 1
        }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: UIScreen.main.bounds.height * 0.105, left: 19, bottom: 0, right: 19)
        layout.itemSize = cellSize
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        
        collection = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collection!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collection!.delegate = self
        collection!.dataSource = self
        collection!.backgroundColor = UIColor.clear
        
        view.addSubview(collection!)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        imageViews[indexPath.item].center = cell.contentView.center
        if models[indexPath.item].isActivated() {
            cell.contentView.backgroundColor = UIColor(patternImage: highlight)
        } else {
            cell.contentView.backgroundColor = nil
        }
        if !models[indexPath.item].canActivate() {
            imageViews[indexPath.item].alpha = 0.25
        } else {
            imageViews[indexPath.item].alpha = 1.0
        }
        cell.contentView.addSubview(imageViews[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if models[indexPath.item].isActivated() {
            models[indexPath.item].deactivate()
            collection?.reloadData()
            updateMetrics()
        } else if models[indexPath.item].activate() {
            collection?.reloadData()
            updateMetrics()
        }
    }
}
