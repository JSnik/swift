//
//  DynamicBlockPresentationType2ViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class DynamicBlockPresentationType2ViewController: UIViewController {
    
    static var TAG = String(describing: DynamicBlockPresentationType2ViewController.classForCoder())

    @IBOutlet weak var textTitle: UILabelH4!
    weak var collectionViewGenericPreviews: GenericPreviewsCollectionViewController!
    
    var dynamicBlockModel: DynamicBlockModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(DynamicBlockPresentationType2ViewController.TAG, "viewDidLoad")
        
        loadDynamicBlock(dynamicBlockModel)
        let customFont = UIFont(name: "FuturaPT-Demi", size: 16.0)
        textTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 17.0))
        textTitle.adjustsFontForContentSizeCategory = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_GENERIC_PREVIEWS_COLLECTION:
            self.collectionViewGenericPreviews = (segue.destination as! GenericPreviewsCollectionViewController)

            break
        default:
            break
        }
    }
    
    deinit {
        GeneralUtils.log(DynamicBlockPresentationType2ViewController.TAG, "deinit")
    }
    
    func loadDynamicBlock(_ dynamicBlockModel: DynamicBlockModel) {
        // update title
        if let title = dynamicBlockModel.getName() {
            textTitle.setText(title)
        } else {
            textTitle.setVisibility(UIView.VISIBILITY_GONE)
        }
        
        let dataset = DynamicBlocksPresentationHelper.getGenericPreviewsFromDynamicBlock(dynamicBlockModel)

        collectionViewGenericPreviews.updateDataset(dataset)
    }
}

