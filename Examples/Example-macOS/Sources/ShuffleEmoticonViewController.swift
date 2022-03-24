import Cocoa
import DifferenceKit

final class ShuffleEmoticonViewController: NSViewController {
    @IBOutlet private var collectionView: NSCollectionView!
    @IBOutlet private var tableView: NSTableView!

    private var data = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    private var dataInput: [String] {
        get { return data }
        set {
            let changeset = StagedChangeset(source: data, target: newValue)
            collectionView.reload(using: changeset) { data in
                self.data = data
            }
            tableView.reload(using: changeset, with: .effectFade) { data in
                self.data = data
            }
        }
    }

    func checkForDuplicates() {
        for row in 0 ... tableView.numberOfRows {}
    }

    var elementBuffer: [String] = []
    @IBAction func shufflePress(_ button: NSButton) {
        let oldData = data
        if Int.random(in: 1 ..< 100) > 50 {
            for _ in 0 ... 3 { // Do it multiple times
                if let randomElement = data.randomElement() {
                    elementBuffer.append(randomElement)
                    data.removeAll(where: { $0 == randomElement })
                }
            }
        }

        // Add back
        if Int.random(in: 1 ..< 100) > 50 {
            for element in elementBuffer {
                data.insert(element, at: Int.random(in: 0 ... data.count))
            }
            elementBuffer.removeAll()
        }

        // Apply changes manually
        print("new data: ", data)
        let dups = Dictionary(grouping: data, by: {$0}).filter { $1.count > 1 }.keys
        print("dups: ", dups)
        
        let changeset = StagedChangeset(source: oldData, target: data)
        tableView.reload(using: changeset, with: .effectFade) { data in
            self.data = data
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        tableView.selectionHighlightStyle = .none
        collectionView.register(ShuffleEmoticonCollectionViewItem.self, forItemWithIdentifier: ShuffleEmoticonCollectionViewItem.itemIdentifier)
    }
}

extension ShuffleEmoticonViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: ShuffleEmoticonCollectionViewItem.itemIdentifier, for: indexPath) as! ShuffleEmoticonCollectionViewItem
        item.emoticon = data[indexPath.item]
        return item
    }
}

extension ShuffleEmoticonViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        print("viewFor:row", row, data[row])
        let view = tableView.makeView(withIdentifier: NSTableCellView.itemIdentifier, owner: tableView) as! NSTableCellView
        view.textField?.stringValue = data[row]
        return view
    }
}

private extension NSTableCellView {
    static var itemIdentifier: NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier(String(describing: self))
    }
}
