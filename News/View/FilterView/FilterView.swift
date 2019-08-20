//
//  FilterView.swift
//  News
//
//  Created by Chmola Lilia on 8/20/19.
//  Copyright © 2019 Lilia Chmola. All rights reserved.
//

import UIKit

protocol FilterViewDelegate: class {
    func selected(filter: String)
}

class FilterView: UIView {
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var filterPikerView: UIPickerView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var backButton: UIButton!
    weak var delegate: FilterViewDelegate?
    private var selectedFilter = "publishedAt"
    private let dataArray = ["publishedAt", "popularity", "relevancy"]
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        hideWithAnimation()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        delegate?.selected(filter: self.selectedFilter)
        hideWithAnimation()
    }
    
    private func hideWithAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomView.frame.origin.y = self.bottomView.bounds.size.height + UIScreen.main.bounds.size.height
            self.backButton.alpha = 0.0
        }) { (animated) in
            self.removeFromSuperview()
        }
    }
    
    func displayWithAnimation() {
        backButton.alpha = 0.0
        let currentFrameBottomView = bottomView.frame
        bottomView.frame.origin.y = bottomView.bounds.size.height + UIScreen.main.bounds.size.height
        UIView.animate(withDuration: 0.5) {
            self.bottomView.frame = currentFrameBottomView
            self.backButton.alpha = 1.0
        }
    }
    
    // MARK: Init methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("FilterView", owner: self, options: nil)
        containerView.fixInView(self)
    }
}

extension FilterView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFilter = dataArray[row]
    }
}

extension FilterView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataArray[row]
    }
}
