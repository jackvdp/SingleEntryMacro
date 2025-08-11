import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SingleEntryMacros

final class SingleEntryMacroTests: XCTestCase {
    func testSingleEntryMacro() {
        assertMacroExpansion(
            """
            extension EnvironmentValues {
                @SingleEntry var foo: Foo = Foo()
            }
            """,
            expandedSource: """
            extension EnvironmentValues {
                var foo: Foo {
                    get {
                        self[FooKey.self]
                    }
                    set {
                        self[FooKey.self] = newValue
                    }
                }

                struct FooKey: EnvironmentKey {
                    static let defaultValue: Foo = Foo()
                }
            }
            """,
            macros: ["SingleEntry": SingleEntryMacro.self]
        )
    }
}
