//
//  SearchViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    static var TAG = String(describing: SearchViewController.classForCoder())

    static var needsScrollReset = false
    static let EVENT_SCROLL_TO_TOP_SEARCH = "EVENT_SCROLL_TO_TOP_SEARCH"

    @IBOutlet weak var mainScrollView: UIScrollViewTouchable!
    @IBOutlet weak var wrapperContent: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerSearchByCategoriesCompact: UIView!
    @IBOutlet weak var containerBroadcastsByCategoriesCompact: UIView!
    @IBOutlet weak var buttonLoadMore: UIButtonLoadMore!
    @IBOutlet weak var containerChannels: UIView!
    @IBOutlet weak var buttonAllBroadcasts: UIButtonOctonary!
    @IBOutlet weak var buttonAllCategoriesLatin: UIButtonBase!
    @IBOutlet weak var buttonAllCategoriesCyrillic: UIButtonBase!
    @IBOutlet weak var mySearchBar: UISearchBar!
    @IBOutlet weak var textTitle: UILabelH1!
    @IBOutlet weak var textCategories: UILabelH4!
    @IBOutlet weak var textChannels: UILabelH4!
    @IBOutlet weak var searchResultsHeightConstttraint: NSLayoutConstraint!

    weak var episodesCollectionViewController: EpisodesCollectionViewController!
    weak var broadcastsBySearchCompactCollectionViewController: BroadcastsBySearchCompactCollectionViewController!
    weak var broadcastsByCategoriesCompactCollectionViewController: BroadcastsByCategoriesCompactCollectionViewController!
    weak var channelsCollectionViewController: ChannelsCollectionViewController!
    weak var notificationViewController: NotificationViewController!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var fullDataset: [BroadcastsByCategoryModel]!
    var fullHitDataset: [EpisodeModel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(SearchViewController.TAG, "viewDidLoad")
        mySearchBar.delegate = self
        // listeners
        buttonLoadMore.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonAllBroadcasts.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonAllCategoriesLatin.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonAllCategoriesLatin.titleLabel?.textColor = UIColor(named: ColorsHelper.BLACK)
        buttonAllCategoriesCyrillic.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        // UI
        buttonAllCategoriesLatin.setText("A - Z", false)
        buttonAllCategoriesCyrillic.setText("A - Я", false)

        let barButtonAppearanceInSearchBar: UIBarButtonItem?
            barButtonAppearanceInSearchBar = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
            barButtonAppearanceInSearchBar?.image = UIImage(named: "Home.png")?.withRenderingMode(.alwaysTemplate)
            barButtonAppearanceInSearchBar?.tintColor = UIColor.white
            barButtonAppearanceInSearchBar?.title = nil
        
        performRequestBroadcastByCategory()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        let customFont = UIFont(name: "FuturaPT-Book", size: 22.0)
        textTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 22.0))
        textTitle.adjustsFontForContentSizeCategory = true
        textCategories.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 22.0))
        textCategories.adjustsFontForContentSizeCategory = true
        textChannels.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 10.0))
        textChannels.adjustsFontForContentSizeCategory = true

        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTheTop), name: Notification.Name(SearchViewController.EVENT_SCROLL_TO_TOP_SEARCH), object: nil)
    }

    @objc func scrollToTheTop() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.mainScrollView.setContentOffset(.zero, animated: false)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_SEARCH_COLLECTION:
//            self.broadcastsBySearchCompactCollectionViewController = (segue.destination as! BroadcastsBySearchCompactCollectionViewController)

            self.episodesCollectionViewController = (segue.destination as! EpisodesCollectionViewController)
