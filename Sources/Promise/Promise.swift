import AnyError
import Result

public class Promise<ReturnType> {
    public typealias Callback = ((@escaping (ReturnType) -> Void), @escaping (Error) -> Void) -> Void
    public typealias ThenCallback = (ReturnType) -> Void
    public typealias ErrorCallback = (Error) -> Void

    private let callback: Callback
    private var thenCallbacks: [ThenCallback] = []
    private var errorCallbacks: [ErrorCallback] = []

    private var result: Result<ReturnType, AnyError>?

    private var isExecuting = false

    public init(callback: @escaping Callback) {
        self.callback = callback
    }

    @discardableResult
    public func then(_ callback: @escaping (ReturnType) -> Void) -> Promise<ReturnType> {
        enqueueThenCallback(callback)
        execute()

        return self
    }

    public func then<T>(_ callback: @escaping (ReturnType) throws -> Promise<T>) -> Promise<T> {
        let promise = Promise<T> { resolve, reject in
            self.enqueueThenCallback { result in
                do {
                    let promise = try callback(result)
                    promise.then { resolve($0) }
                        .catch { reject($0) }
                } catch let error {
                    reject(error)
                }
            }

            self.enqueueCatchCallback { error in
                reject(error)
            }
        }

        execute()

        return promise
    }

    @discardableResult
    public func `catch`(_ callback: @escaping ((Error) -> Void)) -> Promise<ReturnType> {
        enqueueCatchCallback(callback)
        execute()

        return self
    }

    private func execute() {
        if isExecuting {
            return
        }

        isExecuting = true

        self.callback({ result in
            self.result = .value(result)
            self.thenCallbacks.forEach { $0(result) }
        }, { error in
            self.result = .error(AnyError(error))
            self.errorCallbacks.forEach { $0(error) }
        })
    }

    private func enqueueThenCallback(_ callback: @escaping ThenCallback) {
        if let result = result {
            if case .value(let result) = result {
                callback(result)
            }
        } else {
            self.thenCallbacks.append(callback)
        }
    }

    private func enqueueCatchCallback(_ callback: @escaping ErrorCallback) {
        if let result = result {
            if case .error(let error) = result {
                callback(error.error)
            }
        } else {
            self.errorCallbacks.append(callback)
        }
    }
}
