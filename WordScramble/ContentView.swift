//
//  ContentView.swift
//  WordScramble
//
//  Created by Denny Arfansyah on 08/01/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rooWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter you word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Text(score())
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        
                    }
                }
            }
            .navigationTitle(rooWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("Start Game") {
                    startGame()
                }
            }
        }
    }
    
    private func score() -> String {
        "Your have \(usedWords.count) right " + (usedWords.count < 2 ? "word" : "words")
    }
    
    private func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 2 else {
            wordError(errorTitle: "Word must longer", errorMessage: "Type more than 2 letter")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(errorTitle: "Word used already", errorMessage: "Be more original!")
            return
            
        }
        
        guard isPossible(word: answer) else {
            wordError(errorTitle: "Word are not possible", errorMessage: "You cant spell that word from '\(rooWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(errorTitle: "Word not recognized", errorMessage: "You cant just make them up!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    private func startGame() {
        newWord = ""
        usedWords.removeAll()
        if let fileURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let fileContents = try? String(contentsOf: fileURL) {
                let allWords = fileContents.components(separatedBy: "\n")
                rooWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from the bundle.")
    }
    
    private func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    private func isPossible(word: String) -> Bool {
        var tempWord = rooWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelled = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelled.location == NSNotFound
    }
    
    private func wordError(errorTitle: String, errorMessage: String) {
        self.errorTitle = errorTitle
        self.errorMessage = errorMessage
        self.showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
