//
//  StateSubject.swift
//  StateSubject
//
//  Created by Chung Tran on 07/02/2021.
//

import Foundation
import RxSwift
import RxCocoa

public final class StateSubject<T: Equatable> {
    public let state = BehaviorRelay<State>(value: .loading)
    private let disposeBag = DisposeBag()
    
    public var value: T?
    public var request: Single<T>
    public var dataModifier: ((T) -> T)?
    
    public init(value: T? = nil, request: Single<T>, dataModifier: ((T) -> T)? = nil) {
        self.value = value
        self.request = request
        self.dataModifier = dataModifier
    }
    
    public func reload() {
        if state.value == .loading {return}
        state.accept(.loading)
        request
            .subscribe(onSuccess: {newData in
                self.handleNewData(newData)
            }, onFailure: {error in
                self.handleError(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleNewData(_ newData: T) {
        value = dataModifier?(newData) ?? newData
        state.accept(.loaded)
    }
    
    private func handleError(_ error: Error) {
        state.accept(.error(error))
    }
}
