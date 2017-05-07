//
//  LookPictureVC.swift
//  Traber
//
//  Created by luan on 2017/4/29.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class LookPictureVC: AntController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    var imgArray = [Any]()
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leftBtn.setImage(UIImage(named: "case_left_arrow_green")?.byTintColor(UIColor.white), for: .normal)
        rightBtn.setImage(UIImage(named: "case_right_arrow_green")?.byTintColor(UIColor.white), for: .normal)
        collectionView.contentSize = CGSize(width: kScreenWidth * CGFloat(imgArray.count), height: 0)
        collectionView.setContentOffset(CGPoint(x: kScreenWidth * CGFloat(currentPage), y: 0), animated: true)
        checkArrowStatus()
    }

    @IBAction func leftClick(_ sender: UIButton) {
        currentPage -= 1
        if currentPage < 0 {
            currentPage = 0
        }
        collectionView.setContentOffset(CGPoint(x: kScreenWidth * CGFloat(currentPage), y: 0), animated: true)
        checkArrowStatus()
    }
    
    @IBAction func rightClick(_ sender: UIButton) {
        currentPage += 1
        if currentPage > imgArray.count - 1 {
            currentPage = imgArray.count - 1
        }
        collectionView.setContentOffset(CGPoint(x: kScreenWidth * CGFloat(currentPage), y: 0), animated: true)
        checkArrowStatus()
    }
    
    func checkArrowStatus() {
        leftBtn.isEnabled = (currentPage != 0)
        rightBtn.isEnabled = (currentPage != imgArray.count - 1)
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.size
    }
    
    // MARK: UICollectionViewDelegate,UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : LookPictureCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LookPictureCell", for: indexPath) as! LookPictureCell
        if let array = imgArray as? [String] {
            cell.imgView.sd_setImage(with: URL(string: array[indexPath.row]))
        } else if let array = imgArray as? [UIImage] {
            cell.imgView.image = array[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / kScreenWidth)
        checkArrowStatus()
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
