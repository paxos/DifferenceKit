#if os(macOS)
import AppKit

public extension NSTableView {
    private func dataFromTableState() -> [String] {
        var data = [String]()
        for row in 0 ... numberOfRows - 1 {
            if let valueOfView = (view(atColumn: 0, row: row, makeIfNecessary: false) as? NSTableCellView)?.textField?.objectValue as? String {
                data.append(valueOfView)
            }
        }
        return data
    }

    /// Applies multiple animated updates in stages using `StagedChangeset`.
    ///
    /// - Note: There are combination of changes that crash when applied simultaneously in `performBatchUpdates`.
    ///         Assumes that `StagedChangeset` has a minimum staged changesets to avoid it.
    ///         The data of the data-source needs to be updated synchronously before `performBatchUpdates` in every stages.
    ///
    /// - Parameters:
    ///   - stagedChangeset: A staged set of changes.
    ///   - animation: An option to animate the updates.
    ///   - interrupt: A closure that takes an changeset as its argument and returns `true` if the animated
    ///                updates should be stopped and performed reloadData. Default is nil.
    ///   - setData: A closure that takes the collection as a parameter.
    ///              The collection should be set to data-source of NSTableView.

    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        with animation: @autoclosure () -> NSTableView.AnimationOptions,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void
    ) {
        reload(
            using: stagedChangeset,
            deleteRowsAnimation: animation(),
            insertRowsAnimation: animation(),
            reloadRowsAnimation: animation(),
            interrupt: interrupt,
            setData: setData
        )
    }

    /// Applies multiple animated updates in stages using `StagedChangeset`.
    ///
    /// - Note: There are combination of changes that crash when applied simultaneously in `performBatchUpdates`.
    ///         Assumes that `StagedChangeset` has a minimum staged changesets to avoid it.
    ///         The data of the data-source needs to be updated synchronously before `performBatchUpdates` in every stages.
    ///
    /// - Parameters:
    ///   - stagedChangeset: A staged set of changes.
    ///   - deleteRowsAnimation: An option to animate the row deletion.
    ///   - insertRowsAnimation: An option to animate the row insertion.
    ///   - reloadRowsAnimation: An option to animate the row reload.
    ///   - interrupt: A closure that takes an changeset as its argument and returns `true` if the animated
    ///                updates should be stopped and performed reloadData. Default is nil.
    ///   - setData: A closure that takes the collection as a parameter.
    ///              The collection should be set to data-source of NSTableView.
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        deleteRowsAnimation: @autoclosure () -> NSTableView.AnimationOptions,
        insertRowsAnimation: @autoclosure () -> NSTableView.AnimationOptions,
        reloadRowsAnimation: @autoclosure () -> NSTableView.AnimationOptions,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void
    ) {
        if case .none = window, let data = stagedChangeset.last?.data {
            setData(data)
            return reloadData()
        }

        for changeset in stagedChangeset {
            if let interrupt = interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
                setData(data)
                return reloadData()
            }

            var insertionLog = [Int]()
            var removeLog = [Int]()

            beginUpdates()
            setData(changeset.data)

            if !changeset.elementDeleted.isEmpty {
                removeRows(at: IndexSet(changeset.elementDeleted.map { $0.element }), withAnimation: deleteRowsAnimation())
                print("removeRows", changeset.elementDeleted)
            }

            if !changeset.elementInserted.isEmpty {
                insertRows(at: IndexSet(changeset.elementInserted.map { $0.element }), withAnimation: insertRowsAnimation())
                print("InsertRows", changeset.elementInserted)
                changeset.elementInserted.forEach { insertionLog.append($0.element) }
            }

            if !changeset.elementUpdated.isEmpty {
                reloadData(forRowIndexes: IndexSet(changeset.elementUpdated.map { $0.element }), columnIndexes: IndexSet(changeset.elementUpdated.map { $0.section }))
            }

            endUpdates()
            beginUpdates()

            // Adjust offsets for serial apply, not parallel

            typealias MovedElement = (source: ElementPath, target: ElementPath)
            func adjustOffsets(_ elementsMoved: [MovedElement], initialOffset: Int) -> [MovedElement] {
                var currentOffset = initialOffset
                var secondOffset = 0
                var results: [MovedElement] = []

                for (index, var element) in elementsMoved.enumerated() {
                    let previousElement: MovedElement? = index > 0 ? elementsMoved[index - 1] : nil
                    let nextElement: MovedElement? = index < elementsMoved.count - 1 ? elementsMoved[index + 1] : nil

                    if let previousElement = previousElement {
                        if previousElement.target.element <= element.source.element {
                            currentOffset += 1
                        } else {
                            secondOffset += 1 // not sure if this is correct
                        }
                    }

                    element.source.element += currentOffset
                    element.target.element += secondOffset
                    results.append(MovedElement((source: element.source, target: element.target)))
                }

                return results
            }

            let adjusted = adjustOffsets(changeset.elementMoved, initialOffset: insertionLog.count)

            print("÷·")

            for (source, target) in adjusted {
                print("UI State before: ", dataFromTableState())
                /// A "move" is the same as this:
                /// removeRows(at: IndexSet(integer: source.element))
                /// insertRows(at: IndexSet(integer: target.element))

//                print("Move", source, target)

//                let sourceAdjustment = insertionLog.filter { $0 < source.element }.count - removeLog.filter { $0 < source.element }.count
//                let targetAdjustment = insertionLog.filter { $0 < target.element }.count - removeLog.filter { $0 < target.element }.count

//                let sourceAdjustment = insertionLog.count
//                let targetAdjustment = insertionLog.filter { $0 < target.element }.count - removeLog.filter { $0 < target.element }.count
//
//                let adjustedTargetIndex = target.element + sourceAdjustment
//                let adjustedSourceIndex = source.element + insertionLog.count

                print("Move", source.element, target.element)
//                print("Move adjusted", adjustedSourceIndex, target.element)

                moveRow(at: source.element, to: target.element)

//
                ////                print("target.element: \(target.element), adjustedTargetIndex: \(adjustedTargetIndex)")
//                print("Move", adjustedSourceIndex, target.element)
//                print("Move adjusted", source.element, adjustedTargetIndex)
//
//                /// Moves are not swaps; they are inserts and removes and affect all indexes immediately
//                moveRow(at: adjustedSourceIndex, to: adjustedTargetIndex)

//                beginUpdates()

                // make it a swap
//                moveRow(at: target.element + 1, to: source.element)
//                print("Move", target.element + 1, source.element)
                ////                endUpdates()
//
                removeLog.append(source.element)
                insertionLog.append(target.element)

                print("UI State after: ", dataFromTableState())

//                beginUpdates()
            }
            let dataItShouldBe = changeset.data as! [String]
            let dataFromTable = dataFromTableState()
            if dataItShouldBe != dataFromTable {
                print("❌ Data is not in sync!")
                print("Should: ", dataItShouldBe)
                print("But is: ", dataFromTable)
            } else {
                print("✅ data in sync ", dataFromTable)
            }

            endUpdates()
        }
    }
}

