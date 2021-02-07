//
//  StateSubject.swift
//  StateSubject
//
//  Created by Chung Tran on 07/02/2021.
//

import Foundation
import RxSwift
import RxCocoa

public final class LazySubject<T: Equatable> {
    public let state = BehaviorRelay<State>(value: .initializing)
    private let disposeBag = DisposeBag()
    private var disposable: Disposable?
    
    public var value: T?
    public var request: Single<T> {
        didSet {
            value = nil
            state.accept(.initializing)
            disposable?.dispose()
        }
    }
    public var dataModifier: ((T) -> T)?
    
    public init(value: T? = nil, request: Single<T>, dataModifier: ((T) -> T)? = nil) {
        self.value = value
        self.request = request
        self.dataModifier = dataModifier
    }
    
    public func reload(force: Bool = false) {
        // prevent dupplicating request
        if force, state.value == .loading {return}
        
        // cancel old request if it's exist
        disposable?.dispose()
        
        // new state
        if force {value = nil}
        state.accept(.loading)
        
        // send request
        let disposable = request
            .subscribe(onSuccess: {newData in
                self.handleNewData(newData)
            }, onFailure: {error in
                self.handleError(error)
            })
        disposable.disposed(by: disposeBag)
    }
    
    private func handleNewData(_ newData: T) {
        value = dataModifier?(newData) ?? newData
        state.accept(.loaded)
    }
    
    private func handleError(_ error: Error) {
        state.accept(.error(error))
    }
}
