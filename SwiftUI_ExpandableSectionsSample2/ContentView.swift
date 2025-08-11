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
    let level: Int
    let maxLevel: Int // 最大3階層まで表示する例
    
    @State private var isExpanded = false
    
    @State private var selectedFolder: Folder? = nil
    
    // 入力用の状態変数
    @State private var showingAddSubFolderSheet = false
    @State private var newFolderTitle = ""
    
    var body: some View {
        Group {
            if folder.childrenArray/*(atLevel: level)*/.isEmpty {
                Label(folder.title ?? "", systemImage: "folder")
            } else {
                DisclosureGroup(
                    isExpanded: $isExpanded,
                    content: {
                        if level < maxLevel {
                            ForEach(folder.childrenArray) { child in
                                RecursiveDisclosureGroup(folder: folder, level: level + 1, maxLevel: maxLevel)
                            }
                        } else {
                            Text("もっと深い階層があります…")
                                .italic()
                                .padding(.leading, CGFloat(level + 1) * 20)
                        }
                    },
                    label: {
                        Label(folder.title ?? "", systemImage: "folder")
                    }
                )
            }
        }
        .contextMenu {
            Button("サブフォルダ追加") {
                newFolderTitle = ""
                selectedFolder = folder
                showingAddSubFolderSheet = true
            }
            Button(role: .destructive) {
                deleteFolder(folder)
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
        .alert("make Sub Folder ?", isPresented: $showingAddSubFolderSheet) {
            TextField("text", text: $newFolderTitle)
                .textInputAutocapitalization(.never)
            Button("Cancel", role: .cancel) {}
            Button("Make") {
                if let targetFolder = selectedFolder {
                    addSubfolder(to: targetFolder, level: level, title: newFolderTitle)
                }
            }
        } message: {
            Text("")
        }
    }
    
    func addSubfolder(to folder: Folder?, level: Int, title: String) {
        let newFolder = Folder(context: viewContext)
        newFolder.id = UUID()
        newFolder.title = title
        newFolder.parent = folder

        do {
            try viewContext.save()
            print("親フォルダ: \(folder?.title ?? "") の子フォルダ一覧：")
            for child in folder?.childrenArray ?? [] {
                print(" - \(child.title ?? "")")
            }
        } catch {
            print("保存エラー: \(error)")
        }
    }
    
    func deleteFolder(_ folder: Folder) {
        viewContext.delete(folder)
        do {
            try viewContext.save()
        } catch {
            print("削除エラー: \(error)")
        }
    }
}

/*struct FolderContextMenuView: View {
    let folder: Folder
    let viewContext: NSManagedObjectContext
    
    var body: some View {
        Group {
            Button(action: {
                addSubfolder(to: folder)
            }) {
                Label("サブフォルダを追加", systemImage: "folder.badge.plus")
            }
            Button(role: .destructive, action: {
                deleteFolder(folder)
            }) {
                Label("削除", systemImage: "trash")
            }
        }
    }
    
    private func addSubfolder(to folder: Folder) {
        let newFolder = Folder(context: viewContext)
        newFolder.id = UUID()
        newFolder.title = "新しいフォルダ"
        newFolder.parent = folder
        
        /*var currentChildren = folder.childrenArray
        currentChildren.append(newFolder)
        folder.children = NSSet(array: currentChildren)*/
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving new folder: \(error)")
        }
    }
    
    private func deleteFolder(_ folder: Folder) {
        viewContext.delete(folder)
        do {
            try viewContext.save()
        } catch {
            print("削除失敗: \(error)")
        }
    }
}*/

//

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.title, ascending: true)]
    ) var folders: FetchedResults<Folder>
    
    let maxLevel = 3
    let rootLevel = 0
    
    
    @State private var showingAddFolderSheet = false
    @State private var newFolderTitle = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(folders.filter { $0.parent == nil }) { folder in
                    RecursiveDisclosureGroup(folder: folder, level: rootLevel, maxLevel: maxLevel)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Folders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddFolderSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Make Folder?", isPresented: $showingAddFolderSheet) {
                TextField("Folder name", text: $newFolderTitle)
                    .textInputAutocapitalization(.never)
                Button("Cancel", role: .cancel) {}
                Button("Make") {
                    addFolder(title: newFolderTitle)
                }
            } message: {
                Text("")
            }
        }

        
    }
    
    func addFolder(to folder: Folder? = nil, title: String) {
        let newFolder = Folder(context: viewContext)
        newFolder.id = UUID()
        newFolder.title = title
        newFolder.parent = folder

        guard let folder = folder else {
            // folderがnil（＝ルートに追加）ならchildren更新は不要
            do {
                try viewContext.save()
            } catch {
                print("保存エラー: \(error)")
            }
            return
        }

        /*var currentChildren = folder.childrenArray(atLevel: level)
        currentChildren.append(newFolder)
        folder.children = NSSet(array: currentChildren)*/

        do {
            try viewContext.save()
        } catch {
            print("保存エラー: \(error)")
        }
    }
}

extension Folder {
    var childrenArray: [Folder] {
        let set = children as? Set<Folder> ?? []
        let sorted = set.sorted { ($0.title ?? "") < ($1.title ?? "") }
        return sorted
    }
}

/*extension Folder {
    func childrenArray(atLevel level: Int) -> [Folder] {
        let set = children as? Set<Folder> ?? []
        let filtered = set.filter { $0.level == level }
        let sorted = filtered.sorted { ($0.title ?? "") < ($1.title ?? "") }
        return sorted
    }
}*/

/*
extension Folder {
    var level: Int {
        var depth = 0
        var current = parent
        while current != nil {
            depth += 1
            current = current?.parent
        }
        return depth
    }
}
*/



/*
extension Folder {
    var childrenArray: [Folder] {
        let set = children as? Set<Folder> ?? []
        return set.sorted { $0.title ?? "" < $1.title ?? "" }
    }
}
*/
