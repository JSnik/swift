//
//  BroadcastsViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastsViewController: UIViewController, UIScrollViewDelegate {
    
    static var TAG = String(describing: BroadcastsViewController.classForCoder())
    
    static var needsScrollReset = false
    static var needsUpdate = false
    static let EVENT_SCROLL_TO_TOP_BROADCASTS = "EVENT_SCROLL_TO_TOP_BROADCASTS"

    @IBOutlet weak var mainScrollView: UIScrollViewCollaborative!
    @IBOutlet weak var containerDynamicBlocks: UIView!
    @IBOutlet weak var dynamicBlocksActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerBroadcastsByCategories: UIView!
    @IBOutlet weak var textTitle: UILabelH1!
    @IBOutlet weak var broadcastsByCategoriesActivityIndicator: UIActivityIndicatorView!
    
    weak var dynamicBlocksCollectionViewController: DynamicBlocksCollectionViewController!
    weak var broadcastsByCategoriesCollectionViewController: BroadcastsByCategoriesCollectionViewController!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(BroadcastsViewController.TAG, "viewDidLoad")
        
        // delegates
        mainScrollView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTheTop), name: Notification.Name(BroadcastsViewController.EVENT_SCROLL_TO_TOP_BROADCASTS), object: nil)

        performRequestContentSection()
        
        performRequestBroadcastByCategory()
        let customFont3 = UIFont(name: "FuturaPT-Book", size: 22.0)
        textTitle.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: customFont3 ?? UIFont.systemFont(ofSize: 22.0))
        textTitle.adjustsFontForContentSizeCategory = true
    }

    @objc func scrollToTheTop() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.mainScrollView.setContentOffset(.zero, animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset scrolls.
        if (BroadcastsViewController.needsScrollReset) {
            BroadcastsViewController.needsScrollReset = false
            
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                self?.mainScrollView.setContentOffset(.zero, animated: false)
            }

            if (broadcastsByCategoriesCollectionViewController.dataset.count > 0) {
                broadcastsByCategoriesCollectionViewController.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }

        checkIfViewControllerNeedsUpdate()
    }
    
    deinit {
        GeneralUtils.log(BroadcastsViewController.TAG, "deinit")
        
        BroadcastsViewController.needsScrollReset = false
        BroadcastsViewController.needsUpdate = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_DYNAMIC_BLOCKS_COLLECTION:
            self.dynamicBlocksCollectionViewController = (segue.destination as! DynamicBlocksCollectionViewController)
            
            break
        case StoryboardsHelper.SEGUE_EMBED_BROADCASTS_BY_CATEGORIES_COLLECTION:
            self.broadcastsByCategoriesCollectionViewController = (segue.destination as! BroadcastsByCategoriesCollectionViewController)
            self.broadcastsByCategoriesCollectionViewController.scrollDelegate = self

            break
        default:
            break
        }
    }
    
    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        CollaborativeScrollViewHelper.scrollViewDidScroll(scrollView, mainScrollView, (self.broadcastsByCategoriesCollectionViewController.collectionView as! UICollectionViewBase))
    }
    
    // MARK: Custom
    
    @objc func appMovedToForeground() {
        checkIfViewControllerNeedsUpdate()
    }
    
    func checkIfViewControllerNeedsUpdate() {
        if (BroadcastsViewController.needsUpdate) {
            BroadcastsViewController.needsUpdate = false

            if let dashboardContainerViewController = appDelegate.dashboardContainerViewController {
                if let mainPageViewController = dashboardContainerViewController.mainPageViewController {
                    let currentPageIndex = mainPageViewController.getCurrentPageIndex()
                    
                    let viewController = UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCASTS, bundle: nil)
                        .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCASTS) as! BroadcastsViewController
                    
                    mainPageViewController.orderedViewControllers[NavigationViewController.NAVIGATION_ITEM_INDEX_BROADCASTS] = viewController
                    
                    // if this view controller IS the current active tab, reload it
                    if (currentPageIndex == NavigationViewController.NAVIGATION_ITEM_INDEX_BROADCASTS) {
                        mainPageViewController.setViewControllers([mainPageViewController.orderedViewControllers[NavigationViewController.NAVIGATION_ITEM_INDEX_BROADCASTS]], direction: .forward, animated: false, completion: nil)
                    }
                }
            }
        }
    }

    func setViewStateContentSectionNormal() {
        containerDynamicBlocks.isHidden = false
        dynamicBlocksActivityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateContentSectionLoading() {
        containerDynamicBlocks.isHidden = true
        dynamicBlocksActivityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    func setViewStateContentSectionNoResults() {
        containerDynamicBlocks.setVisibility(UIView.VISIBILITY_GONE)
        dynamicBlocksActivityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }
    
    func setViewStateBroadcastsByCategoriesNormal() {
        containerBroadcastsByCategories.isHidden = false
        broadcastsByCategoriesActivityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }
    
    func setViewStateBroadcastsByCategoriesLoading() {
        containerBroadcastsByCategories.isHidden = true
        broadcastsByCategoriesActivityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    func setViewStateBroadcastsByCategoriesNoResults() {
        containerBroadcastsByCategories.setVisibility(UIView.VISIBILITY_GONE)
        broadcastsByCategoriesActivityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }
    
    func performRequestContentSection() {
        setViewStateContentSectionLoading()
        
        let contentSectionRequest = ContentSectionRequest(appDelegate.dashboardContainerViewController!.notificationViewController, ContentSectionRequest.SECTION_ID_BROADCASTS)

        contentSectionRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleContentSectionResponse(data)
        }
        
        contentSectionRequest.errorCallback = { [weak self] in
            self?.setViewStateContentSectionNoResults()
        }
        
        contentSectionRequest.execute()
    }
    
    func handleContentSectionResponse(_ data: [String: Any]) {
        var dataset = [DynamicBlockModel]()
        
        let blocks = data[ContentSectionRequest.RESPONSE_PARAM_BLOCKS] as! [[String: Any]]
        
        if (blocks.count > 0) {
            for i in (0..<blocks.count) {
                let block = blocks[i]
                
                let name = block[ContentSectionRequest.RESPONSE_PARAM_NAME] as? String
                let presentationTypeId = block[ContentSectionRequest.RESPONSE_PARAM_PRESENTATION_TYPE_ID] as! Int
                let contentType = block[ContentSectionRequest.RESPONSE_PARAM_CONTENT_TYPE] as! String
                let items = block[ContentSectionRequest.RESPONSE_PARAM_ITEMS] as! [NSDictionary]
                
                let dynamicBlockModel = DynamicBlockModel(name, String(presentationTypeId), contentType)
                dynamicBlockModel.setItems(items)
                
                dataset.append(dynamicBlockModel)
            }
            
            dynamicBlocksCollectionViewController.updateDataset(dataset)
            
            setViewStateContentSectionNormal()
        } else {
            setViewStateContentSectionNoResults()
        }
    }
    
    func performRequestBroadcastByCategory() {
        setViewStateBroadcastsByCategoriesLoading()
        
        let broadcastByCategoryRequest = BroadcastByCategoryRequest(appDelegate.dashboardContainerViewController!.notificationViewController)

        broadcastByCategoryRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleBroadcastsByCategoryResponse(data)
        }
        
        broadcastByCategoryRequest.errorCallback = { [weak self] in
            self?.setViewStateBroadcastsByCategoriesNoResults()
        }
        
        broadcastByCategoryRequest.execute()
    }
    
    func handleBroadcastsByCategoryResponse(_ data: [String: Any]) {
        var dataset = [BroadcastsByCategoryModel]()

        let categories = data[BroadcastByCategoryRequest.RESPONSE_PARAM_CATEGORIES] as! [[String: Any]]
        print("BroadcastsViewController categories = \(categories)")
        if (categories.count > 0) {
            for i in (0..<categories.count) {
                let category = categories[i]

                let id = category[BroadcastByCategoryRequest.RESPONSE_PARAM_ID] as! String
                let name = category[BroadcastByCategoryRequest.RESPONSE_PARAM_TITLE] as! String
                let broadcasts = category[BroadcastByCategoryRequest.RESPONSE_PARAM_BROADCASTS] as! [NSDictionary]

                let broadcastsByCategoryModel = BroadcastsByCategoryModel(String(id), name)
                broadcastsByCategoryModel.setBroadcasts(broadcasts)

                dataset.append(broadcastsByCategoryModel)
            }

            broadcastsByCategoriesCollectionViewController.updateDataset(dataset)

            setViewStateBroadcastsByCategoriesNormal()
        } else {
            setViewStateBroadcastsByCategoriesNoResults()
        }
    }
}

