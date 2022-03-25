#if os(macOS)
import AppKit

typealias MovedElement = (source: ElementPath, target: ElementPath)

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

    func reload<C: Equatable>(
        using stagedChangeset: StagedChangeset<C>,
        with animation: @autoclosure () -> NSTableView.AnimationOptions,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        originalData: C,
        newData: C,
        setData: (C) -> Void
    )
        where C.Element: Equatable
    {
        reload(
            using: stagedChangeset,
            deleteRowsAnimation: animation(),
            insertRowsAnimation: animation(),
            reloadRowsAnimation: animation(),
            originalData: originalData,
            newData: newData,
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

    // Every move is a REMOVE and an INSERT, and after each operation the indexes higher than the current one need to be incremented/decremted

    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        deleteRowsAnimation: @autoclosure () -> NSTableView.AnimationOptions,
        insertRowsAnimation: @autoclosure () -> NSTableView.AnimationOptions,
        reloadRowsAnimation: @autoclosure () -> NSTableView.AnimationOptions,
        originalData: C,
        newData: C,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void
    )
        where C.Element: Equatable
    {
        if case .none = window, let data = stagedChangeset.last?.data {
            setData(data)
            return reloadData()
        }

        // we will replay all operations on playAlong and keep originalData for reference of the original offsets
//        var playAlong = Array(originalData)

        for changeset in stagedChangeset {
            print("➡️ next changeset…")
            print("changeset data: ", changeset.data)
            if let interrupt = interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
                setData(data)
                return reloadData()
            }
            
            
            // MARK: - Moves
            beginUpdates()

            // We found out that source always related to the element that was initially on that offset
            // where is it now? I have no idea :)
            for (source, target) in changeset.elementMoved {
                print("UI State before:", dataFromTableState())
//                print("playAlong:", playAlong)
                /// A "move" is the same as this:
                /// removeRows(at: IndexSet(integer: source.element))
                /// insertRows(at: IndexSet(integer: target.
                ///
                ///
                ///

//                let elementInOriginalData = Array(originalData)[source.element]
////                let adjustedFromIndex = playAlong.firstIndex(where: { $0 == elementInOriginalData })!
//
//                print("Move", source.element, target.element)
//                print("Move (adjusted)", adjustedFromIndex, target.element)
//                //                print("Move adjusted", adjustedSourceIndex, target.element)
//
//                moveRow(at: adjustedFromIndex, to: target.element)
//
//                //
//                //                removeLog.append(source.element)
//                //                insertionLog.append(target.element)
//
//                print("UI State after: ", dataFromTableState())

                //                beginUpdates()
            }
            endUpdates()
//
//            let operations = changeset.elementMoved.map { OrderedOperation(from: $0.source.element, to: $0.target.element) }
//            let converter = OrderedOperationConverter(unorderedOperations: operations)
//
            setData(changeset.data)
//
            beginUpdates()

            if !changeset.elementDeleted.isEmpty {
                removeRows(at: IndexSet(changeset.elementDeleted.map { $0.element }), withAnimation: deleteRowsAnimation())
                // Replay
//                changeset.elementDeleted.forEach { playAlong.remove(at: $0.element) }
                print("removeRows", changeset.elementDeleted)

//                changeset.elementDeleted.forEach { converter.recordDelete(atIndex: $0.element) }
            }

            if !changeset.elementInserted.isEmpty {
                insertRows(at: IndexSet(changeset.elementInserted.map { $0.element }), withAnimation: insertRowsAnimation())
                // Replay
//                changeset.elementInserted.forEach {
//                    playAlong.insert(Array(newData)[$0.element], at: $0.element)
//                }
                print("InsertRows", changeset.elementInserted)

                // TODO: Adjust target offsets after current index
//                changeset.elementInserted.forEach { converter.recordInsert(atIndex: $0.element + 1) }
            }
//
            if !changeset.elementUpdated.isEmpty {
                reloadData(forRowIndexes: IndexSet(changeset.elementUpdated.map { $0.element }), columnIndexes: IndexSet(changeset.elementUpdated.map { $0.section }))
            }
//
            endUpdates()
            print("UI State: \(dataFromTableState())")
//


     

            let dataItShouldBe = changeset.data as! [String]
            let dataFromTable = dataFromTableState()
            if dataItShouldBe != dataFromTable {
                print("❌ Data is not in sync!")
                print("Should: ", dataItShouldBe)
                print("But is: ", dataFromTable)
            } else {
                print("✅ data in sync ", dataFromTable)
            }

//            endUpdates()
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
