import Cocoa
import DifferenceKit

final class ShuffleEmoticonViewController: NSViewController {
    @IBOutlet var collectionView: NSCollectionView!
    @IBOutlet var tableView: NSTableView!

    private var data = ["test", "is", "this", "working", "?"]
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

//    func checkForDuplicates() {
//
//        let vals = [String]()
//        for row in 0 ... tableView.numberOfRows {
//            vals.append(tableView.item)
//        }
//
//
//        let dups = Dictionary(grouping: ["1", "1", "2"], by: {$0}).filter { $1.count > 1 }.keys
//        print("dups: ", dups)
//    }

    func runScenarios() {
        let scenarios = [
            // failing
            (from: ["1", "2", "3"], to: ["1", "3", "4", "2"]), // Example where move relates to index of initial sets, so move needs to go first

            // Okay

            (from: ["1", "2", "3"], to: ["3", "2", "1"]),
            (from: ["1", "2", "3", "4"], to: ["4", "3", "2", "1"]),
            (from: ["1", "2", "3"], to: ["1", "2"]),
            (from: ["1", "2", "3"], to: ["1", "2", "3", "4"]),

            (from: ["1", "2", "3", "4", "5", "6", "7", "8", "9"], to: ["1", "3", "4", "2"]),
            (from: ["1", "2", "3", "4", "5", "6", "7", "8", "9"], to: ["1", "rofl", "4", "2", "lol"]),
            (from: ["1", "5", "2", "7", "8", "3", "4", "6", "9", "10"], to: ["2", "5", "1", "7", "8", "3", "4", "6", "9", "10"]),

            (from: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"], to: ["2", "5", "1", "7", "8", "3", "4", "6", "9", "10"]),
            (from: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"], to: ["2", "7", "1", "5", "8", "4", "9", "3", "6", "10"]),
            (from: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"], to: ["5", "3", "1", "7", "8", "9", "4", "2", "6", "10"]),
            (from: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"], to: ["5", "1", "7", "4", "2", "10"]),

            (from: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"], to: ["5", "1", "7", "4", "2", "10"]),

            (from: ["test", "is", "this", "working", "?"], to: ["5", "maybe", "test", "not", "sure", "?"]),
        ]

        for scenario in scenarios {
//            print("🫡 Running Scenario: \(scenario.from) -> \(scenario.to)")
            let result = runScenario(from: scenario.from, to: scenario.to)
            if scenario.to != result {
                print("🫡 Scenario FAILED ❌: \(scenario.from) -> \(scenario.to)")
            } else {
                print("🫡 Scenario OK ✅: \(scenario.from) -> \(scenario.to)")
            }
        }
    }

    func runScenario(from: [String], to: [String]) -> [String] {
        data = from
        tableView.reloadData()

        // This forces a "flush" of the changes
        tableView.layout()

        let changeset = StagedChangeset(source: from, target: to)
        tableView.reload(using: changeset, with: .effectFade) { data in
            print("applying data: ", data)
            self.data = data
        }

        return dataFromTableState()
    }

    func dataFromTableState() -> [String] {
        var data = [String]()
        if tableView.numberOfRows > 0 {
            for row in 0 ... tableView.numberOfRows - 1 {
                let valueOfView = (tableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! NSTableCellView).textField?.objectValue as! String
                data.append(valueOfView)
            }
        }
        return data
    }

//
//    func isDataInSync() -> Bool {
//        for row in 0 ... tableView.numberOfRows - 1 {
//            let valueOfView = (tableView.view(atColumn: 0, row: row, makeIfNecessary: false) as! NSTableCellView).textField?.objectValue as! String
//            if valueOfView != data[row] {
//                return false
//            }
//        }
//
//        return true
//    }

    private func doRandomThings() {
        let oldData = data
        if Int.random(in: 1 ..< 100) > 25 {
            for _ in 0 ... 3 { // Do it multiple times
                if let randomElement = data.randomElement() {
                    elementBuffer.append(randomElement)
                    data.removeAll(where: { $0 == randomElement })
                }
            }
        }

        // Add back
        if Int.random(in: 1 ..< 100) > 25 {
            for element in elementBuffer {
                data.insert(element, at: Int.random(in: 0 ... data.count))
            }
            elementBuffer.removeAll()
        }

        // Apply changes manually
        print("new data: ", data)

        let changeset = StagedChangeset(source: oldData, target: data)
        tableView.reload(using: changeset, with: .effectFade) { data in
            self.data = data
        }
    }

    var elementBuffer: [String] = []
    @IBAction func shufflePress(_ button: NSButton) {
        runScenarios()

//
//
//        let sequence1 = [
//            ["5", "maybe", "test", "not", "sure", "?"]
//        ]
//
//        let oldData = data
//
//        for step in sequence1 {
//            print("Doing step to ", step)
//
//            let changeset = StagedChangeset(source: data, target: step)
//            tableView.reload(using: changeset, with: .effectFade) { data in
//                print("applying data: ", data)
//                self.data = data
//            }
//
//            let dataItShouldBe = data
//            let dataFromTable = dataFromTableState()
//
//            if dataItShouldBe != dataFromTable {
//                print("🏁 FINAL data is not in sync!")
//                print("Should: ", dataItShouldBe)
//                print("But is: ", dataFromTable)
//            }
//        }
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
