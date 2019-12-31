//
//  GCDScenario.swift
//  GCDDemo
//
//  Created by roger.wang[王濬淇] on 2019/12/27.
//  Copyright © 2019 roger.wang[王濬淇]. All rights reserved.
//

import Foundation

class GCDScenario {
    func run() {
        print("run scenario... ")
        s5()
    }
    
    /// 建立Serial Queues，並建立同步和同步的block
    ///
    /// sdfsf
    func s1() {
        // 建立Serial Queues，並建立同步和同步的block
        let serialQueue: DispatchQueue = DispatchQueue(label: "serialQueue")
        // 驗證同步執行的結果
        serialQueue.sync {
            for i in 1 ... 10 {
                print("i: \(i)")
            }
        }
        serialQueue.sync {
            for j in 100 ... 109 {
                print("j: \(j)")
            }
        }
    }
    
    /// 非同步佇列的使用方式與驗證非同步執行的結果
    func s2() {
        // 非同步佇列的使用方式與驗證非同步執行的結果
        let concurrentQueue1: DispatchQueue = DispatchQueue(label: "concurrentQueue1", attributes: .concurrent)
        let concurrentQueue2: DispatchQueue = DispatchQueue(label: "concurrentQueue2", attributes: .concurrent)
        let concurrentQueue3: DispatchQueue = DispatchQueue(label: "concurrentQueue3", attributes: .concurrent)

        concurrentQueue1.async {
            for i in 1 ... 10 {
                print("i: \(i)")
            }
        }

        concurrentQueue2.async {
            for j in 100 ... 109 {
                print("j: \(j)")
            }
        }

        concurrentQueue3.async {
            for k in 200 ... 209 {
                print("k: \(k)")
            }
        }
    }
    
