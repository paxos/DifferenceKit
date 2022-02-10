import Cocoa
import DifferenceKit

final class ShuffleEmoticonViewController: NSViewController {
    @IBOutlet private weak var collectionView: NSCollectionView!
    @IBOutlet private weak var tableView: NSTableView!

    private var data = (0x1F600 ... 0x1F602).compactMap { UnicodeScalar($0).map(String.init) }
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

    @IBAction func shufflePress(_ button: NSButton) {
        // Remove middle element
        var oldData = data
        let middleElement = data.remove(at: 1)

        // Apply changes manually
        var changeset = StagedChangeset(source: oldData, target: data)
        tableView.reload(using: changeset, with: .effectFade) { data in
            self.data = data
        }

        // Step 2
        oldData = data
        // Now swap element 0 and element 1, insert middle element back at position 0
        let tmp = data[0]
        data[0] = data[1]
        data[1] = tmp

        data.insert(middleElement, at: 1)

        // Apply changes manually
        changeset = StagedChangeset(source: oldData, target: data)
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
