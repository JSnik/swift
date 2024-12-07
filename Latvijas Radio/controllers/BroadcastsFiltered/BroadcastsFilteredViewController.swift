//
//  BroadcastsFilteredViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastsFilteredViewController: UIViewController {
    
    static var TAG = String(describing: BroadcastsFilteredViewController.classForCoder())

    @IBOutlet weak var containerNotification: UIView!
    @IBOutlet weak var buttonBack: UIButtonQuinary!
    @IBOutlet weak var textTitle: UILabelLabel2!
    @IBOutlet weak var textSubtitle: UILabelH3!
    @IBOutlet weak var containerBroadcasts: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    weak var notificationViewController: NotificationViewController!
    weak var broadcastsFilteredCollectionViewController: BroadcastsFilteredCollectionViewController!

    var hitModel: Hit?
    var broadcastsByCategoryModel: BroadcastsByCategoryModel!
    var channelModel: ChannelModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(BroadcastsFilteredViewController.TAG, "viewDidLoad")
        textSubtitle.adjustsFontForContentSizeCategory = true
        textTitle.adjustsFontForContentSizeCategory = true

        // listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        // UI
        setViewStateNormal()

        if (broadcastsByCategoryModel != nil) {
            // update titles
            let categoryName = broadcastsByCategoryModel.getName()
            textSubtitle.setText(categoryName)

            textTitle.setText("category")

            // update dataset
            let broadcastsJsonArray = broadcastsByCategoryModel.getBroadcasts()
            let dataset = BroadcastsHelper.getBroadcastsListFromJsonArray(broadcastsJsonArray)

            broadcastsFilteredCollectionViewController.updateDataset(dataset)
        } else {
            // update titles
            let channelName = channelModel.getName()
            textSubtitle.setText(channelName)

            textTitle.setText("channel")

            // get dataset
            performRequestChannelBroadcasts()
        }

    }
    
    deinit {
        GeneralUtils.log(BroadcastsFilteredViewController.TAG, "deinit")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_NOTIFICATION:
            self.notificationViewController = (segue.destination as! NotificationViewController)
            self.notificationViewController.setContainerView(containerNotification)
            
            break
        case StoryboardsHelper.SEGUE_EMBED_BROADCASTS_FILTERED_COLLECTION:
            self.broadcastsFilteredCollectionViewController = (segue.destination as! BroadcastsFilteredCollectionViewController)
            self.broadcastsFilteredCollectionViewController.channelModel = channelModel

            break
        default:
            break
        }
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonBack) {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func setViewStateNormal() {
        containerBroadcasts.isHidden = false
        activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateLoading() {
        containerBroadcasts.isHidden = true
        activityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    func performRequestChannelBroadcasts() {
        setViewStateLoading()
        
        // params
        let channelId = channelModel.getId()

        let channelBroadcastsRequest = ChannelBroadcastsRequest(notificationViewController, channelId)

        channelBroadcastsRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleChannelBroadcastsResponse(data)
        }

        channelBroadcastsRequest.execute()
    }

    func handleChannelBroadcastsResponse(_ data: [String: Any]) {
        let broadcastsJsonArray = data[ChannelBroadcastsRequest.RESPONSE_PARAM_BROADCASTS] as! [[String: Any]]
        let broadcasts = BroadcastsHelper.getBroadcastsListFromJsonArray(broadcastsJsonArray)

        broadcastsFilteredCollectionViewController.updateDataset(broadcasts)

        setViewStateNormal()
    }
}

