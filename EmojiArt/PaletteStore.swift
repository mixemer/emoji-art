//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by mixemer on 4/19/22.
//

import SwiftUI

struct Palette: Identifiable, Codable {
    var name: String
    var emojis: String
    var id: Int
    
    fileprivate init(name: String, emojis: String, id: Int) {
        self.name = name
        self.emojis = emojis
        self.id = id
    }
}

class PaletteStore: ObservableObject {
    let name: String
    
    @Published var palettes = [Palette]() {
        didSet {
            storeInUserDefaults()
        }
    }
    
    init (named name: String) {
        self.name = name
        restoreFromUserDefaults()
        
        if palettes.isEmpty {
            print("using defined emojis")
            insertPalette(named: "Vehicles", emojis: "πππππππππ΅ππ πππβοΈπ«π")
            insertPalette(named: "Sport", emojis: "β½οΈππβΎοΈπ₯πΎπππ₯πΈπͺππΉπ·πΌβ·")
            insertPalette(named: "Food", emojis: "πππ₯¬π§π§ππππ₯«ππ")
            insertPalette(named: "Animals", emojis: "πΆπ¦π―π½π»πΉπππ¦π¦π")
        } else {
            print("using stored emojis")
        }
    }
    
    private var userDefaultsKey: String {
        "PaletteStore" + name
    }
    private func storeInUserDefaults() {
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes), forKey: userDefaultsKey)
    }
    
    private func restoreFromUserDefaults() {
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedPalettes = try? JSONDecoder().decode(Array<Palette>.self, from: jsonData) {
            palettes = decodedPalettes
        }
    }
    
    // MARK: - Intends
    
    func palette(at index: Int) -> Palette {
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    @discardableResult
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    
    func insertPalette(named name: String, emojis: String? = nil, at index: Int = 0) {
        let unique = (palettes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        
        let palette = Palette(name: name, emojis: emojis ?? "", id: unique)
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
}


