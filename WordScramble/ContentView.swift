//
//  ContentView.swift
//  WordScramble
//
//  Created by RUEBEN on 8/31/22.
//

import SwiftUI

struct ContentView: View {
    @State private var score = 0
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    var body: some View {
        NavigationView {
            List {
                Text("Your Score is  \(score)")
                    .font(.headline)
                    .foregroundStyle(.blue)
                Section {
                    TextField("Enter your word", text: $newWord).textInputAutocapitalization(.none)
                }
                Section {
                    ForEach(usedWords, id:\.self) {word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityElement()
                        .accessibilityLabel(word)
                        .accessibilityHint("\(word.count) letters")
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button("New Word") {
                        startGame()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Start Game") {
                        resetGame()
                    }
                }
            })
            .alert(errorTitle, isPresented: $showingError) {
                Button("ok", role: .cancel){}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    
     // MARK: - ADD NEW WORD
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "🥴Word used aleady", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "😜Word not possible", message: "You cant spell that word from '\(rootWord)'!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "😫Word not recognized", message: "You cant just make them up, you know!")
            return
        }
        guard dissAllow(word: answer) else {
            wordError(title: "🤠Word is from the start word", message: "Be creative")
            return
        }
        
        guard isShort(word: answer) else {
            wordError(title: "😤Opps Word is too short", message: "Words should be greater than 3")
            return
        }
        withAnimation(.easeInOut){
            usedWords.insert(answer, at: 0)
            score = score + answer.count
        }
        newWord = ""
    }
    
     // MARK: - START GAME
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Failure to load start.txt file")
    }
    
     // MARK: - ISORIGINAL
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
     // MARK: - ISPOSSIBLE
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
     // MARK: - ISREAL
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
     // MARK: - WORDERROR
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
     // MARK: - DISSALLOW
    func dissAllow(word: String) -> Bool {
        !(word == rootWord)
        
    }
    
     // MARK: - ISSHORT
    func isShort(word: String) -> Bool {
        word.count >= 3
    }
    
     // MARK: - RESETGAME
    func resetGame() {
        usedWords.removeAll()
        score = 0
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
