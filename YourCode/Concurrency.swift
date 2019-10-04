//
//  Concurrency.swift


import Foundation

func loadMessage(completion: @escaping (String) -> Void) {
    var firstMessage:String?
    var lastMessage:String?
    let timeoutMessage = "Unable to load message - Time out exceeded"
    let operationQueueToFetchMessages = OperationQueue()
    operationQueueToFetchMessages.maxConcurrentOperationCount = 2
    let startOfOperation = CFAbsoluteTimeGetCurrent()
    let fetchMessageOneOperation = BlockOperation {
        fetchMessageOne { (messageOne) in
            firstMessage = messageOne
            let elapsedTime = elapsedTimeFromStartTime(startOfOperation: startOfOperation)
            if elapsedTime > 2.0 {
                completionOnMainThreadWith(message: timeoutMessage, handler: completion)
            } else {
                if let firstMessageUnWrapped = firstMessage, let lastMessageUnWrapped = lastMessage {
                    completionOnMainThreadWith(message: "\(firstMessageUnWrapped) \(lastMessageUnWrapped)", handler: completion)
                }
            }
        }
    }
    let fetchMessageTwoOperation = BlockOperation {
        fetchMessageTwo { (messageTwo) in
            lastMessage = messageTwo
            let elapsedTime = elapsedTimeFromStartTime(startOfOperation: startOfOperation)
            if elapsedTime > 2.0 {
                completionOnMainThreadWith(message: timeoutMessage, handler: completion)
            } else {
                if let firstMessageUnWrapped = firstMessage, let lastMessageUnWrapped = lastMessage {
                    completionOnMainThreadWith(message: "\(firstMessageUnWrapped) \(lastMessageUnWrapped)", handler: completion)
                }
            }
        }
    }
    operationQueueToFetchMessages.addOperations([fetchMessageOneOperation,fetchMessageTwoOperation], waitUntilFinished: false)
}

func elapsedTimeFromStartTime(startOfOperation:CFAbsoluteTime) -> Double {
    return CFAbsoluteTimeGetCurrent() - startOfOperation
}

func completionOnMainThreadWith(message:String, handler: @escaping (String) -> Void) {
    OperationQueue.main.addOperation {
        handler(message)
    }
}
