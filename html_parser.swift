import Foundation

struct LinkData {
    let text: String
    let href: String?
}

struct HTMLStringData {
    var text: String
    var aTags: [LinkData]
    var bTags: [String]
    var lists: [[String]]
}

func parseHTMLString(_ htmlString: String) -> HTMLStringData {
    var aTags = [LinkData]()
    var bTags = [String]()
    var lists = [[String]]()

    // Regular expression for <a> tags
    let aTagPattern = "<a\\s+(?:[^>]*?\\s+)?href=[\"']([^\"']*)[\"'][^>]*>(.*?)<\\/a>"
    if let aTagRegex = try? NSRegularExpression(pattern: aTagPattern, options: []) {
        let matches = aTagRegex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count))
        for match in matches {
            if let hrefRange = Range(match.range(at: 1), in: htmlString),
               let textRange = Range(match.range(at: 2), in: htmlString) {
                let href = String(htmlString[hrefRange])
                let text = String(htmlString[textRange])
                aTags.append(LinkData(text: text, href: href))
            }
        }
    }

    // Regular expression for <b> tags
    let bTagPattern = "<b[^>]*>(.*?)<\\/b>"
    if let bTagRegex = try? NSRegularExpression(pattern: bTagPattern, options: []) {
        let matches = bTagRegex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count))
        for match in matches {
            if let range = Range(match.range(at: 1), in: htmlString) {
                bTags.append(String(htmlString[range]))
            }
        }
    }

    // Regular expression for <li> tags inside <ul> tags
    let ulTagPattern = "<ul>(.*?)<\\/ul>"
    let liTagPattern = "<li[^>]*>(.*?)<\\/li>"
    if let ulTagRegex = try? NSRegularExpression(pattern: ulTagPattern, options: .dotMatchesLineSeparators) {
        let ulMatches = ulTagRegex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count))
        for ulMatch in ulMatches {
            if let ulRange = Range(ulMatch.range(at: 1), in: htmlString) {
                let ulContent = String(htmlString[ulRange])
                var listItems = [String]()
                if let liTagRegex = try? NSRegularExpression(pattern: liTagPattern, options: []) {
                    let liMatches = liTagRegex.matches(in: ulContent, options: [], range: NSRange(location: 0, length: ulContent.utf16.count))
                    for liMatch in liMatches {
                        if let liRange = Range(liMatch.range(at: 1), in: ulContent) {
                            listItems.append(String(ulContent[liRange]))
                        }
                    }
                }
                lists.append(listItems)
            }
        }
    }

    // Remove <ul> and <li> tags from the original string to get plain text
    var text = htmlString
    text = text.replacingOccurrences(of: ulTagPattern, with: "", options: .regularExpression)
    text = text.replacingOccurrences(of: liTagPattern, with: "", options: .regularExpression)

    // Replace <a> and <b> tags with their inner content
    text = text.replacingOccurrences(of: aTagPattern, with: "$2", options: .regularExpression)
    text = text.replacingOccurrences(of: bTagPattern, with: "$1", options: .regularExpression)

    // Remove any remaining HTML tags
    let plainTextPattern = "<[^>]+>"
    text = text.replacingOccurrences(of: plainTextPattern, with: "", options: .regularExpression, range: nil).trimmingCharacters(in: .whitespacesAndNewlines)

    return HTMLStringData(text: text, aTags: aTags, bTags: bTags, lists: lists)
}

let htmlString = """
This is the list of drinks
<ul>
  <li>Coffee</li>
  <li>Tea</li>
  <li>Milk</li>
</ul>
<a href="http://example.com">html</a> <b>tag</b> and <b>other tags</b>
"""

let parsedData = parseHTMLString(htmlString)

print("Text: \(parsedData.text)")
print("aTags: \(parsedData.aTags)")
print("bTags: \(parsedData.bTags)")
print("Lists: \(parsedData.lists)")
