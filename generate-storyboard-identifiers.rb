require "nokogiri"

path = ARGV[0]
if path.nil?
  puts "☠️  No path specified."
  exit
end

filename = ARGV[1] || "StoryboardIdentifiers.swift"

# Parse the storyboards
def parseStoryboards(path, filename)
  puts "🏁 Generating storyboard identifiers...\n"
  
  storyboardIdentifiers = []
  viewControllerIdentifiers = []
  segueIdentifiers = []
  cellIdentifiers = []

  storyboards = Dir.glob(File.join(path, "**", "*.storyboard"))
  storyboards.each do |storyboard|
    puts "   #{storyboard}\n"
    content = File.open(storyboard) { |f| Nokogiri::XML(f) }

    fileBasename = File.basename(storyboard, ".*")
    storyboardIdentifiers.push(fileBasename)

    viewControllerIdentifiers += findIdentifiers(content, "storyboardIdentifier", 'viewController', 'navigationController', 'tabBarController', 'tableViewController', 'collectionViewController')
    segueIdentifiers += findIdentifiers(content, "identifier", 'segue')
    cellIdentifiers += findIdentifiers(content, "reuseIdentifier", 'tableViewCell', 'collectionViewCell','collectionReusableView')
  end

  fileContent = "import UIKit\n\n"
  fileContent << generateIdentifiers("StoryboardIdentifier", storyboardIdentifiers.uniq.sort) + "\n"
  fileContent << generateIdentifiers("ViewControllerIdentifier", viewControllerIdentifiers.uniq.sort) + "\n"
  fileContent << generateIdentifiers("SegueIdentifier", segueIdentifiers.uniq.sort) + "\n"
  fileContent << generateIdentifiers("CellIdentifier", cellIdentifiers.uniq.sort) + "\n"
  fileContent << generateStoryboardExtension(storyboardIdentifiers.uniq.sort)

  file = path + '/' + filename
  File.open(file, 'w') { |file| file.write(fileContent) }

  puts "🎉 Done!"
end


def findIdentifiers(content, property, *nodes)
  identifiers = []
  content.css(*nodes).each do |node|
    identifier = node[property]
    identifiers.push(identifier) if identifier.nil? == false
  end
  return identifiers
end


def generateIdentifiers(type, identifiers)
  maxLength = identifiers.map { |i| i.length }.max

  str = "struct #{type} {\n"  
  identifiers.each { |identifier| 
    propertyName = identifier.ljust(maxLength).sub(/[a-z]/i) { $&.downcase }
    str << "    static let #{propertyName} = \"#{identifier}\"\n" 
  }
  str << "}\n"
  return str
end

def generateStoryboardExtension(identifiers)
  str = "extension UIStoryboard {\n"
  identifiers.each { |identifier|
    propertyName = identifier.sub(/[a-z]/i) { $&.downcase }
    str << "    class var #{propertyName}: UIStoryboard { return UIStoryboard.init(name: StoryboardIdentifier.#{propertyName}, bundle: nil) }\n"
  }
  str << "}\n"
  return str  
end


parseStoryboards(path, filename)