@available(macOS 10.11, *)
public extension NSCollectionView {
    /// Applies multiple animated updates in stages using `StagedChangeset`.
    ///
    /// - Note: There are combination of changes that crash when applied simultaneously in `performBatchUpdates`.
    ///         Assumes that `StagedChangeset` has a minimum staged changesets to avoid it.
    ///         The data of the data-source needs to be updated synchronously before `performBatchUpdates` in every stages.
    ///
    /// - Parameters:
    ///   - stagedChangeset: A staged set of changes.
    ///   - interrupt: A closure that takes an changeset as its argument and returns `true` if the animated
    ///                updates should be stopped and performed reloadData. Default is nil.
    ///   - setData: A closure that takes the collection as a parameter.
    ///              The collection should be set to data-source of NSCollectionView.
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void
    ) {
        if case .none = window, let data = stagedChangeset.last?.data {
            setData(data)
            return reloadData()
        }

        for changeset in stagedChangeset {
            if let interrupt = interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
                setData(data)
                return reloadData()
            }

            animator().performBatchUpdates({
                setData(changeset.data)

                if !changeset.elementDeleted.isEmpty {
                    deleteItems(at: Set(changeset.elementDeleted.map { IndexPath(item: $0.element, section: $0.section) }))
                }

                if !changeset.elementInserted.isEmpty {
                    insertItems(at: Set(changeset.elementInserted.map { IndexPath(item: $0.element, section: $0.section) }))
                }

                if !changeset.elementUpdated.isEmpty {
                    reloadItems(at: Set(changeset.elementUpdated.map { IndexPath(item: $0.element, section: $0.section) }))
                }

                for (source, target) in changeset.elementMoved {
                    moveItem(at: IndexPath(item: source.element, section: source.section), to: IndexPath(item: target.element, section: target.section))
                }
            })
        }
    }
}
#endif
