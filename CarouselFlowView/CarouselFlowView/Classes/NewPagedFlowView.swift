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

protocol NewPagedFlowViewDataSource {
    
    //MARK: 返回显示View的个数
    func numberOfPagesInFlowView(flowView: NewPagedFlowView) -> Int
    
    //MARK: 给某一列设置属性
    func flowView(flowView: NewPagedFlowView, cellForPageAtIndex index: Int) -> UIView
}

protocol NewPagedFlowViewDelegate {
    
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
    var reusableCells:NSMutableArray?
    
    //指示器
    var pageControl:UIPageControl?
    
    //非当前页的透明比例
    var minimumPageAlpha:CGFloat?
    
    //左右间距,默认20
    var leftRightMargin:CGFloat? {
        didSet {
            leftRightMargin = leftRightMargin! * 0.5
        }
    }
    
    //上下间距,默认30
    var topBottomMargin:CGFloat? {
        didSet {
            topBottomMargin = topBottomMargin! * 0.5
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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension NewPagedFlowView {
    //MARK: 刷新视图
    /**
     *  刷新视图
     */
    func reloadData() {
        neadsReload = true
        
        //移除所有self.scrollView的子控件
        for view:UIView in scrollView!.subviews {
            if NSStringFromClass(view.classForCoder) == subviewClassName || view.isKind(of: IndexBannerSubview().classForCoder) {
                
                view.removeFromSuperview()
            }
        }
        
        stopTimer()
        
        if neadsReload == true {
            //如果需要重新加载数据，则需要清空相关数据全部重新加载
            
            //重置pageCount
            if dataSource != nil {
                
                //原始页数
                orginPageCount = dataSource?.numberOfPagesInFlowView(flowView: self)
                
                //总页数
                if isCarousel == true {
                    pageCount = orginPageCount! == 1 ? 1 : (dataSource?.numberOfPagesInFlowView(flowView: self))! * 3
                }
                else{
                    pageCount = orginPageCount == 1 ? 1 : dataSource?.numberOfPagesInFlowView(flowView: self)
                }
                
                //如果总页数为0，return
                if pageCount == 0 {
                    return
                }
                
                if pageControl != nil {
                    pageControl?.numberOfPages = orginPageCount!
                }
            }
            
            //重置pageWidth
            pageSize = CGSize(width: bounds.size.width - 4 * leftRightMargin!, height: (bounds.size.width - 4 * leftRightMargin!) * 9 / 16)
            if delegate != nil {
                pageSize = delegate?.sizeForPageInFlowView(flowView: self)
            }
            
            reusableCells?.removeAllObjects()
            visibleRange = NSMakeRange(0, 0)
            
            //填充cells数组
            cells?.removeAllObjects()
            for _ in 0..<pageCount! {
                cells?.add(NSNull())
            }
            
            // 重置_scrollView的contentSize
            switch orientation! {
            case .Horizontal:
                scrollView?.frame = CGRect(x: 0, y: 0, width: pageSize!.width, height: pageSize!.height)
                scrollView?.contentSize = CGSize(width: pageSize!.width * CGFloat(pageCount!), height: pageSize!.height)
                let theCenter:CGPoint = CGPoint(x: bounds.midX, y: bounds.midY)
                scrollView?.center = theCenter
                
                if orginPageCount! > 1 {
                    if isCarousel == true {
                        //滚到第二组
                        scrollView?.contentOffset = CGPoint(x: pageSize!.width * CGFloat(orginPageCount!), y: 0)
                        
                        page = orginPageCount
                        
                        //启动自动轮播
                        startTimer()
                    }
                    else{
                        //滚到开始
                        scrollView?.contentOffset = CGPoint(x: 0, y: 0)
                        
                        page = orginPageCount
                    }
                }
            case .Vertical:
                scrollView?.frame = CGRect(x: 0, y: 0, width: pageSize!.width, height: pageSize!.height)
                scrollView?.contentSize = CGSize(width: pageSize!.width, height: pageSize!.height * CGFloat(pageCount!))
                let theCenter:CGPoint = CGPoint(x: bounds.midX, y: bounds.midY)
                scrollView?.center = theCenter
                
                if orginPageCount! > 1 {
                    if isCarousel == true {
                        //滚到第二组
                        scrollView?.contentOffset = CGPoint(x: 0, y: pageSize!.height * CGFloat(orginPageCount!))
                        
                        page = orginPageCount
                        
                        //启动自动轮播
                        startTimer()
                    }
                    else{
                        //滚到开始
                        scrollView?.contentOffset = CGPoint(x: 0, y: 0)
                        
                        page = orginPageCount
                    }
                }
            }
        }
        
        setPagesAtContentOffset(offSet: scrollView!.contentOffset) //根据当前scrollView的offset设置cell
        
        refreshVisibleCellAppearance() //更新各个可见Cell的显示外貌
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
        
        let cell = reusableCells?.lastObject
        if cell != nil {
            reusableCells?.removeLastObject()
        }
        
        return cell as! UIView
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
        if pageNumber < pageCount! {
            
            //首先停止定时器
            stopTimer()
            
            if isCarousel == true {
                page = pageNumber + orginPageCount!
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(startTimer), object: nil)
                perform(#selector(startTimer), with: self, afterDelay: 0.5)
            }
            else{
                page = pageNumber
            }
            
            switch orientation! {
            case .Horizontal:
                scrollView?.contentOffset = CGPoint(x: pageSize!.width * CGFloat(page!), y: 0)
            case .Vertical:
                scrollView?.contentOffset = CGPoint(x: 0, y: pageSize!.height * CGFloat(page!))
            }
            
            setPagesAtContentOffset(offSet: scrollView!.contentOffset)
            refreshVisibleCellAppearance()
        }
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
        self.reusableCells = NSMutableArray()
        self.cells = NSMutableArray()
        
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView?.scrollsToTop = false
        self.scrollView?.delegate = self
        self.scrollView?.isPagingEnabled = true
        self.scrollView?.clipsToBounds = false
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
        
        subviewClassName = "IndexBannerSubview"
        
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
    
    func setLeftRightMargin() {
        self.leftRightMargin = leftRightMargin! * 0.5
    }
    
    func setTopBottomMargin() {
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
        reusableCells?.add(cell)
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
    
    func refreshVisibleCellAppearance() {
        if minimumPageAlpha == 1.0 && leftRightMargin == 0 && topBottomMargin == 0 {
            return //无需更新
        }
        
        switch orientation! {
        case .Horizontal:
            guard let offSet = scrollView?.contentOffset.x else {
                return
            }
            
            for i in visibleRange!.location..<(visibleRange!.location + visibleRange!.length) {
                guard let cell = cells?.object(at: i) as? IndexBannerSubview else {
                    return
                }
                
                subviewClassName = NSStringFromClass(cell.classForCoder)
                let origin:CGFloat = cell.frame.origin.x
                let delta:CGFloat = fabs(origin - offSet)
                
                let originCellFrame:CGRect = CGRect(x: pageSize!.width * CGFloat(i), y: 0, width: pageSize!.width, height: pageSize!.height) //如果没有缩小效果的情况下的本该的Frame
                
                if delta < pageSize!.width {
                    cell.coverView.alpha = (delta / pageSize!.width) * minimumPageAlpha!
                    
                    let leftRightInset:CGFloat = leftRightMargin! * delta / pageSize!.width
                    let topBottomInset:CGFloat = topBottomMargin! * delta / pageSize!.width
                    
                    cell.layer.transform = CATransform3DMakeScale((pageSize!.width - leftRightInset * 2) / pageSize!.width, (pageSize!.height - topBottomInset * 2) / pageSize!.height, 1.0)
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset))
                }
                else{
                    cell.coverView.alpha = minimumPageAlpha!
                    
                    cell.layer.transform = CATransform3DMakeScale((pageSize!.width - leftRightMargin! * 2) / pageSize!.width, (pageSize!.height - leftRightMargin! * 2) / pageSize!.height, 1.0)
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(topBottomMargin!, leftRightMargin!, topBottomMargin!, leftRightMargin!))
                }
            }
            
        case .Vertical:
            guard let offSet:CGFloat = scrollView?.contentOffset.y else {
                return
            }
            
            for i in 0..<(visibleRange!.location + visibleRange!.length) {
                guard let cell = cells?.object(at: i) as? IndexBannerSubview else {
                    return
                }
                
                subviewClassName = NSStringFromClass(cell.classForCoder)
                let origin:CGFloat = cell.frame.origin.y
                let delta:CGFloat = fabs(origin - offSet)
                
                let originCellFrame:CGRect = CGRect(x: 0, y: pageSize!.height * CGFloat(i), width: pageSize!.width, height: pageSize!.height) //如果没有缩小效果的情况下的本该的Frame
                
                if delta < pageSize!.height {
                    cell.coverView.alpha = (delta / pageSize!.height) * minimumPageAlpha!
                    
                    let leftRightInset:CGFloat = leftRightMargin! * delta / pageSize!.height
                    let topBottomInset:CGFloat = topBottomMargin! * delta / pageSize!.height
                    
                    cell.layer.transform = CATransform3DMakeScale((pageSize!.width - leftRightInset * 2) / pageSize!.width, (pageSize!.height - topBottomInset * 2) / pageSize!.height, 1.0)
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset))
                    cell.mainImageView.frame = cell.bounds
                }
                else{
                    cell.coverView.alpha = minimumPageAlpha!
                    
                    cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(topBottomMargin!, leftRightMargin!, topBottomMargin!, leftRightMargin!))
                    cell.mainImageView.frame = cell.bounds
                }
            }
        }
    }
    
    func setPageAtIndex(pageIndex: Int) {
        assert(pageIndex >= 0 && pageIndex < cells!.count)
        
        var cell = cells?.object(at: pageIndex) as? UIView
        if cell == NSNull() {
            cell = dataSource?.flowView(flowView: self, cellForPageAtIndex: orginPageCount!)
            
            assert(cell != nil, "datasource must not return nil")
            
            cells?.replaceObject(at: pageIndex, with: cell!)
            
            //添加点击手势
            let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(singleCellTapAction(tap:)))
            cell?.addGestureRecognizer(singleTap)
            cell?.tag = pageIndex % orginPageCount!
            
            switch orientation! {
            case .Horizontal:
                cell?.frame = CGRect(x: pageSize!.width * CGFloat(pageIndex), y: 0, width: pageSize!.width, height: pageSize!.height)
            case .Vertical:
                cell?.frame = CGRect(x: 0, y: pageSize!.height * CGFloat(pageIndex), width: pageSize!.width, height: pageSize!.height)
            }
            
            if cell?.superview == nil {
                scrollView?.addSubview(cell!)
            }
        }
    }
    
    func setPagesAtContentOffset(offSet: CGPoint) {
        
        //MARK: 计算_visibleRange
        
        let startPoint:CGPoint = CGPoint(x: offSet.x - scrollView!.frame.origin.x, y: offSet.y - scrollView!.frame.origin.y)
        
        let endPoint:CGPoint = CGPoint(x: startPoint.x + self.bounds.size.width, y: startPoint.y + self.bounds.size.height)
        
        switch orientation! {
        case .Horizontal:
            var startIndex:Int = 0
            
            for i in 0..<cells!.count {
                if (pageSize!.width * CGFloat(i + 1) > startPoint.x) {
                    startIndex = i
                    break
                }
            }
            
            var endIndex:Int = startIndex
            
            for i in startIndex..<cells!.count {
                //如果都不超过则取最后一个
                if (pageSize!.width * CGFloat(i + 1) < endPoint.x && pageSize!.width * CGFloat(i + 2) >= endPoint.x || (i + 2) == cells!.count) {
                    
                    endIndex = i + 1 //i+2 是以个数，所以其index需要减去1
                    break
                }
            }
            
            //可见页分别向前向后扩展一个，提高效率
            startIndex = max(startIndex - 1, 0)
            endIndex = min(endIndex + 1, cells!.count - 1)
            
            visibleRange = NSMakeRange(startIndex, endIndex - startIndex + 1)
            for i in startIndex...endIndex {
                setPageAtIndex(pageIndex: i)
            }
            
            for i in 0..<startIndex {
                removeCellAtIndex(index: i)
            }
            
            for i in (endIndex + 1)..<cells!.count {
                removeCellAtIndex(index: i)
            }
        case .Vertical:
            var startIndex:Int = 0
            for i in 0..<cells!.count {
                if pageSize!.height * CGFloat(i + 1) > startPoint.y {
                    startIndex = i
                    break
                }
            }
            
            var endIndex:Int = startIndex
            
            for i in startIndex..<cells!.count {
                //如果都不超过则取最后一个
                if (pageSize!.height * CGFloat(i + 1) < endPoint.y && pageSize!.height * CGFloat(i + 2) >= endPoint.y || (i + 2) == cells!.count) {
                    
                    endIndex = i + 1 //i+2 是以个数，所以其index需要减去1
                    break
                }
            }
            
            //可见页分别向前向后扩展一个，提高效率
            startIndex = max(startIndex - 1, 0)
            endIndex = min(endIndex + 1, cells!.count - 1)
            
            visibleRange?.location = startIndex
            visibleRange?.length = endIndex - startIndex + 1
            
            for i in startIndex...endIndex {
                setPageAtIndex(pageIndex: i)
            }
            
            for i in 0..<startIndex {
                removeCellAtIndex(index: i)
            }
            
            for i in (endIndex + 1)..<cells!.count {
                removeCellAtIndex(index: i)
            }
        }
    }
}

