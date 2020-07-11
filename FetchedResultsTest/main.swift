//
//  main.swift
//  FetchedResultsTest
//
//  Created by Chuck Hartman on 7/8/20.
//

import Foundation
import CoreData

print("Begin FetchedResultsTest")

// Initialize th Core Data store with Items and Attributes
let allItems = CoreDataDataSource<Item>()
let allAttributes = CoreDataDataSource<Attribute>()

CoreData.deleteAll("Item")
print("Item count: \(allItems.count)")
print("Attribute count: \(allAttributes.count)")
CoreData.initialDbSetup()
print("Item count: \(allItems.count)")
print("Attribute count: \(allAttributes.count)")


let dataSource = CoreDataDataSource<Attribute>(sortKey1: "item.order",
                                               sortKey2: "order",
                                               sectionNameKeyPath: "item.name")

print("\nFetched Results of original DB")
sectionedData(dataSource)

CoreData.executeBlockAndCommit {
    let items = allItems.fetch()    // Gets all Items in order by order
    print("Swapping order property of first two Items")
    let firstItemOrder = items[0].order
    let secondItemOrder = items[1].order
    items[0].order = secondItemOrder
    items[1].order = firstItemOrder
}

print("\nFetched Results after updating order of first two Items")
sectionedData(dataSource)

print("Finished FetchedResultsTest")

private func sectionedData(_ datasource: CoreDataDataSource<Attribute>) {

    func sectionName(_ section: NSFetchedResultsSectionInfo) -> String {
        // Each section will always have at least one object and it will be an Attribute
        return sectionNameFromKeyPath(section.objects?.first as! Attribute)
    }
    
    func sectionNameFromKeyPath(_ attribute: Attribute) -> String {
        let value = attribute.value(forKeyPath: datasource.frc.sectionNameKeyPath!) as? String
        return value ?? ""
    }
    
    let items = allItems.fetch()
    for i in 0..<items.count {
        print("Item        - index: \(i) order: \(items[i].order) name: \(items[i].name)")
    }
    print("")

    let sections = dataSource.sections
    for i in 0..<sections.count {
        print("SectionInfo - index: \(i) name: \(sections[i].name) Section Name should be: \(sectionName(sections[i]))")
        let attributes = sections[i].objects as! [Attribute]
        for j in 0..<attributes.count {
            print("Attribute   - index: \(j) order: \(j) name: \(attributes[j].name) sectionName: \(sectionNameFromKeyPath(attributes[j]))")
        }
        print("")
    }
}

