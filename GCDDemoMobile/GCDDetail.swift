//
//  GCDDetail.swift
//  GCDDemoMobile
//
//  Created by roger.wang[王濬淇] on 2019/12/30.
//  Copyright © 2019 roger.wang[王濬淇]. All rights reserved.
//

import Foundation

/// queue type
public enum DispatchQueueType: String {
    case serial
    case concurrent
    case main
    case global
}

/// task type
enum DispatchTaskType: String {
    case sync
    case async
}

enum DetailMode: Int {
    case testSyncTaskInSerialQueue = 0
    case testAsyncTaskNestedInSameSerialQueue
    case testSyncTaskNestedInSameSerialQueue
    case testSyncTaskInConcurrentQueue
    case testAsyncTaskNestedInConcurrentQueue
    case testSyncTaskNestedInConcurrentQueue
    case testTaskInSerialQueue_async
    case testSyncTaskNestedInSameSerialQueue_async
    case testAsyncTaskNestedInSameSerialQueue_async
    case testTaskInConcurrentQueue_async
    case testSyncTaskNestedInSameConcurrentQueue_async
    case testAsyncTaskNestedInSameConcurrentQueue_async
}

class GCDDetail {

    let serialQueue = DispatchQueue(
        label: "test.serialQueue")
    let concurrentQueue = DispatchQueue(
        label: "test.concurrentQueue",
        attributes: .concurrent)
    let mainQueue = DispatchQueue.main
    let globalQueue = DispatchQueue.global()
    
    let serialQueueKey = DispatchSpecificKey<String>()
    let concurrentQueueKey = DispatchSpecificKey<String>()
    let mainQueueKey = DispatchSpecificKey<String>()
    let globalQueueKey = DispatchSpecificKey<String>()
    
    init() {
        serialQueue.setSpecific(key: serialQueueKey, value: DispatchQueueType.serial.rawValue)
        concurrentQueue.setSpecific(key: concurrentQueueKey, value: DispatchQueueType.concurrent.rawValue)
        mainQueue.setSpecific(key: mainQueueKey, value: DispatchQueueType.main.rawValue)
        globalQueue.setSpecific(key: globalQueueKey, value: DispatchQueueType.global.rawValue)
    }
    
    func run(mode: DetailMode) {
        switch mode {
        
        case .testSyncTaskInSerialQueue:
            testSyncTaskInSerialQueue()
        case .testAsyncTaskNestedInSameSerialQueue:
            testAsyncTaskNestedInSameSerialQueue()
        case .testSyncTaskNestedInSameSerialQueue:
            testSyncTaskNestedInSameSerialQueue() //crask
        case .testSyncTaskInConcurrentQueue:
            testSyncTaskInConcurrentQueue()
        case .testAsyncTaskNestedInConcurrentQueue:
            testSyncTaskInConcurrentQueue()
        case .testSyncTaskNestedInConcurrentQueue:
            testSyncTaskNestedInConcurrentQueue()
        case .testTaskInSerialQueue_async:
            testTaskInSerialQueue_async()
        case .testSyncTaskNestedInSameSerialQueue_async:
            testSyncTaskNestedInSameSerialQueue_async() //crash
        case .testAsyncTaskNestedInSameSerialQueue_async:
            testAsyncTaskNestedInSameSerialQueue_async()
        case .testTaskInConcurrentQueue_async:
            testTaskInConcurrentQueue_async()
        case .testSyncTaskNestedInSameConcurrentQueue_async:
            testSyncTaskNestedInSameConcurrentQueue_async()
        case .testAsyncTaskNestedInSameConcurrentQueue_async:
            testAsyncTaskNestedInSameConcurrentQueue_async()
        }
    }
    
    //MARK: - sync
    func testSyncTaskInSerialQueue() {
        serialQueue.sync {
            print("--- serialQueue sync task ---")
            Tools.printCurrentThread(with: "serialQueue sync task")
            Tools.isTaskInQueue(.serial, key: serialQueueKey)
            print("--- serialQueue sync task ---\n")
        }
    }
    
    func testAsyncTaskNestedInSameSerialQueue() {
        serialQueue.sync {
            print("--- serialQueue sync task ---")
            Tools.printCurrentThread(with: "serialQueue sync task")
            Tools.isTaskInQueue(.serial, key: serialQueueKey)
            serialQueue.async {
                print("--- AsyncTaskNested ---")
                Tools.printCurrentThread(with: "serialQueue sync task")
                Tools.isTaskInQueue(.serial, key: self.serialQueueKey)
                print("--- AsyncTaskNested ---\n")
            }
            print("--- serialQueue sync task ---\n")
            
        }
    }
    
    func testSyncTaskNestedInSameSerialQueue() {
        serialQueue.sync {
            print("--- serialQueue sync task ---")
            Tools.printCurrentThread(with: "serialQueue sync task")
            Tools.isTaskInQueue(.serial, key: serialQueueKey)
            serialQueue.sync {
                print("--- SyncTaskNested ---")
                Tools.printCurrentThread(with: "serialQueue sync task")
                Tools.isTaskInQueue(.serial, key: serialQueueKey)
                print("--- SyncTaskNested ---\n")
            }
            print("--- serialQueue sync task ---\n")
            
        }
    }
    
