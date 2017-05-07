//
//  SpinnerButton.swift
//  OttCapital
//
//  Created by 陈宇 on 2017/3/31.
//  Copyright © 2017年 OttCapital. All rights reserved.
//

import UIKit

class SpinnerButton: UIButton {

    let cover = UIButton(frame: CGRect.zero)
    var strArray : [String]!
    var action: ((String) -> Void)?
    
    lazy var tableView: UITableView = {
        let tableview = UITableView()
        tableview.layer.cornerRadius = 2.5
        tableview.separatorInset = UIEdgeInsets.zero
        tableview.separatorColor = UIColor(hexString: "c7c7cc")
        return tableview
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        titleLabel?.centerY = self.height / 2;
        titleLabel?.left = 15;
        
        imageView?.centerY = self.height / 2;
        imageView?.right = 15;
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        adjustsImageWhenHighlighted = false
    }

}

extension SpinnerButton {
    
    func show(view: UIView, array: [String], action: @escaping (String) -> Void) {
        if array.isEmpty {
            return
        }
        strArray = array
        self.action = action
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        let rect = self.convert(self.bounds, to: view)
        let contentHeight = tableView.contentSize.height
        let top : CGFloat
        let height : CGFloat
        if rect.maxY + contentHeight > view.height - 20 {
            if rect.maxY > view.height * 0.5 {
                if rect.minY - contentHeight > 20 {
                    top = rect.minY - contentHeight
                    height = contentHeight
                } else {
                    top = 20
                    height = rect.minY - top
                }
            } else {
                top = rect.maxY
                height = view.height - top - 20
            }
        } else {
            top = rect.maxY
            height = contentHeight
        }
        tableView.frame = CGRect(x: rect.origin.x, y: top, width: rect.width, height: 0)
        
        cover.frame = view.bounds
        cover.backgroundColor = UIColor.black
        cover.alpha = 0
        cover.addTarget(self, action: #selector(coverClick(sender:)), for: .touchUpInside)
        
        view.addSubview(cover)
        view.addSubview(tableView)
        
        UIView.animate(withDuration: 0.25) { 
            self.cover.alpha = 0.2
            self.tableView.height = height
        }
    }
    
    func coverClick(sender: UIButton) {
        self.dim(string: nil)
    }
    
    func dim(string: String?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.cover.alpha = 0
            self.tableView.height = 0
        }) { (complete) in
            self.cover.removeFromSuperview()
            self.tableView.removeFromSuperview()
            if let a = self.action, let str = string {
                a(str)
            }
        }
    }
    
}

extension SpinnerButton : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = strArray[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dim(string: strArray[indexPath.row])
    }
}
