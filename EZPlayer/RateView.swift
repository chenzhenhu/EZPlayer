//
//  RateView.swift
//  EZPlayer
//
//  Created by John on 2018/9/14.
//  Copyright © 2018年 yangjun zhu. All rights reserved.
//

import UIKit

public protocol RateViewDelegate: class {
    func rateSelected(rate: Float)
}

private let cellId: String = "RateViewCell"

class RateView: UIView {
    
    open weak var delegate: RateViewDelegate?
    
    fileprivate var data:[[String: Any]] = [["title": "1.0X", "rate": 1],["title": "1.25X","rate": 1.25],["title":"1.5X", "rate": 1.5],["title":"2.0X","rate": 2]]

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.isScrollEnabled = false
        tableView.bounces = false
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "RateViewCell", bundle: Bundle(for: RateView.self)), forCellReuseIdentifier: cellId)
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}

extension RateView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! RateViewCell
        cell.title = data[indexPath.row]["title"] as? String ?? "1.0X"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rate = data[indexPath.row]
        self.delegate?.rateSelected(rate: rate["rate"] as? Float ?? 1)
    }
}
