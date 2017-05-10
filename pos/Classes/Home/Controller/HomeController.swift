//
//  HomeController.swift
//  pos
//
//  Created by luan on 2017/5/7.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class HomeController: AntController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !AntManage.isLogin {
            let login = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateInitialViewController()!
            present(login, animated: true, completion: nil)
        }
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