extension NewPagedFlowView {
    
    //MARK: 点击了cell
    
    func singleCellTapAction(tap:UITapGestureRecognizer) {
        if delegate != nil {
            delegate?.didSelectCell(subView: tap.view!, withSubViewIndex: tap.view!.tag)
        }
    }
}

extension NewPagedFlowView {
    
    //MARK: hitTest
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var newPoint:CGPoint = CGPoint(x: 0, y: 0)
        newPoint.x = point.x - scrollView!.frame.origin.x + scrollView!.contentOffset.x
        newPoint.y = point.y - scrollView!.frame.origin.y + scrollView!.contentOffset.y
        
        if scrollView!.point(inside: newPoint, with: event) {
            return scrollView?.hitTest(newPoint, with: event)
        }
        
        return scrollView
    }
}

extension NewPagedFlowView: UIScrollViewDelegate {
    
    //MARK: UIScrollView Delegate
    //MARK: -
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if orginPageCount == 0 {
            return
        }
        
        var pageIndex:Int = 0
        
        switch orientation! {
        case .Horizontal:
            pageIndex = Int(round(self.scrollView!.contentOffset.x) / pageSize!.width) % orginPageCount!
        case .Vertical:
            pageIndex = Int(round(self.scrollView!.contentOffset.y) / pageSize!.height) % orginPageCount!
        }
        
