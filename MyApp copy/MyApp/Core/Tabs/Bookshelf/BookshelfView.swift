//
// BookshelfView.swift
// My App
//
//

import SwiftUI

struct BookshelfView: View {
    @State private var rating: Double = 0
    @State private var cards: [String] = []
    @State private var isShowingNewShelfModal = false
    @State private var newShelfName = ""
    @EnvironmentObject var bookManager: BookManager

    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("My Bookshelf")
                        .font(.custom("Avenir-Heavy", size: 18))
                        .foregroundColor(Color(hex: "26344f"))
                }
                .padding(.top)

                // MARK: -  In Progress section
                HStack {
                    Text("In Progress")
                        .font(.custom("Avenir-Heavy", size: 18))
                        .foregroundColor(Color(hex: "26344f"))
                    Spacer()
                }
                .padding()

                // MARK: -  Horizontal scroll for bookmarked books
                VStack(alignment: .center) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: -40) {
                            ForEach(bookManager.bookmarkedBooks) { book in
                                NavigationLink(destination: ReadingLog(
                                    imageName: book.imageName,
                                    title: book.title,
                                    author: book.author,
                                    book: book,
                                    startDate: book.bookmarkDate ?? Date(),
                                    pagesRead: book.pagesRead
                                )) {
                                    VStack {
                                        Image(book.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 160, height: 160)
                                            .shadow(color: Color(hex: "26344f").opacity(0.25), radius: 5, x: 0, y: 2)
                                        ProgressBar(progress: calculateProgress(for: book))
                                            .frame(width: 105, height: 8)
                                            .padding(.top, 5)
                                    }
                                }
                            }
                        }
                    }
                }

                // MARK: -  Shelves Section
                HStack {
                    Text("Shelves")
                        .font(.custom("Avenir-Heavy", size: 18))
                        .foregroundColor(Color(hex: "26344f"))
                    Spacer()

                    // MARK: -  Button to create new shelf
                    Button(action: {
                        isShowingNewShelfModal.toggle()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(Color(hex: "26344f"))
                    }
                }
                .padding()

                // MARK: -  Display shelves and their books
                VStack(alignment: .leading, spacing: -15) {
                    ForEach(cards.indices, id: \.self) { index in
                        VStack {
                            // Shelf name editing and book display
                            NavigationLink(destination: ShelfDetailView(shelfName: cards[index], rating: $rating)) { // Pass rating as a binding
                                HStack {
                                    Image(systemName: "bookmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(Color(hex: "26344f"))
                                    TextField("Bookshelf name", text: $cards[index])
                                        .padding()
                                        .background(Color.white)
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                        .onChange(of: cards[index]) { newValue in
                                            // Update shelf name in BookManager
                                            let oldName = cards[index] // Store the current name before it changes
                                            if let existingShelf = bookManager.getShelfNames().first(where: { $0 == oldName }) {
                                                                bookManager.renameShelf(oldName: existingShelf, newName: newValue)
                                            }
                                        }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(hex: "26344f"), lineWidth: 1))
                            }
                        }
                        .padding(.bottom, 5)
                    }
                    .padding(12)
                    .foregroundColor(Color(hex: "26344f"))
                }
            }
            .onAppear {
                self.cards = bookManager.getShelfNames()
            }
            .sheet(isPresented: $isShowingNewShelfModal) {
                VStack(alignment: .leading) {
                    Text("Enter New Shelf Name")
                        .font(.title2)
                        .padding()

                    TextField("Shelf Name", text: $newShelfName)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity)

                    Button(action: {
                        createNewCard()
                        isShowingNewShelfModal = false
                    }) {
                        Text("Create Shelf")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()
            }
        }
    }

    // MARK: -  Calculate the reading progress percentage
    private func calculateProgress(for book: Book) -> Double {
        return book.pages > 0 ? Double(book.pagesRead) / Double(book.pages) * 100 : 0
    }

    // MARK: -  Create a new shelf (card) and add it to the BookManager's bookshelf
    private func createNewCard() {
        if newShelfName.isEmpty {
            return
        }
        cards.append(newShelfName)  // Add new shelf to the local array (UI)
        bookManager.bookshelf[newShelfName] = []  // Add the new shelf to the BookManager
    }
}

// MARK: -  Display Books in the corresponding shelves
struct ShelfDetailView: View {
    let shelfName: String
    @EnvironmentObject var bookManager: BookManager
    @Binding var rating: Double  // Accept rating as a binding
    @State private var activeButtonIndex: Int = 0
    
    let buttonTitles = ["All", "Title", "Author", "Date Started", "Date Finished"]
    let defaultColor = Color(hex: "26344f").opacity(0.15)
    let textColor = Color(hex: "26344f").opacity(0.5)

    var body: some View {
        let booksInShelf = bookManager.getBooks(for: shelfName)
        VStack(spacing: 15) {
            // MARK: - Filters
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(0..<buttonTitles.count, id: \.self) { index in
                        Button(action: {
                            activeButtonIndex = index
                        }) {
                            Text(buttonTitles[index])
                                .padding(.horizontal, 16)
                                        .frame(height: 40)
                                .background(activeButtonIndex == index ? Color(hex: "698bcc") : defaultColor)
                                .foregroundColor(activeButtonIndex == index ? Color.white : textColor)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                    }
                }
                
                        }
            ForEach(booksInShelf) { book in
                NavigationLink(destination: BookDetailsView(book: book)) {
                    HStack {
                        // Book image
                        Image(book.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .padding(.horizontal, -15)

                        VStack(alignment: .leading, spacing: 4) {
                            // Book title
                            Text(book.title)
                                .font(.custom("Avenir-Heavy", size: 18))
                                .foregroundColor(Color(hex: "26344f"))
                            
                            // Book author
                            Text(book.author)
                                .font(.custom("Avenir-Regular", size: 16))
                                .foregroundColor(Color(hex: "26344f"))
                                .opacity(0.7)

                            // Rating view
                            YourRating(rating: $rating)
                                .scaleEffect(0.9)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Chevron icon
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(hex: "698bcc"))
                    }
                    .padding(12)
                    .foregroundColor(Color(hex: "26344f"))
                    .background(Color.white)
                    .cornerRadius(5)
                    .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)

                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.top)
        .padding(.horizontal)
        .padding(.bottom, 0)
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationBarTitle(shelfName, displayMode: .inline)
    }
}

// MARK: -  Preview
#Preview {
    BookshelfView()
        .environmentObject(BookManager())
}