    /// 使用 DispatchGroup run DispatchQueue
    ///
    ///
    func s3() {
        /* queue 裡的工作項目都是很單純的個別子執行緒 */
        let group: DispatchGroup = DispatchGroup()
        
        let queue1 = DispatchQueue(label: "queue1", attributes: .concurrent)
        queue1.async(group: group) {
            // 事件A
            for i in 1 ... 100 {
                print("i: \(i)")
            }
        }
        let queue2 = DispatchQueue(label: "queue2", attributes: .concurrent)
        queue2.async(group: group) {
            // 事件B
            for j in 101 ... 200 {
                print("j: \(j)")
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            // 已處理完事件A和事件B
            print("處理完成事件A和事件B...")
        }
    }
    
    
    /// 模擬 queue 裡 呼叫 API
    ///
    /// 需配合 enter leave
    func s4() {
        // queue 裡的工作項目除了都是個別的子執行緒外，每個子執行緒裡又有子執行緒(後端 API 屬另一條子執行緒)
        let group: DispatchGroup = DispatchGroup()

        let queue1 = DispatchQueue(label: "queue1", attributes: .concurrent)
        group.enter() // 開始呼叫 API1
        queue1.async(group: group) {
            // Call 後端 API1
            Tools.networkRequest(sleepTime: 2, taskName: "task 1") { taskName in
                print("\(taskName) finish...")
                group.leave()
            }
            // 結束呼叫 API1
            
        }
        let queue2 = DispatchQueue(label: "queue2", attributes: .concurrent)
        //group.enter() // 開始呼叫 API2
        queue2.async(group: group) {
            // Call 後端 API2
            Tools.networkRequest(sleepTime: 1, taskName: "task 2") { taskName in
                print("\(taskName) finish...")
        //        group.leave()
            }
            // 結束呼叫 API2
            
        }

        group.notify(queue: DispatchQueue.main) {
          // 完成所有 Call 後端 API 的動作
          print("完成所有 Call 後端 API 的動作...")
        }
    }
    
    // 但是要等 task 1 run 完 再 run task 2 怎麼辦呢?
    // 再 使用 wait(), 但是會 block queue 可能會造成 dead lock...
    func s5() {
        // queue 裡的工作項目除了都是個別的子執行緒外，每個子執行緒裡又有子執行緒(後端 API 屬另一條子執行緒)
        let group: DispatchGroup = DispatchGroup()

        let queue1 = DispatchQueue(label: "queue1", attributes: .concurrent)
        
        queue1.async(group: group) {
            group.enter() // 開始呼叫 API1
            // Call 後端 API1
            Tools.networkRequest(sleepTime: 2, taskName: "task 1") { taskName in
                print("\(taskName) finish...")
                group.leave()
            }
            // 結束呼叫 API1
            
        }

        
        
        let queue2 = DispatchQueue(label: "queue2", attributes: .concurrent)
        
        queue2.async(group: group) {
//            group.wait()
            group.enter() // 開始呼叫 API2
            // Call 後端 API2
            Tools.networkRequest(sleepTime: 1, taskName: "task 2") { taskName in
                print("\(taskName) finish...")
                group.leave()
            }
            // 結束呼叫 API2
            
        }

        group.notify(queue: DispatchQueue.main) {
          // 完成所有 Call 後端 API 的動作
          print("完成所有 Call 後端 API 的動作...")
        }
    }
    
    /// 使用 DispatchSemaphore
    ///
    /// A dispatch semaphore is an efficient implementation of a traditional counting semaphore. Dispatch semaphores call down to the kernel only when the calling thread needs to be blocked. If the calling semaphore does not need to block, no kernel call is made.
    ///
    /// You increment a semaphore count by calling the signal() method, and decrement a semaphore count by calling wait() or one of its variants that specifies a timeout.
    func s6() {
        let semaphore = DispatchSemaphore(value: 1)
        let group: DispatchGroup = DispatchGroup()
        let queue1 = DispatchQueue(label: "queue1", attributes: .concurrent)
        
        queue1.async(group: group) {
            semaphore.wait()
            // Call 後端 API1
            Tools.networkRequest(sleepTime: 10, taskName: "task 1") { taskName in
                print("\(taskName) finish...")
                semaphore.signal()
            }
            // 結束呼叫 API1
            
        }
        
        let queue2 = DispatchQueue(label: "queue2", attributes: .concurrent)
        queue2.async(group: group) {
            semaphore.wait()
            // Call 後端 API2
            Tools.networkRequest(sleepTime: 1, taskName: "task 2") { taskName in
                print("\(taskName) finish...")
                semaphore.signal()
            }
            // 結束呼叫 API2
        }

        group.notify(queue: DispatchQueue.main) {
            semaphore.wait()
            // 完成所有 Call 後端 API 的動作
            print("完成所有 Call 後端 API 的動作...")
            semaphore.signal()
        }
    }
    
    func o1() {
        let queue = OperationQueue()
        let op1 = BlockOperation {
            for i in 0 ... 10 {
                print("op_1: \(i)")
            }
        }
        op1.completionBlock = {
            print("op_1 completed")
        }
        
        queue.addOperation(op1)
        
        let op2 = BlockOperation {
            for i in 0 ... 10 {
                print("op_2: \(i)")
            }
        }
        op2.completionBlock = {
            print("op_2 completed")
        }
        queue.addOperation(op2)
        
        let op3 = BlockOperation {
            for i in 0 ... 10 {
                print("op_3: \(i)")
            }
        }
        op3.completionBlock = {
            print("op_3 completed")
        }
        queue.addOperation(op3)
        
        let op4 = BlockOperation {
            for i in 0 ... 10 {
                print("op_4: \(i)")
            }
        }
        op4.completionBlock = {
            print("op_4 completed")
        }
        queue.addOperation(op4)
    }
    
    func o2() {
        let queue = OperationQueue()
        let op1 = BlockOperation {
            for i in 0 ... 10 {
                print("op_1: \(i)")
            }
        }
        op1.completionBlock = {
            print("op_1 completed")
        }
        
        queue.addOperation(op1)
        
        let op2 = BlockOperation {
            for i in 0 ... 10 {
                print("op_2: \(i)")
            }
        }
        op2.completionBlock = {
            print("op_2 completed")
        }
        op2.addDependency(op1)
        queue.addOperation(op2)
        
        let op3 = BlockOperation {
            for i in 0 ... 10 {
                print("op_3: \(i)")
            }
        }
        op3.completionBlock = {
            print("op_3 completed")
        }
        op3.addDependency(op2)
        queue.addOperation(op3)
        
        let op4 = BlockOperation {
            for i in 0 ... 10 {
                print("op_4: \(i)")
            }
        }
        op4.completionBlock = {
            print("op_4 completed")
        }
        queue.addOperation(op4)
        
    }
    
    func o3() {
        // 1. creat an queue
        let queue = OperationQueue()
        
        // 2. set operation 1
        let op1 = BlockOperation {
            for i in 0 ... 10 {
                print("op_1: \(i)")
            }
        }
        op1.completionBlock = {
            print("op_1 completed")
        }
        
        // 3. set operation 2
        let op2 = BlockOperation {
            for i in 0 ... 10 {
                print("op_2: \(i)")
            }
        }
        op2.completionBlock = {
            print("op_2 completed")
        }
        op2.addDependency(op1) // add dependency.
        
        
        // 4. set operation 3
        let op3 = BlockOperation {
            for i in 0 ... 10 {
                print("op_3: \(i)")
            }
        }
        op3.completionBlock = {
            print("op_3 completed")
        }
        op3.addDependency(op2) // add dependency.
        
        // 5. set operation 4
        let op4 = BlockOperation {
            for i in 0 ... 10 {
                print("op_4: \(i)")
            }
        }
        op4.completionBlock = {
            print("op_4 completed")
        }
        
        // 6. add operations to queue
        queue.addOperation(op1)
        queue.addOperation(op2)
        queue.addOperation(op3)
        queue.addOperation(op4)
    }
    
    func o4() {
        // 1. creat an queue
        let queue = OperationQueue()
        
        // 2. set operation 1
        let op1 = BlockOperation {
            print("op_1 start")
            Tools.networkRequest(sleepTime: 3, taskName: "op_1") { taskName in
                print("\(taskName) finish...")
            }
        }
        op1.completionBlock = {
            print("op_1 completed")
        }
        
        // 3. set operation 2
        let op2 = BlockOperation {
            print("op_2 start")
            Tools.networkRequest(sleepTime: 3, taskName: "op_2") { taskName in
                print("\(taskName) finish...")
            }
        }
        op2.completionBlock = {
            print("op_2 completed")
        }
        op2.addDependency(op1) // add dependency.
        
        
        // 4. set operation 3
        let op3 = BlockOperation {
            Tools.networkRequest(sleepTime: 3, taskName: "op_3") { taskName in
                print("\(taskName) finish...")
            }
        }
        op3.completionBlock = {
            print("op_3 completed")
        }
        op3.addDependency(op2) // add dependency.
        
        // 5. set operation 4
        let op4 = BlockOperation {
            Tools.networkRequest(sleepTime: 3, taskName: "op_4") { taskName in
                print("\(taskName) finish...")
            }
        }
        op4.completionBlock = {
            print("op_4 completed")
        }
        op4.addDependency(op3)
        
        
        let opComplete = BlockOperation {
            print("mission complete !!!")
        }
        opComplete.addDependency(op4)
        
        // 6. add operations to queue
        queue.addOperation(op1)
        queue.addOperation(op2)
        queue.addOperation(op3)
        queue.addOperation(op4)
        queue.addOperation(opComplete)
//        let semaphore = DispatchSemaphore(value: 1)
        
    }
}
