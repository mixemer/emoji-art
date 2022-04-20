//
//  EmojiArtDocumentVM.swift
//  EmojiArt
//
//  Created by mixemer on 3/27/22.
//

import SwiftUI

class EmojiArtDocumentVM: ObservableObject {
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            scheduleAutosave()
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    private var autoSaverTimer: Timer?
    private func scheduleAutosave() {
        autoSaverTimer?.invalidate()
        autoSaverTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalessingInterval, repeats: false) { _ in
            self.autosave()
        }
    }
    
    private struct Autosave {
        static let filename = "Autosaved.emojiart"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
        static let coalessingInterval = 5.0
    }
    
    private func autosave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        let thisFunc = "\(String(describing: self)).\(#function)"
        
        do {
            let data: Data = try emojiArt.json()
            print("\(thisFunc) json = \(String(data: data, encoding: .utf8) ?? "nil" )")
            try data.write(to: url)
            print("\(thisFunc) success")
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisFunc) encodingError = \(encodingError)")
        } catch {
            print("\(thisFunc) error = \(error)")
        }
    }
    
    init() {
        if let url = Autosave.url, let autoSavedEmojiArt = try? EmojiArtModel(url: url) {
            emojiArt = autoSavedEmojiArt
            fetchBackgroundImageDataIfNecessary()
        }else {
            emojiArt = EmojiArtModel()
        }
//        emojiArt.addEmoji("😀", at: (x: 200, y: 100), size: 100)
//        emojiArt.addEmoji("😷", at: (x: -100, y: 200), size: 100)
//        emojiArt.addEmoji("🦠", at: (x: 0, y: 0), size: 100)
    }
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    // MARK: - selectedEmojis
    @Published var selectedEmojiIds: Set<Int> = []
    
    func toggleMatching(_ emojiId: Int) {
        selectedEmojiIds.toggleMatching(emojiId)
    }
    
    // MARK: - Background
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            // fetch the url
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil {
                            self?.backgroundImage = UIImage(data: imageData!)
                        }
                    }
                }
            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    // MARK: - Intends
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
        print("background \(background)")
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func moveEmojiWithId(_ emojiId: Int, by offset: CGSize) {
        if let index = emojiArt.emojis.first(where: { $0.id ==  emojiId }) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func moveSelectedEmojis(by offset: CGSize) {
        for emojiId in selectedEmojiIds {
            moveEmojiWithId(emojiId, by: offset)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
    
    func scaleEmojiWithId(_ emojiId: Int, by scale: CGFloat) {
        if let index = emojiArt.emojis.first(where: { $0.id ==  emojiId }) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
    
    func scaleSelectedEmojis(by scale: CGFloat) {
        for emojiId in selectedEmojiIds {
            scaleEmojiWithId(emojiId, by: scale)
        }
    }
    
    func removeSelectedEmojis() {
        for emojiId in selectedEmojiIds {
            emojiArt.emojis.removeAll(where: { $0.id == emojiId })
        }
        selectedEmojiIds.removeAll()
    }
}
