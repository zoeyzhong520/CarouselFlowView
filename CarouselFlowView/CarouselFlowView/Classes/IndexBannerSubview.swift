//
//  IndexBannerSubview.swift
//  CarouselFlowView
//
//  Created by JOE on 2017/8/6.
//  Copyright © 2017年 JOE. All rights reserved.
//

import UIKit

class IndexBannerSubview: UIView {

    //MARK: - Lazy
    
    //主图
    lazy var mainImageView: UIImageView = {
        let tempMainImageView = UIImageView(frame: self.bounds)
        tempMainImageView.isUserInteractionEnabled = true
        return tempMainImageView
    }()
    
    //用来变色的view
    lazy var coverView: UIView = {
        let tempCoverView = UIView(frame: self.bounds)
        tempCoverView.backgroundColor = UIColor.black
        return tempCoverView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(self.mainImageView)
        addSubview(self.coverView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}








