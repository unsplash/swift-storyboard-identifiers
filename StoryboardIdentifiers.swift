import UIKit

struct StoryboardIdentifier {
    static let template = "Template"
}

struct ViewControllerIdentifier {
    static let grid           = "Grid"
    static let gridNavigation = "GridNavigation"
    static let item           = "Item"
    static let list           = "List"
    static let listNavigation = "ListNavigation"
    static let tabBar         = "TabBar"
}

struct SegueIdentifier {
    static let addItem  = "AddItem"
    static let viewItem = "ViewItem"
}

struct CellIdentifier {
    static let gridItem = "GridItem"
    static let listItem = "ListItem"
}

extension UIStoryboard {
    class var template: UIStoryboard { return UIStoryboard.init(name: StoryboardIdentifier.template, bundle: nil) }
}