    func testSyncTaskInConcurrentQueue() {
        concurrentQueue.sync {
            print("--- concurrentQueue sync task ---")
            Tools.printCurrentThread(with: "concurrentQueue sync task")
            Tools.isTaskInQueue(.concurrent, key: concurrentQueueKey)
            print("--- concurrentQueue sync task ---\n")
        }
    }
    
    func testAsyncTaskNestedInConcurrentQueue() {
        concurrentQueue.sync {
            print("--- concurrentQueue sync task ---")
            Tools.printCurrentThread(with: "concurrentQueue sync task")
            Tools.isTaskInQueue(.concurrent, key: concurrentQueueKey)
            concurrentQueue.async {
                print("--- AsyncTaskNested ---")
                Tools.printCurrentThread(with: "concurrentQueue sync task")
                Tools.isTaskInQueue(.concurrent, key: self.concurrentQueueKey)
                print("--- AsyncTaskNested ---\n")
            }
            print("--- concurrentQueue sync task ---\n")
            
        }
    }
    
    func testSyncTaskNestedInConcurrentQueue() {
        concurrentQueue.sync {
            print("--- concurrentQueue sync task ---")
            Tools.printCurrentThread(with: "concurrentQueue sync task")
            Tools.isTaskInQueue(.concurrent, key: concurrentQueueKey)
            concurrentQueue.sync {
                print("--- SyncTaskNestedIn ---")
                Tools.printCurrentThread(with: "concurrentQueue sync task")
                Tools.isTaskInQueue(.concurrent, key: concurrentQueueKey)
                print("--- SyncTaskNestedIn ---\n")
            }
            print("--- concurrentQueue sync task ---\n")
            
        }
    }
    
    //MARK: - async
    func testTaskInSerialQueue_async() {
        serialQueue.async {
            print("--- testTaskInSerialQueue_async ---")
            Tools.printCurrentThread(with: "serialQueue async task")
            Tools.isTaskInQueue(.serial, key: self.serialQueueKey)
            print("--- testTaskInSerialQueue_async ---\n")
        }
    }
    
    func testSyncTaskNestedInSameSerialQueue_async() {
        serialQueue.async {
            print("--- testSyncTaskNestedInSameSerialQueue_async ---")
            Tools.printCurrentThread(with: "serialQueue async task")
            Tools.isTaskInQueue(.serial, key: self.serialQueueKey)
            print("--- testSyncTaskNestedInSameSerialQueue_async ---\n")
            self.serialQueue.sync {
                print("--- serialQueue sync task ---")
                Tools.printCurrentThread(with: "serialQueue async task")
                Tools.isTaskInQueue(.serial, key: self.serialQueueKey)
                print("--- serialQueue sync task ---\n")
            }
        }
    }
    
    func testAsyncTaskNestedInSameSerialQueue_async() {
        serialQueue.async {
            print("--- testAsyncTaskNestedInSameSerialQueue_async ---")
            Tools.printCurrentThread(with: "serialQueue async task")
            Tools.isTaskInQueue(.serial, key: self.serialQueueKey)
            print("--- testAsyncTaskNestedInSameSerialQueue_async ---\n")
            self.serialQueue.async {
                print("--- serialQueue async task ---")
                Tools.printCurrentThread(with: "serialQueue async task")
                Tools.isTaskInQueue(.serial, key: self.serialQueueKey)
                print("--- serialQueue async task ---\n")
            }
        }
    }

    func testTaskInConcurrentQueue_async() {
        concurrentQueue.async {
            print("--- testTaskInConcurrentQueue_async ---")
            Tools.printCurrentThread(with: "concurrentQueue async task")
            Tools.isTaskInQueue(.concurrent, key: self.concurrentQueueKey)
            print("--- testTaskInConcurrentQueue_async ---\n")
        }
    }
    
    func testSyncTaskNestedInSameConcurrentQueue_async() {
        concurrentQueue.async {
            print("--- testSyncTaskNestedInSameConcurrentQueue_async ---")
            Tools.printCurrentThread(with: "concurrentQueue async task")
            Tools.isTaskInQueue(.concurrent, key: self.concurrentQueueKey)
            
            self.concurrentQueue.sync {
                print("--- ConcurrentQueue sync task ---")
                Tools.printCurrentThread(with: "concurrentQueue async task")
                Tools.isTaskInQueue(.concurrent, key: self.concurrentQueueKey)
                print("--- ConcurrentQueue sync task ---\n")
            }
            
            print("--- testSyncTaskNestedInSameConcurrentQueue_async ---\n")
        }
    }
    
    func testAsyncTaskNestedInSameConcurrentQueue_async() {
        concurrentQueue.async {
            print("--- testAsyncTaskNestedInSameConcurrentQueue_async ---")
            Tools.printCurrentThread(with: "concurrentQueue async task")
            Tools.isTaskInQueue(.concurrent, key: self.concurrentQueueKey)
            print("--- testAsyncTaskNestedInSameConcurrentQueue_async ---\n")
            self.concurrentQueue.async {
                print("--- ConcurrentQueue async task ---")
                Tools.printCurrentThread(with: "concurrentQueue async task")
                Tools.isTaskInQueue(.concurrent, key: self.concurrentQueueKey)
                print("--- ConcurrentQueue async task ---\n")
            }
        }
    }
    
}

