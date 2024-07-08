enum HTMLTag: String {
  case a
  case b
  case ul
  case li
}

struct HTMLStringData {
  let text: String
  let links: [LinkData]
  let boldText: [String]
  let listItems: [String]
}

struct LinkData {
  let text: String
  let href: String?
}

func parseHTMLString(_ htmlString: String) -> HTMLStringData {
  var text = ""
  var currentTag: HTMLTag? = nil
  var currentLinkHref: String? = nil
  var links: [LinkData] = []
  var boldText: [String] = []
  var listItems: [String] = []
  var inList = false
  
  for char in htmlString {
    switch char {
    case "<":
      currentTag = nil
      currentLinkHref = nil
    case ">":
      if let tag = currentTag {
        switch tag {
        case .a:
          currentLinkHref = nil
        case .a where text.isEmpty: // Handle empty content within `<a>` tags
          links.append(LinkData(text: "", href: currentLinkHref))
          text = ""
        case .a:
          if let content = text.trimmingCharacters(in: .whitespacesAndNewlines) {
            links.append(LinkData(text: content, href: currentLinkHref))
            text = ""
          }
        case .b:
          currentTag = nil
        case .b:
          if let content = text.trimmingCharacters(in: .whitespacesAndNewlines) {
            boldText.append(content)
            text = ""
          }
        case .ul:
          inList = true
        case .ul: // Handle empty list
          listItems.append("")
        case .li:
          if inList {
            listItems.append(text.trimmingCharacters(in: .whitespacesAndNewlines))
            text = ""
          }
        default:
          break
        }
      }
    case " ":
      if currentTag == .a {
        currentLinkHref = "" // Start capturing href after the opening `<a>` tag
      }
    default:
      if currentTag == nil {
        text.append(char)
      } else if currentTag == .a {
        currentLinkHref?.append(char) // Append characters to href while in `<a>` tag
      }
    }
  }
  
  return HTMLStringData(text: text.trimmingCharacters(in: .whitespacesAndNewlines), links: links, boldText: boldText, listItems: listItems)
}

// Example usage
let htmlString = "This is an example with <a href=\"https://www.example.com\">link</a> and <b>bold text</b>\n<ul>\n\t<li>Coffee</li>\n</ul>"
let data = parseHTMLString(htmlString)

print("Text:", data.text)
for link in data.links {
  print("Link Text:", link.text)
  print("Link Href:", link.href ?? "No Href")
}
print("Bold Text:", data.boldText)
print("List Items:", data.listItems)
