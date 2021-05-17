//
//  BooksListViewModel.swift
//  BooksAPI
//
//  Created by Assem on 5/13/21.
//

import Combine
import SwiftUI

class BooksListViewModel: ObservableObject {
    @Published public private(set) var books: [BookViewModel] = []
    @Published var searchString: String = ""
    
    private let dataModel: DataModel = DataModel()
    private var disposables = Set<AnyCancellable>()
    
    init() {
        $searchString
            .sink(receiveValue: loadBooks(searchString:))
            .store(in: &disposables)
    }
    
    
    func loadBooks(searchString: String) {
        books.removeAll()
        
        dataModel.loadBooks(searchString: searchString) { books in
            books.forEach { self.appendBook(book: $0) }
        }
    }
    
    private func appendBook(book: Book) {
        let bookViewModel = BookViewModel(book: book)
        DispatchQueue.main.async {
            self.books.append(bookViewModel)
        }
      }

}
