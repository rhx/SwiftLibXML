import Foundation

func queryTitles() {
    let xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <catalogue>
      <book id="1">
        <title>Clean Code</title>
        <author>Robert C. Martin</author>
      </book>
      <book id="2">
        <title>The Swift Programming Language</title>
        <author>Apple Inc.</author>
      </book>
    </catalogue>
    """

    guard let document = XMLDocument(data: Data(xml.utf8)) else { return }

    // An attribute predicate narrows the selection to a specific book.
    if let books = document.xpath("//book[@id='1']") {
        for book in books {
            let title = book.children.first(where: { $0.name == "title" })?.content ?? ""
            print(title)
        }
    }
    // Clean Code
}
