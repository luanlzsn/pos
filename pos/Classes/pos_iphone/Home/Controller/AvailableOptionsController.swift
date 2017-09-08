//
//  AvailableOptionsController.swift
//  pos
//
//  Created by luan on 2017/9/8.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class AvailableOptionsController: AntController,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var optionArray = [OptionModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissClick(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func sectionClick(button: UIButton) {
        let optionModel = optionArray[button.tag]
        optionModel.isSelect = !optionModel.isSelect
        tableView.reloadData()
    }
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.className() == "UITableViewCellContentView" {
            return false
        }
        return true
    }
    
    // MARK: - UITableViewDelegate,UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return optionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let optionModel = optionArray[section]
        return optionModel.isSelect ? optionArray[section].option_value.count : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
        headerView.backgroundColor = UIColor.white
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 20, y: 0, width: kScreenWidth - 70, height: 40)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(sectionClick(button:)), for: .touchUpInside)
        button.tag = section
        
        headerView.addSubview(button)
        let optionModel = optionArray[section]
        button.setTitle(optionModel.name, for: .normal)
        
        let arrow = UIImageView(image: UIImage(named: "right_arrow"))
        arrow.transform = CGAffineTransform.init(rotationAngle: CGFloat(optionModel.isSelect ? Float.pi / 2 : -Float.pi / 2))
        arrow.centerY = headerView.centerY
        arrow.left = kScreenWidth - 20 - #imageLiteral(resourceName: "right_arrow").size.width
        headerView.addSubview(arrow)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AvailableOptionsCell = tableView.dequeueReusableCell(withIdentifier: "AvailableOptionsCell", for: indexPath) as! AvailableOptionsCell
        let optionModel = optionArray[indexPath.section]
        let optionValue = optionModel.option_value[indexPath.row ]
        cell.optionName.text = optionValue.name
        cell.selectBtn.isSelected = optionValue.isSelect
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let optionModel = optionArray[indexPath.section]
        let optionValue = optionModel.option_value[indexPath.row]
        optionValue.isSelect = !optionValue.isSelect
        tableView.reloadData()
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
