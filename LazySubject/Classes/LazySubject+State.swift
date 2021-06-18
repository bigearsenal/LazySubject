//
//  StateSubject+State.swift
//  StateSubject
//
//  Created by Chung Tran on 07/02/2021.
//

import Foundation

public enum LazySubjectState: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.initializing, .initializing), (.loading, .loading), (.loaded, .loaded):
            return true
        case (.error(let error1), .error(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        default:
            return false
        }
    }
    
    case initializing
    case loading
    case loaded
    case error(Error)
}

public extension Array where Element == LazySubjectState {
    var combinedState: Element {
        assert(count > 0)
        
        // if all are equal
        if allEqual() {
            return self.first!
        }
        
        // if there is an error
        if let error = firstError {
            return .error(error)
        }
        
        // if at least 1 is loading
        if atLeastOneIsLoading {
            return .loading
        }
        
        return .initializing
    }
    
    private func allEqual() -> Bool {
        if let firstElem = first {
            return !dropFirst().contains { $0 != firstElem }
        }
        return true
    }
    
    private var firstError: Error? {
        for i in self {
            switch i {
            case .error(let error):
                return error
            default:
                break
            }
        }
        return nil
    }
    
    private var atLeastOneIsLoading: Bool {
        for i in self {
            switch i {
            case .loading, .initializing:
                return true
            default:
                break
            }
        }
        return false
    }
}
