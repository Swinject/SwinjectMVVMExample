import Foundation


/// A Nimble matcher that succeeds when the actual sequence's last element
/// is equal to the expected value.
public func endWith<S: Sequence, T: Equatable>(_ endingElement: T) -> NonNilMatcherFunc<S>
    where S.Iterator.Element == T
{
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "end with <\(endingElement)>"

        if let actualValue = try actualExpression.evaluate() {
            var actualGenerator = actualValue.makeIterator()
            var lastItem: T?
            var item: T?
            repeat {
                lastItem = item
                item = actualGenerator.next()
            } while(item != nil)
            
            return lastItem == endingElement
        }
        return false
    }
}

/// A Nimble matcher that succeeds when the actual collection's last element
/// is equal to the expected object.
public func endWith(_ endingElement: Any) -> NonNilMatcherFunc<NMBOrderedCollection> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "end with <\(endingElement)>"
        let collection = try actualExpression.evaluate()
        return collection != nil && collection!.index(of: endingElement) == collection!.count - 1
    }
}


/// A Nimble matcher that succeeds when the actual string contains the expected substring
/// where the expected substring's location is the actual string's length minus the
/// expected substring's length.
public func endWith(_ endingSubstring: String) -> NonNilMatcherFunc<String> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "end with <\(endingSubstring)>"
        if let collection = try actualExpression.evaluate() {
            let range = collection.range(of: endingSubstring)
            return range != nil && range!.upperBound == collection.endIndex
        }
        return false
    }
}

#if _runtime(_ObjC)
extension NMBObjCMatcher {
    public class func endWithMatcher(_ expected: Any) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let actual = try! actualExpression.evaluate()
            if let _ = actual as? String {
                let expr = actualExpression.cast { $0 as? String }
                return try! endWith(expected as! String).matches(expr, failureMessage: failureMessage)
            } else {
                let expr = actualExpression.cast { $0 as? NMBOrderedCollection }
                return try! endWith(expected).matches(expr, failureMessage: failureMessage)
            }
        }
    }
}
#endif
