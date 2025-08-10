// Sources/SingleEntryMacro/SingleEntryMacro.swift
@attached(accessor)
@attached(peer, names: arbitrary)
public macro SingleEntry() = #externalMacro(module: "SingleEntryMacros", type: "SingleEntryMacro")
