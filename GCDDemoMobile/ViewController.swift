//
//  ViewController.swift
//  GCDDemoMobile
//
//  Created by roger.wang[王濬淇] on 2019/12/30.
//  Copyright © 2019 roger.wang[王濬淇]. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var imgView1: UIImageView!
    @IBOutlet weak var imgView2: UIImageView!
    @IBOutlet weak var imgView3: UIImageView!
    @IBOutlet weak var cancelTaskButton: UIButton!
    
    var targetWorkItem: DispatchWorkItem?
    let gcdDetail = GCDDetail()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func check(_ sender: Any) {
//        print("check")
//        gcdDetail.run()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "GCDDetailViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func tapR2C1(_ sender: Any) {
        simpleSerialQueueTask()
    }
    
    @IBAction func tapR2C2(_ sender: Any) {
        simpleConcurrentQueueTask()
    }
    
    @IBAction func tapSerial(_ sender: Any) {
        clearImages()
        serialQueue()
        //        serialQueueWithWorkItem()
    }
    
    @IBAction func tapConcurent(_ sender: Any) {
        clearImages()
        concurrent()
    }
    
    @IBAction func cancelTask(_ sender: Any) {
        guard let wi = targetWorkItem else {
            return
        }
        print(wi)
        if wi.isCancelled == false {
            wi.cancel()
        }
    }
    //MARK: sync task
    
    //MARK: - simple task
    func simpleSerialQueueTask() {
        let group: DispatchGroup = DispatchGroup()
        let queue = DispatchQueue(label: "queue1") // default is serial FIFO
        queue.async(group: group) {
            Tools.printCurrentThread(with: "queue1: Task 1")
            for i in 1 ... 5 {
                print("i: \(i)")
            }
        }
        
        queue.async(group: group) {
            Tools.printCurrentThread(with: "queue1: Task 2")
            for j in 6 ... 10 {
                print("j: \(j)")
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            print("處理完成...")
        }
    }
    
    func simpleConcurrentQueueTask() {
        let group: DispatchGroup = DispatchGroup()
        
        let queue = DispatchQueue(label: "queue1", attributes: .concurrent)
        
        queue.async(group: group) {
            Tools.printCurrentThread(with: "queue1: Task 1")
            for i in 1 ... 5 {
                print("i: \(i)")
            }
        }
        
        queue.async(group: group) {
            Tools.printCurrentThread(with: "queue1: Task 2")
            for j in 6 ... 10 {
                print("j: \(j)")
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            // 已處理完事件A和事件B
            print("處理完成...")
        }
    }
    
    // MARK: - complex task
    /// <#Description#>
    func serialQueue() {
        let url = URL(string: "https://cdn.arstechnica.net/wp-content/uploads/2018/06/macOS-Mojave-Dynamic-Wallpaper-transition.jpg")!
        let serialQueue = DispatchQueue(label: "serialQueue")
        let group = DispatchGroup()
        serialQueue.async {
            group.enter()
            Tools.printCurrentThread(with: "---task 1 start---")
            self.downloaded(from: url) { (image) in
                //                Tools.printCurrentThread(with: "downloaded task")
                DispatchQueue.main.async {
                    self.imgView1.image = image
                }
                Tools.printCurrentThread(with: "---task 1 end---")
                group.leave()
            }
            group.wait()
            group.enter()
            Tools.printCurrentThread(with: "---task 2 start---")
            self.downloaded(from: url) { (image) in
                DispatchQueue.main.async {
                    self.imgView2.image = image
                }
                Tools.printCurrentThread(with: "---task 2 end---")
                group.leave()
            }
            group.wait()
            group.enter()
            Tools.printCurrentThread(with: "---task 3 start---")
            self.downloaded(from: url) { (image) in
                DispatchQueue.main.async {
                    self.imgView3.image = image
                }
                Tools.printCurrentThread(with: "---task 3 end---")
                group.leave()
            }
            print("all finished!!!")
        }
        
        
    }
    
    
    
    func concurrent() {
        let url = URL(string: "https://cdn.arstechnica.net/wp-content/uploads/2018/06/macOS-Mojave-Dynamic-Wallpaper-transition.jpg")!
        let group = DispatchGroup()
        group.enter()
        
        print("task 1 start...")
        self.downloaded(from: url) { (image) in
            Tools.printCurrentThread(with: "---task 1 start---")
            DispatchQueue.main.async {
                self.imgView1.image = image
            }
            print("task 1 end...")
            group.leave()
            
        }

        group.enter()
        print("task 2 start...")
        self.downloaded(from: url) { (image) in
            Tools.printCurrentThread(with: "---task 2 start---")
            DispatchQueue.main.async {
                self.imgView2.image = image
            }
            print("task 2 end...")
            group.leave()
        }
        
        group.enter()
        print("task 3 start...")
        self.downloaded(from: url) { (image) in
            Tools.printCurrentThread(with: "---task 3 start---")
            DispatchQueue.main.async {
                self.imgView3.image = image
            }
            print("task 3 end...")
            group.leave()
        }
        
        group.notify(queue: .main) {
            print("all finished!!! ")
        }
    }
    
    func serialQueueWithWorkItem() {
        
        let serialQueue = DispatchQueue(label: "serialQueue")
        let group = DispatchGroup()
        group.enter()
        let t1 = DispatchWorkItem { [weak self] in
            print("t1 start...")
            
            self?.downloaded(from: URL(string: "https://i.picsum.photos/id/1011/5472/3648.jpg")!) { (image) in
                DispatchQueue.main.async {
                    self?.imgView1.image = image
                }
                print("t1 end...")
                group.leave()
            }
        }
        
        let t2 = DispatchWorkItem { [weak self] in
            group.wait()
            group.enter()
            print("t2 start...")
            
            self?.downloaded(from: URL(string: "https://i.picsum.photos/id/1014/6016/4000.jpg")!) { (image) in
                DispatchQueue.main.async {
                    self?.imgView2.image = image
                }
                print("t2 end...")
                group.leave()
            }
        }
        
        let t3 = DispatchWorkItem { [weak self] in
            group.wait()
            group.enter()
            print("t3 start...")
            
            self?.downloaded(from: URL(string: "https://i.picsum.photos/id/1027/2848/4272.jpg")!) { (image) in
                DispatchQueue.main.async {
                    self?.imgView3.image = image
                }
                print("t3 end...")
                group.leave()
            }
        }
        serialQueue.async(execute: t1)
        serialQueue.async(execute: t2)
        serialQueue.async(execute: t3)
        targetWorkItem = t3
        
        
    }
    
    
    
    
    func clearImages() {
        imgView1.image = nil
        imgView2.image = nil
        imgView3.image = nil
    }
    
    func downloaded(from url: URL,
                    contentMode mode: UIView.ContentMode = .scaleAspectFit,
                    group: DispatchGroup,
                    complete: @escaping (UIImage?) -> ()) {
        print("start")
        group.enter()
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    complete(nil)
                    return
            }
            complete(image)
            
        }.resume()
        
        //        sleep(1)
        //        complete(nil)
    }
    
    func downloaded(from url: URL,
                    contentMode mode: UIView.ContentMode = .scaleAspectFit,
                    complete: @escaping (UIImage?) -> ()) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    complete(nil)
                    return
            }
            complete(image)
            
        }.resume()
        
        //        sleep(1)
        //        complete(nil)
    }
}

