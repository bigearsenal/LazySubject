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
    // MARK: - Private
    private let disposeBag = DisposeBag()
    private var disposable: Disposable?
    
    private let _stateRelay = BehaviorRelay<LazySubjectState>(value: .initializing)
    
    // MARK: - Public
    public private(set) var value: T?
    public var request: Single<T> {
        didSet {
            value = nil
            _stateRelay.accept(.initializing)
            disposable?.dispose()
        }
    }
    public var dataModifier: ((T) -> T)?
    public var state: LazySubjectState {
        _stateRelay.value
    }
    public var observable: Observable<LazySubjectState> {
        _stateRelay.asObservable()
    }
    public var dataObservable: Observable<T?> {
        observable.map {[weak self] _ in self?.value}
    }
    
    // MARK: - Initializer
    public init(value: T? = nil, request: Single<T>, dataModifier: ((T) -> T)? = nil) {
        self.value = value
        self.request = request
        self.dataModifier = dataModifier
    }
    
    // MARK: - Methods
    public func reload(force: Bool = false) {
        // prevent dupplicating request
        if force, _stateRelay.value == .loading {return}
        
        // cancel old request if it's exist
        disposable?.dispose()
        
        // new state
        if force {value = nil}
        _stateRelay.accept(.loading)
        
        // send request
        let disposable = request
            .subscribe(onSuccess: {newData in
                self.handleNewData(newData)
            }, onError: {error in
                self.handleError(error)
            })
        disposable.disposed(by: disposeBag)
    }
    
    private func handleNewData(_ newData: T) {
        value = dataModifier?(newData) ?? newData
        _stateRelay.accept(.loaded)
    }
    
    private func handleError(_ error: Error) {
        _stateRelay.accept(.error(error))
    }
    
    public func updateValue(_ value: T) {
        if _stateRelay.value == .loaded {
            self.value = value
            _stateRelay.accept(.loaded)
        }
    }
}
