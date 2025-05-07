// Books.Swift
// Book Model

import SwiftUI

struct Books: Identifiable {
    var id: UUID = UUID()
    var imageName: Image
    var name: String
    var author: String
    var rating: Double
    var description: String
    var pages: Int
    var publisher: String
    var isbn: String
    var released: String
    var genres: [String]
    var numberOfRatings: Int
    var ratingsDistribution: [Int]
    var about: String
    var isBookmarked: Bool
}
