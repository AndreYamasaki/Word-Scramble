//
//  ViewController.swift
//  Project5
//
//  Created by user on 16/07/21.
//

import UIKit

class ViewController: UITableViewController {
    
    //MARK: - Attributes
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
// Challenge 3: Add a left bar button item that calls startGame(), so users can restart with a new word whenever they want to.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Start game", style: .plain, target: self, action: #selector(startGame))

        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            allWords = ["silkworm"]
        }

        startGame()
    }
    
    //MARK: - TableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }

    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    //MARK: - Methods

    @objc func promptForAnswer() {
        
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] action in
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }

        ac.addAction(submitAction)

        present(ac, animated: true)
    }

    func isPossible(word: String) -> Bool {
        
        var tempWord = title!.lowercased()

        for letter in word {
            if let position = tempWord.range(of: String(letter)) {
                tempWord.remove(at: position.lowerBound)
            } else {
                return false
            }
        }

        return true
    }

    func isOriginal(word: String) -> Bool {
        
        return !usedWords.contains(word)
    }

    func isReal(word: String) -> Bool {
        
//Challenge 1: Disallow answers that are shorter than three letters or are just our start word.
        guard word.count > 3 else {return false}
        
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }

    func submit(answer: String) {
        
        let lowerAnswer = answer.lowercased()


        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)

                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)

                    return
                } else {
                    showErrorMessage(errorTitle: "Word not recognised", errorMessage: "You can't just make them up, you know!")
                }
            } else {
                showErrorMessage(errorTitle: "Word used already", errorMessage: "Be more original!")
            }
        } else {
            showErrorMessage(errorTitle: "Word not possible", errorMessage: "You can't spell that word from '\(title!.lowercased())'!")
        }
    }
    
// Challenge 2 Refactor all the else statements we just added so that they call a new method called showErrorMessage().
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

