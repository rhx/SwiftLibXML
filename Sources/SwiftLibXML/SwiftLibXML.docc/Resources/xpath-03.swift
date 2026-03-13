import Foundation

func queryAtomTitles() {
    let xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <feed xmlns:atom="http://www.w3.org/2005/Atom">
      <atom:entry>
        <atom:title>SwiftLibXML 2.0 Released</atom:title>
        <atom:updated>2026-01-15T00:00:00Z</atom:updated>
      </atom:entry>
    </feed>
    """

    guard let document = XMLDocument(data: Data(xml.utf8)) else { return }

    // Register the namespace prefix explicitly.
    let ns: [(prefix: String, href: String)] = [
        ("atom", "http://www.w3.org/2005/Atom")
    ]
    if let titles = document.xpath("//atom:title", namespaces: ns) {
        for title in titles {
            print(title.content)
        }
    }
    // SwiftLibXML 2.0 Released
}
