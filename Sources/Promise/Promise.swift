import Result

public class Promise<ReturnType, ErrorType: Swift.Error> {
    public typealias Callback = ((@escaping (ReturnType) -> Void), @escaping (ErrorType) -> Void) -> Void
    public typealias ThenCallback = (ReturnType) -> Void
    public typealias ErrorCallback = (ErrorType) -> Void

    private let callback: Callback
    private var thenCallbacks: [ThenCallback] = []
    private var errorCallbacks: [ErrorCallback] = []

    private var result: Result<ReturnType, ErrorType>?

    private var isExecuting = false

    public init(callback: @escaping Callback) {
        self.callback = callback
    }

    @discardableResult
    public func then(_ callback: @escaping (ReturnType) -> Void) -> Promise<ReturnType, ErrorType> {
        enqueueThenCallback(callback)
        execute()

        return self
    }

    public func then<T>(_ callback: @escaping (ReturnType) throws -> Promise<T, ErrorType>) -> Promise<T, ErrorType> {
        let promise = Promise<T, ErrorType> { resolve, reject in
            self.enqueueThenCallback { result in
                do {
                    let promise = try callback(result)
                    promise.then { resolve($0) }
                        .catch { reject($0) }
                } catch let error as ErrorType {
                    reject(error)
                } catch let error {
                    fatalError("Invalid error type thrown. Expected \(ErrorType.self), got \(type(of: error))")
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
    public func `catch`(_ callback: @escaping ((ErrorType) -> Void)) -> Promise<ReturnType, ErrorType> {
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
            self.result = .success(result)
            self.thenCallbacks.forEach { $0(result) }
        }, { error in
            self.result = .failure(error)
            self.errorCallbacks.forEach { $0(error) }
        })
    }

    private func enqueueThenCallback(_ callback: @escaping ThenCallback) {
        if let result = result {
            if case .success(let result) = result {
                callback(result)
            }
        } else {
            self.thenCallbacks.append(callback)
        }
    }

    private func enqueueCatchCallback(_ callback: @escaping ErrorCallback) {
        if let result = result {
            if case .failure(let error) = result {
                callback(error)
            }
        } else {
            self.errorCallbacks.append(callback)
        }
    }
}