//            self.episodesCollectionViewController.scrollDelegate = self
//            self.episodesCollectionViewController.episodesCollectionLoadMoreDelegate = self
//            self.episodesCollectionViewController.isLoadMoreEnabled = true
//            self.episodesCollectionViewController.collectionView.scrollsToTop = true

            break
        case StoryboardsHelper.SEGUE_EMBED_BROADCASTS_BY_CATEGORIES_COMPACT_COLLECTION:
            self.broadcastsByCategoriesCompactCollectionViewController = (segue.destination as! BroadcastsByCategoriesCompactCollectionViewController)

            break
        case StoryboardsHelper.SEGUE_EMBED_CHANNELS_COLLECTION:
            self.channelsCollectionViewController = (segue.destination as! ChannelsCollectionViewController)
            
            let dataset = ChannelsManager.getChannels()
            self.channelsCollectionViewController.updateDataset(dataset)

            break
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset scrolls.
        if (SearchViewController.needsScrollReset) {
            SearchViewController.needsScrollReset = false
            
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                self?.mainScrollView.setContentOffset(.zero, animated: false)
            }
        }
    }
    
    deinit {
        GeneralUtils.log(SearchViewController.TAG, "deinit")
        
        SearchViewController.needsScrollReset = false
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonLoadMore) {
            broadcastsByCategoriesCompactCollectionViewController.originalDataset = fullDataset
            broadcastsByCategoriesCompactCollectionViewController.updateDataset(fullDataset)
            
            buttonLoadMore.setVisibility(UIView.VISIBILITY_GONE)
        }
        if (sender == buttonAllBroadcasts) {
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_ALL_BROADCASTS, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_ALL_BROADCASTS) as! AllBroadcastsViewController)

            navigationController?.pushViewController(viewController, animated: true)
        }
        if (sender == buttonAllCategoriesLatin) {
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_ALL_BROADCASTS, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_ALL_BROADCASTS) as! AllBroadcastsViewController)

            navigationController?.pushViewController(viewController, animated: true)
        }
        if (sender == buttonAllCategoriesCyrillic) {
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_ALL_BROADCASTS, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_ALL_BROADCASTS) as! AllBroadcastsViewController)

            viewController.initialTabIndex = AllBroadcastsPageViewController.PAGE_INDEX_CYRILLIC
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func setViewStateNormal() {
        wrapperContent.setVisibility(UIView.VISIBILITY_VISIBLE)
        activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }
    
    func setViewStateBLoading() {
        wrapperContent.setVisibility(UIView.VISIBILITY_GONE)
        activityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }

    func performRequestBroadcastByCategory() {
        setViewStateBLoading()
        
        let broadcastByCategoryRequest = BroadcastByCategoryRequest(appDelegate.dashboardContainerViewController!.notificationViewController)

        broadcastByCategoryRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleBroadcastsByCategoryResponse(data)
        }

        broadcastByCategoryRequest.execute()
    }
    
    func handleBroadcastsByCategoryResponse(_ data: [String: Any]) {
        var dataset = [BroadcastsByCategoryModel]()

        let categories = data[BroadcastByCategoryRequest.RESPONSE_PARAM_CATEGORIES] as! [[String: Any]]
        print("SearchViewController handleBroadcastsByCategoryResponse categories = \(categories)")
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
            
            fullDataset = [BroadcastsByCategoryModel]()
            fullDataset.append(contentsOf: dataset)

            // initially, show only first 5 categories
            var initialDataset = [BroadcastsByCategoryModel]()
            for i in (0..<dataset.count) {
                if (i < 5) {
                    initialDataset.append(dataset[i])
                }
            }
            
            broadcastsByCategoriesCompactCollectionViewController.originalDataset = initialDataset
            broadcastsByCategoriesCompactCollectionViewController.updateDataset(initialDataset)
        }
        
        setViewStateNormal()
    }

    func handleSearchResponse(_ data: [String: Any], _ data1: Data) {
        var dataset = [EpisodeModel]()
        do {
            let someDictionaryFromJSON = try JSONSerialization.jsonObject(with: data1, options: .allowFragments) as! [String: Any]
            print("SearchViewController handleSearchResponse someDictionaryFromJSON = \(someDictionaryFromJSON)")
//            let json4Swift_Base = try SearchSuccess(someDictionaryFromJSON)
            if let err = someDictionaryFromJSON["error"] as? Int,
               err == 0 {
                if let d = someDictionaryFromJSON["data"] as? [String: Any] {
                    if let items = d["items"] as? [[String: Any]] {
                        let episodes = EpisodesHelper.getEpisodesSearchListFromJsonArray(items)
                        if (episodes.count > 0) {
                            for i in (0..<(episodes.count)) {
                                if let hit = episodes[i] as? EpisodeModel {
                                    dataset.append(hit)
                                }
                            }
                        }
//                        for el in items {
//                            if el["id"] != nil &&  el["title"] != nil  {
//                                var episodeModel: EpisodeModel? = nil
//                                let id = el["id"]
//                                let title = el["title"]
//                                let aired: Int64 = el["aired"] as! Int64
//                                let published: Int64 = el["published"] as! Int64
//                                let url = el["url"]
//                                var strHtml = ""
//                                if let leadHtml = el["lead"] {
//                                    strHtml = (leadHtml as AnyObject).debugDescription.replacingOccurrences(of: "<[^>]+>", with: "")
//                                }
//                                var imageUrl = ""
//                                if let images = el["images"] as? Dictionary<String,String> ,
//                                   let imLarge = images["large"] {
//                                    imageUrl = imLarge
//                                }
//                                var categoryTitle = "Unknown Category"
//                                if let category = el["category"] as? Dictionary<String,Any>,
//                                   let ktit = category["title"] as? String {
//                                    categoryTitle = ktit
//                                }
//                                var audioStreamUrl = ""
//                                var downloadUrl = ""
//                                var durationInSeconds = 0
//                                if let media = el["media"]  as? [String: Any] {
//                                    if let audio = media["audio"] as? [Any]  {
//                                        if audio.count > 0 {
//                                            if let fAudio = audio[0] as? [String: Any] {
//                                                if let audioData = fAudio["data"] as? [String: Any] {
//                                                    if let audioDataLinks = audioData["links"] as? [String: Any] {
//                                                        if let audioDataLinksMP3 = audioDataLinks["mp3"] as? [String: Any] {
//                                                            if let html5 = audioDataLinksMP3["html5"] as? String {
//                                                                audioStreamUrl = html5
//                                                            }
//                                                            if let download = audioDataLinksMP3["download"] as? String {
//                                                                downloadUrl = download
//                                                            }
//                                                        }
//                                                    }
//                                                }
//                                                if let duration = fAudio["duration"] as? Int  {
//                                                    durationInSeconds = duration
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                                var dateInMillis = aired > 0 ? aired * 1000 : published * 1000
//                        }
//                    }
                }

            }
            let jsonDecoder = JSONDecoder()
                let json4Swift_Base = try jsonDecoder.decode(SearchSuccess.self, from: data1)
////            let json4Swift_Base = try jsonDecoder.decode(SearchResult.self, from: data1)
//
                let hits = json4Swift_Base.hits
//            let hits = json4Swift_Base.data?.items
            //        let hits = data[SearchRequest.RESPONSE_PARAM_HITS] as! [[String: Any]]
            print("SearchViewController handleSearchResponse hits = \(hits)")
//            if (hits?.count ?? 0 > 0) {
//                for i in (0..<(hits?.count ?? 0)) {
//                    if let hit = hits?[i] {
//
//                        //                let id = hit[BroadcastByCategoryRequest.RESPONSE_PARAM_ID] as! String
//                        //                let name = hit[BroadcastByCategoryRequest.RESPONSE_PARAM_TITLE] as! String
//                        //                let broadcasts = hit[BroadcastByCategoryRequest.RESPONSE_PARAM_BROADCASTS] as! [NSDictionary]
//                        //
//                        //                let broadcastsByCategoryModel = BroadcastsByCategoryModel(String(id), name)
//                        //                broadcastsByCategoryModel.setBroadcasts(broadcasts)
//                        //
//                        //                dataset.append(broadcastsByCategoryModel)
//                        dataset.append(hit)
//                    }
//                }

                fullHitDataset = [EpisodeModel]()
                fullHitDataset.append(contentsOf: dataset)

                // initially, show only first 5 categories
                var initialDataset = [EpisodeModel]()
                for i in (0..<dataset.count) {
                    if (i < 5) {
                        initialDataset.append(dataset[i])
                    }
                }
                if initialDataset.count > 0 {
                    searchResultsHeightConstttraint.constant = 350
                } else {
                    searchResultsHeightConstttraint.constant = 10
                }
                episodesCollectionViewController.updateDataset(initialDataset)

//                broadcastsBySearchCompactCollectionViewController.originalDataset = initialDataset
//                broadcastsBySearchCompactCollectionViewController.updateDataset(initialDataset)
            }

            setViewStateNormal()
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

        /*
         var dataset = [Item]()
         var searchSuccess = SearchSuccess()

         print("SearchViewController handleSearchResponse data = \(data)")
         //        do {
         //            let responseJson = try JSONSerialization.jsonObject(with: data, options: [])
         //let searchSuccess = try? JSONDecoder().decode(SearchSuccess.self, from: data)

         //            print("searchSuccess = \(String(describing: searchSuccess))")
         dataset = data["hits"] //?? [Item]()
         if (dataset.count > 0) {

         fullHitDataset = [Item]()
         fullHitDataset.append(contentsOf: dataset)

         // initially, show only first 5 categories
         var initialDataset = [Item]()
         for i in (0..<dataset.count) {
         if (i < 5) {
         print("dataset[\(i)] = \(dataset[i])")
         initialDataset.append(dataset[i])
         }
         }

         broadcastsBySearchCompactCollectionViewController.updateDataset(initialDataset)
         broadcastsBySearchCompactCollectionViewController.originalDataset = initialDataset
         }

         setViewStateNormal()

         //        } catch let error as NSError {
         //            print("Error: \(error.domain)")
         //
         //        }
         */
    }

    func searchStart(searchString: String) {

        let urlQueryItems = [
//            URLQueryItem(name: "q", value: searchString),
//            URLQueryItem(name: "query_by", value: "show_name,episode_title,authors,description,categories"),
//            URLQueryItem(name: "x-typesense-api-key", value: Configuration.X_TYPESENSE_API_KEY)
            URLQueryItem(name: "module", value: "articles"),
            URLQueryItem(name: "method", value: "list"),
            URLQueryItem(name: "apikey", value: Configuration.API_KEY),
//            URLQueryItem(name: "data", value: "data=%7B%22search%22%3A%22\(searchString)%22%7D")
//            URLQueryItem(name: "data", value: "{“search”:”\(searchString)")
            URLQueryItem(name: "data", value: "{\"search\":\"" + searchString + "\"}")
            //{“search”:”aigars”}
        ]
        let searchRequest = SearchRequest(urlQueryItems)
        searchRequest.successCallback = { [weak self] (data, data1) -> Void in
            print("SearchRequest data = \(data),  data1 = \(data1)")
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
//                if let jsonString = String(data: jsonData, encoding: .utf8) {
//                    print("searchStart SearchRequest jsonString = \(jsonString)")
//                    let searchSuccess = try SearchSuccess(jsonString, using: .utf8)
//                    print("searchStart searchSuccess = \(String(describing: searchSuccess))")
                    self?.handleSearchResponse(data, data1)
//                }

//            } catch {
//                GeneralUtils.log(SearchViewController.TAG, error.localizedDescription)
//            }
        }
        searchRequest.errorCallback = { [weak self] in
            print("searchRequest.errorCallback")
        }
        searchRequest.execute()
    }

//}

//extension SearchViewController {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        mySearchBar.resignFirstResponder()
        dismissKeyboard()
    }

//    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(false, animated: true)
//    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        mySearchBar.resignFirstResponder()
        dismissKeyboard()
        searchStart(searchString: searchBar.text ?? "")
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        mySearchBar.resignFirstResponder()
        dismissKeyboard()
    }

}

