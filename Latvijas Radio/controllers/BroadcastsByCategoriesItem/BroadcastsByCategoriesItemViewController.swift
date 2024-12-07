//
//  BroadcastsByCategoriesItemViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastsByCategoriesItemViewController: UIViewController {
    
    static var TAG = String(describing: BroadcastsByCategoriesItemViewController.classForCoder())
    
    @IBOutlet weak var textTitle: UILabelH4!
    
    weak var genericPreviewsCollectionViewController: GenericPreviewsCollectionViewController!

    var broadcastsByCategoryModel: BroadcastsByCategoryModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: ColorsHelper.WHITE)
        GeneralUtils.log(BroadcastsByCategoriesItemViewController.TAG, "viewDidLoad")
        
        loadGenericPreviews()
        let customFont1 = UIFont(name: "FuturaPT-Demi", size: 16.0)
        textTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 16.0))
        textTitle.adjustsFontForContentSizeCategory = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_GENERIC_PREVIEWS_COLLECTION:
            self.genericPreviewsCollectionViewController = (segue.destination as! GenericPreviewsCollectionViewController)

            break
        default:
            break
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        // Containers with dynamic height might have loaded while we were away from this view,
//        // causing them to have wrong height.
//        // Update it.
//        
//        view.setNeedsLayout()
//        view.layoutIfNeeded()
//
//        print("viewWillAppear")
//    }
    
    deinit {
        GeneralUtils.log(BroadcastsByCategoriesItemViewController.TAG, "deinit")
    }
    
    func loadGenericPreviews() {
        // update title
        let title = broadcastsByCategoryModel.getName()
        textTitle.setText(title)
        
        // get dataset
        var dataset = [GenericPreviewModel]()
        
        let broadcastsJsonArray = broadcastsByCategoryModel.getBroadcasts()
        let broadcasts = BroadcastsHelper.getBroadcastsListFromJsonArray(broadcastsJsonArray)
        
        for i in (0..<broadcasts.count) {
            let genericPreviewModel = GenericPreviewModel(GenericPreviewModel.TYPE_BROADCAST, broadcasts[i], nil)
            
            dataset.append(genericPreviewModel)
        }

        genericPreviewsCollectionViewController.updateDataset(dataset)
    }
}

