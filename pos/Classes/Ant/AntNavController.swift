//
//  LeomanNavController.swift
//  MoFan
//
//  Created by luan on 2016/12/8.
//  Copyright © 2016年 luan. All rights reserved.
//

import UIKit

class AntNavController: UINavigationController,UINavigationControllerDelegate,UIGestureRecognizerDelegate {
    
    var navBackground : UIView?
    var lineImageView : UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        checkNavBackground()
        if responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            interactivePopGestureRecognizer?.delegate = self
            delegate = self
        }
        // Do any additional setup after loading the view.
    }
    
    func checkNavBackground() {
        for view : UIView in self.navigationBar.subviews {
            if #available(iOS 10, *) {
                if NSStringFromClass(view.classForCoder) == "_UIBarBackground" {
                    navBackground = view
                }
            } else {
                if NSStringFromClass(view.classForCoder) == "_UINavigationBarBackground" {
                    navBackground = view
                }
            }
        }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        super.pushViewController(viewController, animated: animated)
        if viewControllers.count > 1 {
            checkItem(viewController)
        }
    }

    func checkItem(_ viewController: UIViewController) {
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named :"nav_back")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(backSuperiorController))
    }
    
    func backSuperiorController() {
        popViewController(animated: true)
    }
    
    //MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    //MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
