//
//  SynchronizedNetworkCall.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 27/04/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class SynchronizedNetworkCall<T> {
    private lazy var syncQueue: DispatchQueue = DispatchQueue(label: "sync.queue")
    private var waitingLoadingDelegates: [NetworkLoading] = []
    private var waitingCompletionBlocks: [() -> Void] = []
    private var action: (SynchronizedNetworkCall, NetworkLoading?) -> NetworkRequestOperation?
    private var completion: (T?) -> Void
    
    private var running = false
    private var completed = false
    
    private var currentOperation: NetworkRequestOperation? = nil
    
    init(action: @escaping (SynchronizedNetworkCall, NetworkLoading?) -> NetworkRequestOperation?, completion: @escaping (T?) -> Void) {
        self.action = action
        self.completion = completion
    }
}

extension SynchronizedNetworkCall {
    func run(loadingDelegate: NetworkLoading? = nil, completion: (() -> Void)? = nil) {
        syncQueue.sync {
            if self.completed {
                DispatchQueue.main.async {
                    completion?()
                }
                return
            }
            
            if let completion = completion {
                self.waitingCompletionBlocks.append(completion)
            }
            
            if !self.running {
                self.running = true
                
                DispatchQueue.main.async {
                    if let op = self.action(self, loadingDelegate) {
                        self.syncQueue.sync {
                            self.currentOperation = op
                        }
                    }
                }
            }
            else if let delegate = loadingDelegate, let operation = currentOperation {
                self.waitingLoadingDelegates.append(delegate)
                delegate.startLoading(operation)
            }
        }
    }
    
    func markAsRunning() {
        syncQueue.sync {
            if !self.completed && !self.running {
                self.running = true
            }
        }
    }
    
    func reset() {
        syncQueue.sync {
            self.running = false
            self.completed = false
            self.waitingCompletionBlocks = []
            self.waitingLoadingDelegates = []
            self.currentOperation = nil
        }
    }
    
    func complete(_ success: Bool, _ response: T?) {
        syncQueue.sync {
            guard !self.completed else {
                return
            }
            
            self.running = false
            self.completed = success
            
            self.callWaitingBlocks(success: success, response: response)
            self.completion(response)
        }
    }
}

private extension SynchronizedNetworkCall {
    func callWaitingBlocks(success: Bool, response: T?) {
        let operation = currentOperation ?? NetworkRequestOperation()
        let blocks = waitingCompletionBlocks
        let delegates = waitingLoadingDelegates
        
        waitingCompletionBlocks = []
        waitingLoadingDelegates = []
        currentOperation = nil
        DispatchQueue.main.async {
            delegates.forEach { $0.stopLoading(operation) }
            blocks.forEach { $0() }
        }
    }
}
