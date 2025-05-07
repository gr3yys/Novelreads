// BookManager.swift
// MyApp
//
// Created by greys on 10/26/24.

import SwiftUI
import Combine

class BookManager: ObservableObject {
    @Published var bookmarkedBooks: [Book] = []
    @Published var bookshelf: [String: [Book]] = [:] // Store shelves as a dictionary of arrays of books
    @Published var shelves: [String: [Book]] = [:]
    @Published var completedBooks: [CompletedBook] = []
    
    private let bookshelfKey = "bookshelfData" // Key for storing in UserDefaults
    
    init() {
        loadBookshelfData() // Load bookshelf data when the app starts
        loadShelvesFromUserDefaults()
        }
    
    // MARK: - Bookmarking Functions
    
    func toggleBookmark(for book: Book) {
        if let index = bookmarkedBooks.firstIndex(where: { $0.id == book.id }) {
            bookmarkedBooks.remove(at: index)
        } else {
            var newBook = book
            newBook.bookmarkDate = Date()
            bookmarkedBooks.append(newBook)
        }
    }
    
    func isBookmarked(_ book: Book) -> Bool {
        return bookmarkedBooks.contains(where: { $0.id == book.id })
    }

    func bookmark(book: Book) {
        if !bookmarkedBooks.contains(where: { $0.id == book.id }) {
            bookmarkedBooks.append(book)
        }
    }
        
    func unbookmark(book: Book) {
        bookmarkedBooks.removeAll(where: { $0.id == book.id })
    }
    
    func updatePagesRead(for book: Book, with pages: Int) {
        if let index = bookmarkedBooks.firstIndex(where: { $0.id == book.id }) {
            bookmarkedBooks[index].pagesRead += pages
        }
    }

    // MARK: - Bookshelf Functions
    
    func addBook(to shelf: String, book: Book) {
        if shelves[shelf] != nil {
            shelves[shelf]?.append(book)
        } else {
            shelves[shelf] = [book] // If the shelf doesn't exist, create it
        }
        saveShelvesToUserDefaults() // Ensure data is persisted
    }


    func getShelfNames() -> [String] {
        return Array(bookshelf.keys)
    }
    
    // Save shelves data to UserDefaults using JSON encoding
        func saveShelvesToUserDefaults() {
            if let encoded = try? JSONEncoder().encode(shelves) {
                UserDefaults.standard.set(encoded, forKey: "shelves") // Store the encoded data
            }
        }

        // Load shelves data from UserDefaults using JSON decoding
        func loadShelvesFromUserDefaults() {
            if let data = UserDefaults.standard.data(forKey: "shelves"),
               let decoded = try? JSONDecoder().decode([String: [Book]].self, from: data) {
                shelves = decoded // Load the saved shelves data
            }
        }

    func removeBookFromShelf(_ book: Book, shelf: String) {
        if let index = bookshelf[shelf]?.firstIndex(where: { $0.id == book.id }) {
            bookshelf[shelf]?.remove(at: index)
            saveBookshelfData() // Save after modifying bookshelf
        }
    }

    func getBooks(for shelf: String) -> [Book] {
            return shelves[shelf] ?? [] // Return an empty array if no books exist for the shelf
        }

    // MARK: - Renaming Shelves
    
    func renameShelf(oldName: String, newName: String) {
        guard let books = bookshelf[oldName], !newName.isEmpty else { return }
        
        // Remove the old shelf and add the renamed shelf
        bookshelf[oldName] = nil
        bookshelf[newName] = books
        
        // Notify SwiftUI about the change
        objectWillChange.send()  // Manually trigger a UI update
        
        saveBookshelfData() // Save after renaming shelf
    }
    
    // MARK: - Finished Books
    
    // Add a book to the completed books list along with the completion date
        func addBookToCompleted(book: Book) {
            let completedBook = CompletedBook(book: book, completionDate: Date())
            completedBooks.append(completedBook)
            
            // Optionally, sort the books to keep the list ordered by completion date
            completedBooks.sort { $0.completionDate > $1.completionDate }
        }

        func getCompletedBooks() -> [CompletedBook] {
            return completedBooks
        }
    
    // MARK: - Persistence
    
    // Save bookshelf data to UserDefaults
    private func saveBookshelfData() {
        if let data = try? JSONEncoder().encode(bookshelf) {
            UserDefaults.standard.set(data, forKey: bookshelfKey)
        }
    }
    
    // Load bookshelf data from UserDefaults
    private func loadBookshelfData() {
        if let data = UserDefaults.standard.data(forKey: bookshelfKey),
           let decodedBookshelf = try? JSONDecoder().decode([String: [Book]].self, from: data) {
            bookshelf = decodedBookshelf
        }
    }
}

// store completed book with a date
struct CompletedBook {
    let book: Book
    let completionDate: Date
}
