import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SingleEntryMacros: AccessorMacro, PeerMacro {
    
    // This replaces the variable's accessors (removes the initializer, adds get/set)
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
            return []
        }
        
        let variableName = pattern.identifier.text
        let keyName = "\(variableName.capitalized)Key"
        
        return [
            AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
                "self[\(raw: keyName).self]"
            },
            AccessorDeclSyntax(accessorSpecifier: .keyword(.set)) {
                "self[\(raw: keyName).self] = newValue"
            }
        ]
    }
    
    // This adds the EnvironmentKey struct as a peer
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
              let typeAnnotation = binding.typeAnnotation?.type,
              let defaultValue = binding.initializer?.value else {
            return []
        }
        
        let variableName = pattern.identifier.text
        let keyName = "\(variableName.capitalized)Key"
        
        let environmentKey: DeclSyntax = """
            struct \(raw: keyName): EnvironmentKey {
                static let defaultValue: \(typeAnnotation)= \(defaultValue)
            }
            """
        
        return [environmentKey]
    }
}

@main
struct SingleEntryMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SingleEntryMacros.self,
    ]
}
