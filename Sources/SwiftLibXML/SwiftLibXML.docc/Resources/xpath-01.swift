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

    // Select all title elements anywhere in the document.
    // XPath returns element nodes only — no text-node filtering needed.
    if let titles = document.xpath("//title") {
        for title in titles {
            print(title.content)
        }
    }
    // Clean Code
    // The Swift Programming Language
}
