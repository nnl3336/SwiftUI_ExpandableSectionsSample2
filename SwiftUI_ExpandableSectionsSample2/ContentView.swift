//
//  ContentView.swift
//  SwiftUI_ExpandableSectionsSample2
//
//  Created by Yuki Sasaki on 2025/08/08.
//

import SwiftUI
import CoreData

struct RecursiveDisclosureGroup: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let folder: Folder
    @State private var isExpanded = false
    
    var body: some View {
        if !folder.childrenArray.isEmpty {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    ForEach(folder.childrenArray) { child in
                        RecursiveDisclosureGroup(folder: child)
                            .padding(.leading, 20)
                            .contextMenu {
                                contextMenuView
                            }
                    }
                },
                label: {
                    Label(folder.title ?? "", systemImage: "folder")
                }
            )
        } else {
            Text(folder.title ?? "")
                .padding(.leading, 20)
                .contextMenu {
                    contextMenuView
                }
        }
    }
    
    var contextMenuView: some View {
        Button(action: {
            addSubfolder(to: folder)
        }) {
            Label("サブフォルダを追加", systemImage: "folder.badge.plus")
        }
    }

    
    func addSubfolder(to folder: Folder) {
        let newFolder = Folder(context: viewContext)
        newFolder.id = UUID()
        newFolder.title = "新しいフォルダ"
        newFolder.parent = folder  // ここが重要！
        
        var currentChildren = folder.childrenArray
        currentChildren.append(newFolder)
        folder.children = NSSet(array: currentChildren)
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving new folder: \(error)")
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.title, ascending: true)]
    ) var folders: FetchedResults<Folder>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(folders) { folder in
                    RecursiveDisclosureGroup(folder: folder)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Folders")
        }
    }
    
    private func addFolder() {
        let newFolder = Folder(context: viewContext)
        newFolder.id = UUID()
        newFolder.title = "新しいフォルダ"
        newFolder.children = nil
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving new folder: \(error)")
        }
    }
}


extension Folder {
    var childrenArray: [Folder] {
        let set = children as? Set<Folder> ?? []
        return set.sorted { $0.title ?? "" < $1.title ?? "" }
    }
}


/*
extension Folder {
    var childrenArray: [Folder] {
        let set = children as? Set<Folder> ?? []
        return set.sorted { $0.title ?? "" < $1.title ?? "" }
    }
}
*/
