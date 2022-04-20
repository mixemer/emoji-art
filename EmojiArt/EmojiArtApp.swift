//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by mixemer on 3/27/22.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let documentVM = EmojiArtDocumentVM()
    let paletteStore = PaletteStore(named: "Default")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: documentVM)
        }
    }
}
