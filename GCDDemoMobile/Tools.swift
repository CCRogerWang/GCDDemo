import Foundation

public class Tools {
    // 假装是网络请求
    public static func networkRequest(sleepTime: Int, taskName: String, closure: @escaping (String)->Void) -> Void {
//        Thread.printCurrent()
        print("\(taskName) start...")
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: TimeInterval(sleepTime))
            // 假装是成功回调
            DispatchQueue.main.async {
                closure(taskName)
            }
        }
    }
    
    public static func printCurrentThread(with des: String, _ terminator: String = "") {
        print("\(des) at thread: \(Thread.current), this is \(Thread.isMainThread ? "" : "not ")main thread\(terminator)")
    }
    
    public static func isTaskInQueue(_ queueType: DispatchQueueType, key: DispatchSpecificKey<String>) {
        let value = DispatchQueue.getSpecific(key: key)
        let optOriginalValue: String? = queueType.rawValue
        print("Is task in \(queueType.rawValue) queue: \(value == optOriginalValue)")
    }
}
