# SingleEntry Macro

A Swift macro that simplifies creating SwiftUI Environment values with proper singleton behavior.

## The Problem with @Entry

SwiftUI's built-in `@Entry` macro has a significant issue: it creates new instances every time you access the environment value, rather than using a single shared instance.

### Example of the Problem

```swift
extension EnvironmentValues {
    @Entry var bar: Bar = Bar()
}

struct Bar {
    let uuid: UUID = .init()
    
    init() {
        print("****** Bar \(uuid.uuidString)")
    }
}

struct ViewOne: View {
    @Environment(\.bar) var foo
    var body: some View {
        NavigationView {
            VStack {
                Text("View One \(foo.uuid.uuidString)")
                NavigationLink(destination: ViewTwo()) {
                    Text("Go to View Two")
                }
            }
        }
    }
}

struct ViewTwo: View {
    @Environment(\.bar) var foo
    var body: some View {
        Text("View Two \(foo.uuid.uuidString)")
    }
}
```

Just navigating between these two screens produces five different instances:

```swift
****** Bar BF07CB3E-8064-4EE8-B155-BF7119BD6F73
****** Bar 27207B40-CEAC-4D71-80BA-C0723BCA1646
****** Bar B8A3C07B-82D7-4C08-8042-A0D8FDAAB965
****** Bar AEAF84C9-EED6-48BE-8CB0-00E8E48DD6B7
****** Bar 2DBB536E-F948-4627-823D-2428E1142CE2
```

### Why This Happens
When you expand the @Entry macro, it looks like this:

```swift
extension EnvironmentValues {
    var bar: Bar {
        get {
            self[__Key_bar.self]
        }
        set {
            self[__Key_bar.self] = newValue
        }
    }
    
    private struct __Key_bar: SwiftUICore.EnvironmentKey {
        @__EntryDefaultValue
        static var defaultValue: Bar = Bar()
    }
}
```

The problem is the @__EntryDefaultValue macro, which expands to:

```swift
static var defaultValue: Bar {
    get {
        Bar()  // Creates a new instance every time!
    }
}
```

So what looks like a stored property `= Bar()` is actually a computed property that creates a new instance on every access.

### The Solution: @SingleEntry

`@SingleEntry` generates the correct code with a true stored property:

```swift
extension EnvironmentValues {
    @SingleEntry var bar: Bar = Bar()
}
```

Expands to:
```swift
extension EnvironmentValues {
    var bar: Bar {
        get {
            self[BarKey.self]
        }
        set {
            self[BarKey.self] = newValue
        }
    }
    
    struct BarKey: EnvironmentKey {
        static var defaultValue: Bar = Bar()  // True stored property!
    }
}
```
With `@SingleEntry`, you get exactly **one instance** that's shared across your entire app, which is typically what you want for services, configuration objects, and other shared resources.

## Installation

### Swift Package Manager

#### Option 1: Xcode GUI
1. Open your project in Xcode
2. Go to **File** → **Add Package Dependencies...**
3. Enter the repository URL:
   ```
   https://github.com/jackvdp/SingleEntryMacro
   ```
4. Choose **"Up to Next Major Version"** and enter `1.0.0`
5. Click **Add Package**
6. Select **SingleEntry** and add it to your target

#### Option 2: Package.swift
Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SingleEntry.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["SingleEntry"]
    )
]
```