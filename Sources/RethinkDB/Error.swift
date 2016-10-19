public enum ReqlError: Error {
    case authError(String)
    case driverError(String)
    case cursorEmpty

    public var localizedDescription: String {
        switch self {
        case .authError(let e): return e
        case .driverError(let e): return e
        case .cursorEmpty: return "Cursor is empty"
        }
    }
}
