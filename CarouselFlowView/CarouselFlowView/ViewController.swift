//
//  ViewController.swift
//  CarouselFlowView
//
//  Created by 仲召俊 on 2017/8/6.
//  Copyright © 2017年 JOE. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //图片数组
    lazy var imageArray:NSMutableArray = {
        var imgArray = NSMutableArray()
        
        for i in 0..<5 {
            imgArray.add("Yosemited0\(i).jpg")
        }
        
        return imgArray
    }()
    
    //轮播图
    var pageFlowView:NewPagedFlowView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.cyan
        self.title = "NewPagedFlowView"
        
        createView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ViewController {
    
    fileprivate func createView() {
        
        pageFlowView = NewPagedFlowView(frame: CGRect(x: 0, y: 8, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 9 / 16))
        pageFlowView?.backgroundColor = UIColor.white
        pageFlowView?.delegate = self
        pageFlowView?.dataSource = self
        pageFlowView?.minimumPageAlpha = 0.4
        pageFlowView?.orginPageCount = self.imageArray.count
        pageFlowView?.isOpenAutoScroll = true
        pageFlowView?.orientation = .Horizontal
        
        //初始化pageControl
        let pageControl:UIPageControl = UIPageControl(frame: CGRect(x: 0, y: pageFlowView!.frame.size.height - 24, width: UIScreen.main.bounds.size.width, height: 8))
        pageFlowView?.pageControl = pageControl
        pageFlowView?.addSubview(pageControl)
        //self.view.addSubview(pageFlowView!)
        
        let bottomScrollView:UIScrollView = UIScrollView(frame: self.view.bounds)
        pageFlowView?.reloadData()
        bottomScrollView.addSubview(pageFlowView!)
        self.view.addSubview(bottomScrollView)
        
        bottomScrollView.addSubview(pageFlowView!)
    }
}

extension ViewController: NewPagedFlowViewDelegate {
    
    //MARK: NewPagedFlowViewDelegate
    
    func sizeForPageInFlowView(flowView: NewPagedFlowView) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width - 60, height: (UIScreen.main.bounds.size.width - 60) * 9 / 16)
    }
    
    func didSelectCell(subView: UIView, withSubViewIndex subIndex: Int) {
        print("点击了第\(subIndex + 1)图")
    }
}


extension ViewController: NewPagedFlowViewDataSource {
    
    //MARK: NewPagedFlowViewDataSource
    
    func numberOfPagesInFlowView(flowView: NewPagedFlowView) -> Int {
        print("\(self.imageArray)")
        return self.imageArray.count
    }
    
    func flowView(flowView: NewPagedFlowView, cellForPageAtIndex index: Int) -> UIView {
        
        var bannerView = flowView.dequeueReusableCell() as? IndexBannerSubview
        if bannerView == nil {
            bannerView = IndexBannerSubview(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 9 / 16))
            bannerView?.tag = index
            bannerView?.layer.cornerRadius = 4
            bannerView?.layer.masksToBounds = true
        }
        
        bannerView?.mainImageView.image = UIImage(named: self.imageArray[index] as! String)
        
        return bannerView!
    }
    
    func didScrollToPage(pageNumber: Int, flowView: NewPagedFlowView) {
        print("滚动到了第\(pageNumber + 1)页")
    }
}

extension ViewController {
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return interfaceOrientation != .portraitUpsideDown
    }
}