        if isCarousel == true {
            if orginPageCount! > 1 {
                switch orientation! {
                case .Horizontal:
                    if scrollView.contentOffset.x / pageSize!.width >= CGFloat(2 * orginPageCount!) {
                        
                        scrollView.contentOffset = CGPoint(x: pageSize!.width * CGFloat(orginPageCount!), y: 0)
                        
                        page = orginPageCount
                    }
                    
                    if scrollView.contentOffset.x / pageSize!.width <= CGFloat(orginPageCount! - 1) {
                        
                        scrollView.contentOffset = CGPoint(x: (CGFloat(2 * (orginPageCount! - 1)) * pageSize!.width), y: 0)
                        
                        page = 2 * orginPageCount!
                    }
                case .Vertical:
                    if scrollView.contentOffset.y / pageSize!.height >= CGFloat(2 * orginPageCount!) {
                        
                        scrollView.contentOffset = CGPoint(x: 0, y: pageSize!.height * CGFloat(orginPageCount!))
                        
                        page = orginPageCount
                    }
                    
                    if scrollView.contentOffset.y / pageSize!.height <= CGFloat(orginPageCount! - 1) {
                        
                        scrollView.contentOffset = CGPoint(x: 0, y: (CGFloat(2 * (orginPageCount! - 1)) * pageSize!.height))
                        
                        page = 2 * orginPageCount!
                    }
                }
            }
            else{
                pageIndex = 0
            }
        }
        
        setPagesAtContentOffset(offSet: scrollView.contentOffset)
        refreshVisibleCellAppearance()
        
        if pageControl != nil {
            pageControl?.currentPage = pageIndex
        }
        
        if delegate != nil && currentPageIndex != pageIndex && pageIndex >= 0 {
            delegate?.didScrollToPage(pageNumber: pageIndex, flowView: self)
        }
        
        currentPageIndex = pageIndex
    }
    
    //MARK: 将要开始拖拽
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    //MARK: 将要结束拖拽
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if orginPageCount! > 1 && isOpenAutoScroll == true && isCarousel == true {
            
            switch orientation! {
            case .Horizontal:
                if page == Int(scrollView.contentOffset.x / pageSize!.width) {
                    page = Int(scrollView.contentOffset.x / pageSize!.width) + 1
                }
                else{
                    page = Int(scrollView.contentOffset.x / pageSize!.width)
                }
            case .Vertical:
                if page == Int(scrollView.contentOffset.y / pageSize!.height) {
                    page = Int(scrollView.contentOffset.y / pageSize!.height) + 1
                }
                else{
                    page = Int(scrollView.contentOffset.y / pageSize!.height)
                }
            }
        }
    }
    
    //MARK: 结束拖拽
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer()
    }
}



