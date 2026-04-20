import Foundation
import Carbon

guard CommandLine.arguments.count > 1 else {
    print("Please provide an input source ID or language code.")
    exit(1)
}

let query = CommandLine.arguments[1]
let sourceList = TISCreateInputSourceList(nil, false).takeRetainedValue() as! [TISInputSource]

for source in sourceList {
    // 1. Check Input Mode ID (e.g. com.apple.inputmethod.TCIM.Pinyin)
    if let ptrMode = TISGetInputSourceProperty(source, kTISPropertyInputModeID) {
        let modeId = Unmanaged<CFString>.fromOpaque(ptrMode).takeUnretainedValue() as String
        if modeId == query {
            TISSelectInputSource(source)
            exit(0)
        }
    }
    
    // 2. Check Input Source ID (e.g. com.google.inputmethod.Japanese.base)
    if let ptrID = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) {
        let id = Unmanaged<CFString>.fromOpaque(ptrID).takeUnretainedValue() as String
        if id == query {
            TISSelectInputSource(source)
            exit(0)
        }
    }
    
    // 3. Check Language Code (e.g. en, fr, ko)
    if let ptrLangs = TISGetInputSourceProperty(source, kTISPropertyInputSourceLanguages) {
        let langs = Unmanaged<CFArray>.fromOpaque(ptrLangs).takeUnretainedValue() as! [String]
        if langs.contains(where: { $0.hasPrefix(query) }) {
            TISSelectInputSource(source)
            exit(0)
        }
    }
}

print("Not found")
exit(1)
