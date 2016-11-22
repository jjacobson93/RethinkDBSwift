public enum ReqlError: Error {
    case authError(String)
    case compileError(String, [Any], [Any])
    case cursorEmpty
    case driverError(String)
    case typeError(Any, String)

    public var localizedDescription: String {
        switch self {
        case .authError(let e): return e
        case .driverError(let e): return e
        case .compileError(let e, let term, let backtrace):
            let queryPrinter = QueryPrinter(root: term, backtrace: backtrace)
            return "\(e)\n\(queryPrinter.printQuery())\n\(queryPrinter.printCarrots())"
        case .cursorEmpty: return "Cursor is empty"
        case .typeError(let value, let type): return "Cannot coerce value \(value) to suggested type \(type)."
        }
    }
}

public struct QueryPrinter {
    let root: [Any]
    let backtrace: [Any]
    
    init(root: [Any], backtrace: [Any]) {
        self.root = root
        self.backtrace = backtrace
    }
    
    func printQuery() -> String {
        return self.composeTerm(self.root)
    }
    
    func printCarrots() -> String {
        return self.composeCarrots(self.root, self.backtrace)
    }
    
    func composeTerm(_ term: [Any]) -> String {
        guard let typeValue = term[0] as? Int else {
            return "EXPECTED INT, FOUND ARRAY: \(term[0])"
        }
        
        guard let termType = ReqlTerm(rawValue: typeValue), let termArgs = term[1] as? [Any] else {
            return ""
        }
        
        let args = termArgs.map({ self.composeTerm($0) })
        var optargs = [String: String]()
        if term.count > 2, let dict = term[2] as? [String: Any] {
            for (k, v) in dict {
                optargs[k] = self.composeTerm(v)
            }
        }
        return self.composeTerm(termType, args, optargs)
    }
    
    func composeTerm(_ term: Any) -> String {
        if let term = term as? [Any] {
            return self.composeTerm(term)
        }
        
        return "\(term)"
    }
    
    func composeTerm(_ termType: ReqlTerm, _ args: [String], _ optargs: [String: String]) -> String {
        let term = termType.description
        let argsString = args.joined(separator: ", ")
        if optargs.isEmpty {
            return "\(term)(\(argsString))"
        }
        return "\(term)(\(argsString), \(optargs))"
    }
    
    func composeCarrots(_ term: [Any], _ backtrace: [Any]) -> String {
        guard let typeValue = term[0] as? Int, let termType = ReqlTerm(rawValue: typeValue), let termArgs = term[1] as? [Any] else {
            return ""
        }
        
        if backtrace.isEmpty {
            return String(repeating: "^", count: self.composeTerm(term).characters.count)
        }
        
        let currFrame = backtrace[0]
        let args = termArgs.enumerated().map { (i, arg) -> String in
            if let currFrameInt = currFrame as? Int64, Int(currFrameInt) == i {
                return self.composeCarrots(arg, Array(backtrace[1..<backtrace.count]))//self.composeCarrots(arg, backtrace[1..<backtrace.count])
            }
            
            return self.composeTerm(arg)
        }
        
        var optargs = [String: String]()
        if term.count > 2, let dict = term[2] as? [String: Any] {
            for (k, v) in dict {
                if let currFrameKey = currFrame as? String, currFrameKey == k {
                    optargs[k] = self.composeCarrots(v, Array(backtrace[1..<backtrace.count]))
                } else {
                    optargs[k] = self.composeTerm(v)
                }
            }
        }
        
        return self.composeTerm(termType, args, optargs).characters.map({ (c: Character) -> String in
            return c != "^" ? " " : "^"
        }).joined()
    }
    
    func composeCarrots(_ term: Any, _ backtrace: [Any]) -> String {
        return ""
    }
}
