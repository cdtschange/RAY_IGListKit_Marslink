//
//  FeedViewController.swift
//  Marslink
//
//  Created by Mao on 22/12/2016.
//  Copyright © 2016 Ray Wenderlich. All rights reserved.
//

import UIKit
import IGListKit

class FeedViewController: UIViewController {
    
    let loader = JournalEntryLoader()
    
    
    let pathfinder = Pathfinder()
    
    let wxScanner = WxScanner()
    
    // 1
    let collectionView: IGListCollectionView = {
        // 2
        let view = IGListCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        // 3
        view.backgroundColor = UIColor.black
        return view
    }()
    
    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loader.loadLatest()
        
        view.addSubview(collectionView)
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        pathfinder.delegate = self
        pathfinder.connect()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FeedViewController: IGListAdapterDataSource {
    // 1
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        // 1
        var items: [IGListDiffable] = [wxScanner.currentWeather]
        items += loader.entries as [IGListDiffable]
        items += pathfinder.messages as [IGListDiffable]
        // 2
        return items.sorted(by: { (left: Any, right: Any) -> Bool in
            if let left = left as? DateSortable, let right = right as? DateSortable {
                return left.date > right.date
            }
            return false
        })
        
//        return loader.entries
        
//        var items: [IGListDiffable] = pathfinder.messages
//        items += loader.entries as [IGListDiffable]
//        return items
    }
    
    // 2
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        if object is Message {
            return MessageSectionController()
        } else if object is Weather {
            return WeatherSectionController()
        } else {
            return JournalSectionController()
        }
        
//        if object is Message {
//            return MessageSectionController()
//        } else {
//            return JournalSectionController()
//        }
        
//        return JournalSectionController()
//        return IGListSectionController()
    }
    
    // 3
    func emptyView(for listAdapter: IGListAdapter) -> UIView? { return nil }
}

extension FeedViewController: PathfinderDelegate {
    func pathfinderDidUpdateMessages(pathfinder: Pathfinder) {
        adapter.performUpdates(animated: true)
    }
}
