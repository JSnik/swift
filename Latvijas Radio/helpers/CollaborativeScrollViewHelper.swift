//
//  CollaborativeScrollViewHelper.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class CollaborativeScrollViewHelper {
    
    static func scrollViewDidScroll(_ currentScrollView: UIScrollView, _ outerScrollView: UIScrollViewCollaborative, _ innerScrollView: UICollectionViewBase) {
        
        if (currentScrollView == outerScrollView) {
            // scrolling outerScrollView
            //print("-----Scrolling outerScrollView: start")

            let innerContentOffsetY = innerScrollView.contentOffset.y.rounded()
            
            if (innerContentOffsetY <= 0) {
                // at top
                currentScrollView.showsVerticalScrollIndicator = true
                innerScrollView.showsVerticalScrollIndicator = false
            } else {
                // Not at the top in innerScrollView, so prevent outerScrollView from scrolling
                
                currentScrollView.contentOffset = outerScrollView.lastContentOffset
                
                currentScrollView.showsVerticalScrollIndicator = false
                innerScrollView.showsVerticalScrollIndicator = true
            }
            
            outerScrollView.lastContentOffset = currentScrollView.contentOffset
            
            //print("-----Scrolling outerScrollView: end")
        }
        
        if (currentScrollView == innerScrollView) {
            // scrolling innerScrollView
            //print("-----Scrolling innerScrollView: start")

            let outerContentOffsetY = outerScrollView.contentOffset.y.rounded()
            let outerContentSizeHeight = outerScrollView.contentSize.height.rounded()
            let outerFrameSizeHeight = outerScrollView.frame.size.height.rounded()
            
            if (outerContentOffsetY >= (outerContentSizeHeight - outerFrameSizeHeight)) {
                // reached bottom
                outerScrollView.showsVerticalScrollIndicator = false
                innerScrollView.showsVerticalScrollIndicator = true

            } else {
                // not at the bottom in outerScrollView, prevent innerScrollView from scrolling
                innerScrollView.contentOffset = innerScrollView.lastContentOffset
                
                outerScrollView.showsVerticalScrollIndicator = true
                innerScrollView.showsVerticalScrollIndicator = false
            }
            
            innerScrollView.lastContentOffset = currentScrollView.contentOffset
            
            //print("-----Scrolling innerScrollView: end")
        }
    }
    
//    // leaving for reference:
//    // get top/middle/bottom positions
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let contentOffsetY = scrollView.contentOffset.y.rounded()
//        let contentSizeHeight = scrollView.contentSize.height.rounded()
//        let frameSizeHeight = scrollView.frame.size.height.rounded()
//
//        if (contentOffsetY >= (contentSizeHeight - frameSizeHeight)) {
//            // reached bottom
//        }
//
//        if (contentOffsetY <= 0) {
//            // reached top
//        }
//
//        if (contentOffsetY > 0 && contentOffsetY < (contentSizeHeight - frameSizeHeight)) {
//            // not top and not bottom
//        }
//    }
    
    // leaving for reference:
    
    //    // https://stackoverflow.com/questions/25793141/continuous-vertical-scrolling-between-uicollectionview-nested-in-uiscrollview?rq=1
    
    //    enum Direction {
    //        case none, left, right, up, down
    //    }
    //
    //
    //    static var mLockOuterScrollView = false
    //

    //
    //    static func scrollViewDidScroll(_ currentScrollView: UIScrollView, _ outerScrollView: UIScrollViewCollaborative, _ innerScrollView: UICollectionViewBase) {
    //
    //        if (currentScrollView == outerScrollView) {
    //            // scrolling outerScrollView
    //            print("---------- outerScroll: start")
    //
    //            //lock outer scrollview if necessary
    //            if CollaborativeScrollViewHelper.mLockOuterScrollView {
    //                outerScrollView.contentOffset = outerScrollView.lastContentOffset
    //            }
    //
    //            outerScrollView.lastContentOffset = currentScrollView.contentOffset
    //
    //            print("---------- outerScroll: end")
    //        }
    //
    //        if (currentScrollView == innerScrollView) {
    //            // scrolling innerScrollView
    //            print("---------- innerScroll: start")
    //
    //            //determine direction of scrolling
    //            var directionTemp: Direction?
    //            if innerScrollView.lastContentOffset.y > innerScrollView.contentOffset.y {
    //                directionTemp = .up
    //            } else if innerScrollView.lastContentOffset.y < innerScrollView.contentOffset.y {
    //                directionTemp = .down
    //            }
    //            guard let direction = directionTemp else {return}
    //
    //            let isAlreadyAllTheWayDown = (innerScrollView.contentOffset.y + innerScrollView.frame.size.height) == innerScrollView.contentSize.height
    //            let isAlreadyAllTheWayUp = innerScrollView.contentOffset.y == 0
    //            if (direction == .down && isAlreadyAllTheWayDown) || (direction == .up && isAlreadyAllTheWayUp) {
    //                CollaborativeScrollViewHelper.mLockOuterScrollView = false
    //            } else {
    //                CollaborativeScrollViewHelper.mLockOuterScrollView = true
    //            }
    //
    //            innerScrollView.lastContentOffset = innerScrollView.contentOffset
    //
    //            print("---------- innerScroll: end")
    //        }
    //    }
        

}
