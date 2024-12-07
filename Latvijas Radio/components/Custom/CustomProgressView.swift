//
//  CustomProgressView.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class CustomProgressView: UIView {

    var progress: Float = 0 {
        didSet {
            updateProgressView()
        }
    }
    
    @IBInspectable var barColor: UIColor = UIColor(named: ColorsHelper.BLACK)! {
        didSet {
            updateBarColor()
        }
    }

    private let progressView = UIView()

    // initialised from Interface Builder
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    // initialised from code
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
        
    // MARK: Custom
    
    func commonInit() {
        clipsToBounds = true
        
        updateBarColor()

        addSubview(progressView)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateProgressView()
    }

    func updateProgressView() {
        let totalPossibleWidth = Float(bounds.width)
        let onePercentOfTotalPossibleWidth = totalPossibleWidth / 100
        let newProgressWidth = onePercentOfTotalPossibleWidth * progress * 100

        progressView.frame.size.width = CGFloat(newProgressWidth)
    }
    
    func updateBarColor() {
        progressView.backgroundColor = barColor
    }
}
