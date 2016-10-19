import Foundation

extension Value {
    public subscript(key: String) -> Value {
        get {
            switch self {
            case .document(let doc):
                return doc[key]
            default:
                return .nothing
            }
        }

        set(value) {
            switch self {
            case .document(let doc):
                doc[key] = value
                self = .document(doc)
            default:
                return
            }
        }
    }

    public subscript(key: Int) -> Value {
        get {
            switch self {
            case .array(let arr):
                return arr[key]
            default:
                return .nothing
            }
        }

        set(value) {
            switch self {
            case .array(var arr):
                arr[key] = value
                self = .array(arr)
            default:
                return
            }
        }
    }
}
