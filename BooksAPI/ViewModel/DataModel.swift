//
//  DataModel.swift
//  BooksAPI
//
//  Created by Assem on 5/13/21.
//

import SwiftyJSON
import SDWebImageSwiftUI
import SwiftUI

class DataModel {
    
    private var dataTask: URLSessionDataTask?
    
    func loadBooks(searchString: String, completion: @escaping(([Book]) -> Void)) {
        dataTask?.cancel()
        guard let url = buildUrl(forTerm: searchString) else {
            completion([])
            return
        }
        dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion([])
                return
            }
            if let bookResponse = try? JSONDecoder().decode(BookResponse.self, from: data) {
                completion(bookResponse.books)
            }
        }
        dataTask?.resume()
    }
    
    private func buildUrl(forTerm searchString: String) -> URL? {
        guard !searchString.isEmpty else { return nil }
        let urlString = searchString.replacingOccurrences(of: " ", with: "+").lowercased()
        let queryItems = [
            URLQueryItem(name: "q", value: "\(urlString)+intitle")
        ]
        var components = URLComponents(string: "https://www.googleapis.com/books/v1/volumes")
        components?.queryItems = queryItems
        return components?.url
    }
}

//    func loadBooks(searchString: String, completion: @escaping(([Book]) -> Void)) {
//        guard !searchString.isEmpty else { return }
//        let urlString = buildUrl(searchString: searchString)
//        let session = URLSession(configuration: .default)
//        guard let url = urlString else { return }
//        session.dataTask(with: url) { data, _, error in
//            if error != nil {
//                print(error?.localizedDescription)
//                return
//            }
//
//
//            let json = try! JSON(data: data!)
//
//            let items = json["items"].array ?? []
//
//            for item in items {
//
//                let title = item["volumeInfo"]["title"].stringValue
//                let authors = item["volumeInfo"]["authors"].array ?? []
//                let description = item["volumeInfo"]["description"].stringValue
//                let imageUrl = item["volumeInfo"]["imageLinks"]["thumbnail"].stringValue
//                var author = ""
//
//                for a in authors {
//                    author += "\(a.stringValue)"
//                }
//
//                DispatchQueue.main.async {
//                    self.data.append(Book(title: title, authors: author, description: description, imageUrl: imageUrl))
//                }
//                completion(self.data)
//
//            }
//        }.resume()
//    }
//
//    private func buildUrl(searchString: String) -> URL? {
//        guard !searchString.isEmpty else { return nil }
//        let queryItems = [
//            URLQueryItem(name: "q", value: "\(searchString)+intitle")
//        ]
//        var components = URLComponents(string: "https://www.googleapis.com/books/v1/volumes")
//        components?.queryItems = queryItems
//        print(components?.url)
//        return components?.url
//    }
//



struct BookResponse: Decodable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case books = "items"
    }
    let id = UUID()
    let books: [Book]
}

struct Book: Decodable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case bookId = "id", selfLink, volumeInfo, accessInfo
    }
    
    let id = UUID()
    let bookId: String
    let selfLink: String
    let volumeInfo: BookInfo
    let accessInfo: AccessInfo
}

struct AccessInfo: Decodable, Identifiable {
    let id = UUID()
    let webReaderLink: String
}

struct BookInfo: Decodable, Identifiable {
    let id = UUID()
    //    let authors: [[Any:Any]]
    let title: String
    let subtitle: String?
    let publishedDate: String
    let imageLinks: ImageLinks
}

struct ImageLinks: Decodable {
    enum CodingKeys: String, CodingKey {
        case image = "thumbnail"
    }
    let image: String
}

class BookViewModel: Identifiable, ObservableObject {
    let id = UUID()
    let title: String
    let description: String?
    let imageUrl: String
    let readerLink: String
    let bookId: String
    let bookLink: String
    
    init(book: Book) {
        self.bookId = book.bookId
        self.bookLink = book.selfLink
        self.title = book.volumeInfo.title
        self.description = book.volumeInfo.subtitle
        self.readerLink = book.accessInfo.webReaderLink
        self.imageUrl = book.volumeInfo.imageLinks.image
    }
}
