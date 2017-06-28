//
//  SignalProducer+Argo.swift
//  Pods
//
//  Created by Sam Watts on 23/01/2016.
//
//

import Foundation
import ReactiveSwift
import Moya
import Argo

extension SignalProducerProtocol where Value == Moya.Response, Error == MoyaError {
    
    public func mapFlickerJSON(failsOnEmptyData: Bool = true) -> SignalProducer<Any, MoyaError> {
        return producer.flatMap(.latest) { response -> SignalProducer<Any, MoyaError> in
            return unwrapThrowable { try response.mapFlickerJSON(failsOnEmptyData: failsOnEmptyData) }
        }
    }
    
    func mapFlickerObject<T:Decodable>(type: T.Type, rootKey: String? = nil) -> SignalProducer<T, Error> where T == T.DecodedType {
        
        return producer.flatMap(.latest) { response -> SignalProducer<T, Error> in
            
            do {
                return SignalProducer(value: try response.mapFlickerObject(rootKey: rootKey))
            } catch let error as MoyaError {
                return SignalProducer(error: error)
            } catch {
                return SignalProducer(error: Error.underlying(error))
            }
        }
    }
}

/// Maps throwable to SignalProducer.
private func unwrapThrowable<T>(throwable: () throws -> T) -> SignalProducer<T, MoyaError> {
    do {
        return SignalProducer(value: try throwable())
    } catch {
        if let error = error as? MoyaError {
            return SignalProducer(error: error)
        } else {
            // The cast above should never fail, but just in case.
            return SignalProducer(error: MoyaError.underlying(error as NSError))
        }
    }
}

