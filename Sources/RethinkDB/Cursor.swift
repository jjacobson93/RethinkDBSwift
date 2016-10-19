import Foundation
import Dispatch

public struct CursorIterator<T>: IteratorProtocol {
    let cursor: Cursor<T>

    init(_ cursor: Cursor<T>) {
        self.cursor = cursor
    }

    public mutating func next() -> T? {
        return self.cursor.next()
    }
}

public class Cursor<T>: Sequence {
    
    public typealias Iterator = CursorIterator<T>

    public var token: UInt64

    internal let connection: Connection
    internal let query: Query
    internal let isFeed: Bool
    
    internal var items: [T] = []
    internal var threshold: Int = 1
    internal var outstandingRequests: Int = 0
    internal var alreadyIterated: Bool = false
    internal var error: Error? = nil

    internal var awaitingContinue: DispatchSemaphore?

    typealias Transformer = (Document) -> (T?)
    let transform: Transformer

    init(connection: Connection, query: Query, firstResponse: Response, transform: @escaping Transformer) {
        self.connection = connection
        self.query = query
        self.token = query.token
        self.isFeed = firstResponse.isFeed
        self.transform = transform
        
        // connection.addToCache(cursor: self)
        self.maybeSendContinue()
        self.extendInternal(from: firstResponse)
    }

    deinit {
        try! self.close()
    }

    public func next() -> T? {
        while self.items.count == 0 {
            self.maybeSendContinue()
            self.waitOnCursorItems()

            if self.items.count != 0 {
                break
            }

            if self.error != nil {
                return nil
            }
        }

        return self.items.remove(at: 0)
    }

    public func makeIterator() -> CursorIterator<T> {
        return CursorIterator<T>(self)
    }
    
    public func toArray() -> [T] {
        var array = [T]()
        for item in self {
            array.append(item)
        }
        
        return array
    }

    func extend(from response: Response) {
        self.outstandingRequests -= 1
        self.maybeSendContinue()
        self.extendInternal(from: response)
    }

    private func extendInternal(from response: Response) {
        self.threshold = response.documents.count
        if self.error == nil {
            let documents = response.documents
            switch response.type {
                case .partial:
                    self.items += documents.flatMap(self.transform)
                case .sequence:
                    self.items += documents.flatMap(self.transform)
                    self.error = ReqlError.cursorEmpty
                default:
                    self.error = response.makeError(self.query)
            }
        }

        if self.outstandingRequests == 0 && self.error != nil {
            // connection.removeFromCache(token: response.token)
        }
    }

    func maybeSendContinue() {
        if self.error == nil && self.items.count < self.threshold && self.outstandingRequests == 0 {
            self.outstandingRequests += 1
            do {
                self.awaitingContinue = try self.connection.sendContinue(self)
            } catch let error {
                self.error = error
            }
        }
    }

    func waitOnCursorItems(_ timeout: DispatchTime = DispatchTime.distantFuture) {
        if let waiter = self.awaitingContinue {
            _ = waiter.wait(timeout: timeout)
            self.awaitingContinue = nil
        }

        guard let response = self.connection.completedQueries.removeValue(forKey: self.query.token) else {
            self.error = ReqlError.driverError("No response from query or timeout")
            return
        }

        self.extend(from: response)
    }

    public func close() throws {
        // self.connection.removeFromCache(token: self.token)
        if self.error == nil {
            self.error = ReqlError.cursorEmpty
            if self.connection.isOpen {
                self.outstandingRequests += 1
                try self.connection.stop(self)
            }
        }
    }
}
