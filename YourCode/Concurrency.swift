//
//  Concurrency.swift


import Foundation

/// To complete this task, fill out the `loadMessage` method below this comment.
///
///  * Read the requirements defined below.
///  * Feel free to research solutions on the interent, but don't copy and paste code.
///  * Do track your progress in git and submit the project with git history.
///  * Don't use external libraries such as PromiseKit / RXSwift.
///
/// # Background
///
/// We have created two data sources `fetchMessageOne` & `fetchMessageTwo`
/// that load two parts of a messaage. These mimic loading data from the network and call their completion handlers in 0-2 seconds.
/// (You don't need to look at the source code for these functions, but you should know they complete at random times between runs).
///
///
/// # Requirements Part 1
///
/// This function should fetch both parts of the message (concurrently using GCD or OperationQueue) and join them with
/// a space. e.g if `fetchMessageOne` completes with "Good" and `fetchMessageTwo` completes with "morning!" then loadMessage should call it's completion once with the String:
///   "Good morning!"
/// If loading either part of the message takes more than 2 seconds then `loadMessage` should complete with the String
///   "Unable to load message - Time out exceeded"
///
/// The function should only complete once and must always return the full message in the correct order.
///
/// # Requirements Part 2
///
/// Refactor this function to use idomatic Swift code.
/// Follow the apple Swift naming guidelines. If you choose you can abstract classes, structs, protocols, enums, generics etc.
///
/// # Requirements Part 3
///
/// Refactor this function so it is easy to unit test.
/// Write unit tests that verify both the successful loading & timeout behaviour. These tests must be deterministic.
///
/// # Requirement Part 4
/// * The completion handler should always be called on the main thread.
/// * If loadMessage is called on the main thread, loadMessage should not block the main thread.
///
///
/// How we assess this task
///
/// * Completed functional requirements
/// * Deterministic Unit tests
/// * Code readability & matching apple naming guidelines
/// * Showing work through git history
///
func loadMessage(completion: @escaping (String) -> Void) {
    var firstMessage:String?
    var lastMessage:String?
    let timeoutMessage = "Unable to load message - Time out exceeded"
    /*
    let operationQueueToFetchMessages = OperationQueue()
    operationQueueToFetchMessages.maxConcurrentOperationCount = 2
    let startOfOperation = CFAbsoluteTimeGetCurrent()
    let fetchMessageOneOperation = BlockOperation {
        fetchMessageOne { (messageOne) in
            firstMessage = messageOne
            let elapsedTime = elapsedTimeFromStartTime(startOfOperation: startOfOperation)
            print(elapsedTime)
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
            print(elapsedTime)
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
 */
    let fetchQueueForMessageOne = DispatchQueue(label: "com.fetchQueueForMessageOne")
    let fetchQueueForMessageTwo = DispatchQueue(label: "com.fetchQueueForMessageTwo")
    let dispatchGroup = DispatchGroup()
    var completionIsExecuted = false
    dispatchGroup.enter()
    let fetchItemOne = DispatchWorkItem {
        fetchMessageOne { (messageOne) in
            firstMessage = messageOne
            dispatchGroup.leave()
        }
    }
    dispatchGroup.enter()
    let fetchItemTwo = DispatchWorkItem {
        fetchMessageTwo(completion: { (messageTwo) in
            lastMessage = messageTwo
            dispatchGroup.leave()
        })
    }
    fetchQueueForMessageOne.async(group: dispatchGroup, execute: fetchItemOne)
    fetchQueueForMessageTwo.async(group: dispatchGroup, execute: fetchItemTwo)
    dispatchGroup.notify(queue: .main) {
        if !completionIsExecuted {
            completionIsExecuted = true
            completion(firstMessage! + " " + lastMessage!)
        }
    }
    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
        DispatchQueue.main.async {
            if !completionIsExecuted {
                completionIsExecuted = true
                completion(timeoutMessage)
            }
        }
    }
}

func elapsedTimeFromStartTime(startOfOperation:CFAbsoluteTime) -> Double {
    return CFAbsoluteTimeGetCurrent() - startOfOperation
}

func completionOnMainThreadWith(message:String, handler: @escaping (String) -> Void) {
    OperationQueue.main.addOperation {
        handler(message)
    }
}
