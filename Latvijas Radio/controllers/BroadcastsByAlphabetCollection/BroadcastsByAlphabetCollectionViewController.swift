//
//  BroadcastsByAlphabetCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastsByAlphabetCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: BroadcastsByAlphabetCollectionViewController.classForCoder())

    private let reuseIdentifier = "BroadcastsByAlphabetCollectionViewCell"
    private var dataset: [BroadcastsByAlphabetModel] = [BroadcastsByAlphabetModel]()
    var broadcasts: [BroadcastModel] = [BroadcastModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(BroadcastsByAlphabetCollectionViewController.TAG, "viewDidLoad")

        // insert symbol separator items
        var datasetByAlphabet = [BroadcastsByAlphabetModel]()
        
        var lastSymbol = ""
        
        for i in (0..<broadcasts.count) {
            let broadcastModel = broadcasts[i]
            let title = broadcastModel.getTitle()
            let firstChar = String(title.prefix(1))
            let c = firstChar.first!

            var broadcastsByAlphabetModel: BroadcastsByAlphabetModel!
            
            var itemContainsSymbolSeparator = false
            
            if (c.isLetter) {
                if (firstChar != lastSymbol) {
                    lastSymbol = firstChar
                    
                    itemContainsSymbolSeparator = true
                }
            }
            
            if (itemContainsSymbolSeparator) {
                broadcastsByAlphabetModel = BroadcastsByAlphabetModel(BroadcastsByAlphabetModel.TYPE_SYMBOL, firstChar.uppercased(), nil)
                
                datasetByAlphabet.append(broadcastsByAlphabetModel)
            }
            
            broadcastsByAlphabetModel = BroadcastsByAlphabetModel(BroadcastsByAlphabetModel.TYPE_BROADCAST, nil, broadcastModel)
            
            datasetByAlphabet.append(broadcastsByAlphabetModel)
        }
        
        updateDataset(datasetByAlphabet)
        self.collectionView.scrollsToTop = true
    }
    
    deinit {
        GeneralUtils.log(BroadcastsByAlphabetCollectionViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [BroadcastsByAlphabetModel]) {
        GeneralUtils.log(BroadcastsByAlphabetCollectionViewController.TAG, "setupDataset")

        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = UIColor.clear
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView.collectionViewLayout = layout
        
        self.dataset = dataset

        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    @objc func buttonBroadcastNameClickHandler(_ sender: UIView) {
        let broadcastsByAlphabetModel = dataset[sender.tag]

        let broadcastModel = broadcastsByAlphabetModel.getBroadcast()
        
        let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCAST, bundle: nil)
                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCAST) as! BroadcastViewController)
        
        viewController.broadcastModel = broadcastModel
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension BroadcastsByAlphabetCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BroadcastsByAlphabetCollectionViewCell

        // variables
        let broadcastsByAlphabetModel = dataset[indexPath.row]

        // listeners
        cell.buttonBroadcastName.tag = indexPath.row
        cell.buttonBroadcastName.addTarget(self, action: #selector(buttonBroadcastNameClickHandler), for: .touchUpInside)

        // update type
        if (broadcastsByAlphabetModel.getType() == BroadcastsByAlphabetModel.TYPE_SYMBOL) {
            cell.textStartingSymbol.isHidden = false
            cell.buttonBroadcastName.isHidden = true
            
            // update symbol
            let symbol = broadcastsByAlphabetModel.getSymbol()!
            cell.textStartingSymbol.setText(symbol)
        } else {
            cell.textStartingSymbol.isHidden = true
            cell.buttonBroadcastName.isHidden = false
            
            // update title
            let title = broadcastsByAlphabetModel.getBroadcast()!.getTitle()
            cell.buttonBroadcastName.setText(title, false)
        }
        
        return cell
    }
}
