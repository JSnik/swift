//
//  LivestreamsViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class LivestreamsViewController: UIViewController {
    
    static var TAG = String(describing: LivestreamsViewController.classForCoder())

    static let EVENT_SCROLL_TO_TOP_LIVESTREAMS = "EVENT_SCROLL_TO_TOP_LIVESTREAMS"

    static var needsScrollReset = false


    var radioChannelDataset: [RadioChannel] = []

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var mainScrollView: UIScrollViewTouchable!
    @IBOutlet weak var textTitle: UILabelH1!
    @IBOutlet weak var textLivestreamsInternetChannels: UILabelH3!
    

    weak var livestreamsClassicCollectionViewController: LivestreamsCollectionViewController!
    weak var livestreamsInternetChannelsCollectionViewController: LivestreamsCollectionViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(LivestreamsViewController.TAG, "viewDidLoad")
        
//        populateCollectionViewLivestreamsClassic()
        performRequestGetRadioChannels()

//        populateCollectionViewLivestreamsInternetChannels()
        let customFont1 = UIFont(name: "FuturaPT-Book", size: 22.0)
        textTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 22.0))
        textTitle.adjustsFontForContentSizeCategory = true
        textLivestreamsInternetChannels.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 10.0))
        textLivestreamsInternetChannels.adjustsFontForContentSizeCategory = true
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTheTop), name: Notification.Name(LivestreamsViewController.EVENT_SCROLL_TO_TOP_LIVESTREAMS), object: nil)

    }

    @objc func scrollToTheTop() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.mainScrollView.setContentOffset(.zero, animated: false)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_LIVESTREAMS_CLASSIC_COLLECTION:
            self.livestreamsClassicCollectionViewController = (segue.destination as! LivestreamsCollectionViewController)
            
            break
        case StoryboardsHelper.SEGUE_EMBED_LIVESTREAMS_INTERNET_CHANNELS_COLLECTION:
            self.livestreamsInternetChannelsCollectionViewController = (segue.destination as! LivestreamsCollectionViewController)
            
            break
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Reset scrolls.
        if (LivestreamsViewController.needsScrollReset) {
            LivestreamsViewController.needsScrollReset = false
            
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                self?.mainScrollView.setContentOffset(.zero, animated: false)
            }
        }
    }
    
    deinit {
        GeneralUtils.log(LivestreamsViewController.TAG, "deinit")
        
        LivestreamsViewController.needsScrollReset = false
    }
    
    func populateCollectionViewLivestreamsClassic() {
//        livestreamsClassicCollectionViewController.updateDataset(LivestreamsManager.getLivestreamsClassic())
//        
//        livestreamsClassicCollectionViewController.updateTitles()
    }


    func performRequestGetRadioChannels() {
        let channelId = ""
                let channelRadioRequest = ChannelRadioRequest(appDelegate.dashboardContainerViewController!.notificationViewController, channelId)


        channelRadioRequest.successCallback = { [weak self] (data, data1) -> Void in
            print("channelRadioRequest data = \(data),  data1 = \(data1)")
                    self?.handleRadioChannelsResponse(data, data1)
                }
        channelRadioRequest.errorCallback = { [weak self] in
            print("channelRadioRequest.errorCallback")
        }

        channelRadioRequest.execute()
    }

    func handleRadioChannelsResponse(_ data: [String: Any], _ data1: Data) {

        var dataset = [RadioChannel]()
        do {
            let someDictionaryFromJSON = try JSONSerialization.jsonObject(with: data1, options: .allowFragments) as! [String: Any]
            print("LivestreamsViewController handleRadioChannelsResponse someDictionaryFromJSON = \(someDictionaryFromJSON)")
//            let json4Swift_Base = try SearchSuccess(someDictionaryFromJSON)
            let jsonDecoder = JSONDecoder()
            let json4Swift_Base = try jsonDecoder.decode(ChannelsSuccess.self, from: data1)

            let radioChannels = json4Swift_Base.results
            //        let hits = data[SearchRequest.RESPONSE_PARAM_HITS] as! [[String: Any]]
            print("LivestreamsViewController handleRadioChannelsResponse radioChannels = \(radioChannels)")
            if (radioChannels?.count ?? 0 > 0) {
                for i in (0..<(radioChannels?.count ?? 0)) {
                    if let radioChannel = radioChannels?[i] {
                        dataset.append(radioChannel)
                    }
                }

                var fullRadioChannelDataset: [RadioChannel]!
                fullRadioChannelDataset = [RadioChannel]()
                fullRadioChannelDataset.append(contentsOf: dataset)

                let usersManager = UsersManager.getInstance()
                if let currentUser = usersManager.getCurrentUser() {
//                    let orderedLivestreamsDataset = LivestreamsManager.getOrderedList(currentUser)
//
//                    let curatedLivestreamsDataset = LivestreamsManager.getCuratedList(orderedLivestreamsDataset, isChristmasLivestreamCampaignEnabled)
                    radioChannelDataset = fullRadioChannelDataset
                    livestreamsClassicCollectionViewController.updateDataset(fullRadioChannelDataset)
                }
            }
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            fatalError("Failed to decode due to type mismatch '\(type)' – \(context.codingPath) - \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode: \(error.localizedDescription)")
        }
    }



    func populateCollectionViewLivestreamsInternetChannels() {
        var finalLivestreamsDataset = radioChannelDataset //LivestreamsManager.getLivestreamsInternetChannels()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let dashboardContainerViewController = appDelegate.dashboardContainerViewController {
            if let mainPageViewController = dashboardContainerViewController.mainPageViewController {
                if let dashboardViewController = mainPageViewController.orderedViewControllers[NavigationViewController.NAVIGATION_ITEM_INDEX_DASHBOARD] as? DashboardViewController {
                    finalLivestreamsDataset = LivestreamsManager.getCuratedList(finalLivestreamsDataset, dashboardViewController.isChristmasLivestreamCampaignEnabled)
                }
            }
        }
        
        livestreamsInternetChannelsCollectionViewController.updateDataset(finalLivestreamsDataset)
    }
}

