//
//  StateSubject+State.swift
//  StateSubject
//
//  Created by Chung Tran on 07/02/2021.
//

import Foundation

extension StateSubject {
    public enum State: Equatable {
        public static func == (lhs: StateSubject<T>.State, rhs: StateSubject<T>.State) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading), (.loaded, .loaded):
                return true
            case (.error(let error1), .error(let error2)):
                return error1.localizedDescription == error2.localizedDescription
            default:
                return false
            }
        }
        
        case loading
        case loaded
        case error(Error)
    }
}
