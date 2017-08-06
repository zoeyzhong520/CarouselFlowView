//
//  NewPagedFlowView.swift
//  CarouselFlowView
//
//  Created by JOE on 2017/8/6.
//  Copyright © 2017年 JOE. All rights reserved.
//

import UIKit

enum NewPagedFlowViewOrientation: Int {
    case Horizontal = 0
    case Vertical
}

@objc protocol NewPagedFlowViewDataSource {
    
    @objc optional
    
    //MARK: 返回显示View的个数
    func numberOfPagesInFlowView(flowView: NewPagedFlowView) -> Int
    
    //MARK: 给某一列设置属性
    func flowView(flowView: NewPagedFlowView, cellForPageAtIndex index: Int) -> UIView
}

@objc protocol NewPagedFlowViewDelegate {
    
    @objc optional
    
    //MARK: 当前显示cell的Size
    func sizeForPageInFlowView(flowView: NewPagedFlowView) -> CGSize
    
    //MARk: 滚动到了某一列
    func didScrollToPage(pageNumber: Int, flowView: NewPagedFlowView)
    
    //MARK: 点击了第几个cell
    func didSelectCell(subView: UIView, withSubViewIndex subIndex: Int)
}

class NewPagedFlowView: UIView {

    //代理
    var dataSource:NewPagedFlowViewDataSource?
    var delegate:NewPagedFlowViewDelegate?
    
    //默认为横向
    var orientation:NewPagedFlowViewOrientation?
    
    var scrollView:UIScrollView?
    
    var neadsReload:Bool?
    
    //总页数
    var pageCount:Int?
    
    var cells:NSMutableArray?
    
    var visibleRange:NSRange?
    
    //如果以后需要支持reuseIdentifier，这边就得使用字典类型
    var reusableCells = [UIView]()
    
    //指示器
    var pageControl:UIPageControl?
    
    //非当前页的透明比例
    var minimumPageAlpha:CGFloat?
    
    //左右间距,默认20
    var leftRightMargin:CGFloat? {
        didSet {
            setLeftRightMargin(leftRightMargin: leftRightMargin)
        }
    }
    
    //上下间距,默认30
    var topBottomMargin:CGFloat? {
        didSet {
            setTopBottomMargin(TopBottomMargin: topBottomMargin)
        }
    }
    
    //是否开启自动滚动,默认为开启
    var isOpenAutoScroll:Bool?
    
    //是否开启无限轮播,默认为开启
    var isCarousel:Bool?
    
    //当前是第几页
    var currentPageIndex:Int?
    
    //定时器
    var timer:Timer?
    
    //计时器用到的页数
    var page:Int?
    
    //自动切换视图的时间,默认是5.0
    var autoTime:CGFloat?
    
    //原始页数
    var orginPageCount:Int?

    //一页的尺寸
    var pageSize:CGSize?
    
    //子控制器的类名
    var subviewClassName:String?
}


extension NewPagedFlowView {
    //MARK: 刷新视图
    /**
     *  刷新视图
     */
    func reloadData() {
        
    }
}

extension NewPagedFlowView {
    //MARK: 获取可重复使用的Cell
    /**
     *  获取可重复使用的Cell
     *
     *  @return <#return value description#>
     */
    func dequeueReusableCell() -> UIView {
        return UIView()
        
    }
}

extension NewPagedFlowView {
    //MARK: 滚动到指定的页面
    /**
     *  滚动到指定的页面
     *
     *  @param pageNumber <#pageNumber description#>
     */
    func scrollToPage(pageNumber:Int) {
        
    }
}

extension NewPagedFlowView {
    //MARK: 关闭定时器,关闭自动滚动
    /**
     *  关闭定时器,关闭自动滚动
     */
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

extension NewPagedFlowView {
    //MARK: Private Methods
    
    func initialize() {
        
        self.clipsToBounds = true
        
        self.neadsReload = true
        self.pageCount = 0
        self.isOpenAutoScroll = true
        self.isCarousel = true
        self.leftRightMargin = 20
        self.topBottomMargin = 30
        self.currentPageIndex = 0
        
        self.minimumPageAlpha = 1.0
        self.autoTime = 5.0
        
        self.visibleRange = NSMakeRange(0, 0)
        self.reusableCells = [UIView]()
        
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView?.scrollsToTop = false
        self.scrollView?.delegate = self
        self.scrollView?.isPagingEnabled = true
        self.scrollView?.clipsToBounds = false
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
        
        subviewClassName = "PGIndexBannerSubiew"
        
        /*由于UIScrollView在滚动之后会调用自己的layoutSubviews以及父View的layoutSubviews
         这里为了避免scrollview滚动带来自己layoutSubviews的调用,所以给scrollView加了一层父View
         */
        let superViewOfScrollView = UIView(frame: self.bounds)
        superViewOfScrollView.autoresizingMask = .flexibleWidth
        superViewOfScrollView.autoresizingMask = .flexibleHeight
        superViewOfScrollView.backgroundColor = UIColor.clear
        superViewOfScrollView.addSubview(self.scrollView!)
        addSubview(superViewOfScrollView)
    }
    
    func setLeftRightMargin(leftRightMargin: CGFloat?) {
        self.leftRightMargin = leftRightMargin! * 0.5
    }
    
    func setTopBottomMargin(TopBottomMargin: CGFloat?) {
        self.topBottomMargin = topBottomMargin! * 0.5
    }
    
    func startTimer() {
        if self.orginPageCount! > 0 && self.isOpenAutoScroll == true && self.isCarousel == true {
            
            let timer = Timer.scheduledTimer(timeInterval: Double(self.autoTime!), target: self, selector: #selector(autoNextPage), userInfo: nil, repeats: true)
            self.timer = timer
            RunLoop.main.add(timer, forMode: .commonModes)
        }
    }
}

extension NewPagedFlowView {
    //MARK: 自动轮播
    
    func autoNextPage() {
        self.page! += 1
        
        switch self.orientation! {
        case .Horizontal:
            scrollView?.setContentOffset(CGPoint(x: CGFloat(self.page!) * pageSize!.width, y: 0), animated: true)
        case .Vertical:
            scrollView?.setContentOffset(CGPoint(x: 0, y: CGFloat(self.page!) * pageSize!.height), animated: true)
        }
    }
    
    func queueReusableCell(cell: UIView) {
        reusableCells.append(cell)
    }
    
    func removeCellAtIndex(index:Int) {
        if let cell = cells?.object(at: index) as? UIView {
            queueReusableCell(cell: cell)
            
            if cell.superview != nil {
                cell.removeFromSuperview()
            }
            
            cells?.replaceObject(at: index, with: NSNull())
        }
    }
}

extension NewPagedFlowView: UIScrollViewDelegate {
    
    //MARK: UIScrollView Delegate
    //MARK: -
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    //MARK: 将要开始拖拽
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    //MARK: 将要结束拖拽
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
    
    //MARK: 结束拖拽
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
}



