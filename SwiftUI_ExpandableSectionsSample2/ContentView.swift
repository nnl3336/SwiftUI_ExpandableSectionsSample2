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
    
    // 入力用の状態変数
    @State private var showingAddFolderSheet = false
    @State private var newFolderTitle = ""
    
    var body: some View {
        if folder.childrenArray.isEmpty {
            Label(folder.title ?? "", systemImage: "folder")
                .padding(.leading, CGFloat(level) * 20)
        } else {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    if level < maxLevel {
                        ForEach(folder.childrenArray) { child in
                            RecursiveDisclosureGroup(folder: child, level: level + 1, maxLevel: maxLevel)
                        }
                    } else {
                        Text("もっと深い階層があります...")
                            .italic()
                            .padding(.leading, CGFloat(level + 1) * 20)
                    }
                },
                label: {
                    Label(folder.title ?? "", systemImage: "folder")
                        .padding(.leading, CGFloat(level) * 20)
                }
            )
            .contextMenu {
                Button("サブフォルダ追加") {
                    newFolderTitle = "" // 入力欄クリア
                    showingAddFolderSheet = true
                }
                Button(role: .destructive) {
                    deleteFolder(folder)
                } label: {
                    Label("削除", systemImage: "trash")
                }
            }
            .alert("make Folder ?", isPresented: $showingAddFolderSheet){
                TextField("text", text: $newFolderTitle)
                    .textInputAutocapitalization(.never)
                Button(role: .cancel, action: {}, label: {Text("cancel")})
                Button(role: .none, action: {
                    addSubfolder(to: folder, title: newFolderTitle)
                }, label: {Text("Make")})
            } message: {
                Text("")
            }
        }
    }
    
    func addSubfolder(to folder: Folder, title: String) {
        let newFolder = Folder(context: viewContext)
        newFolder.id = UUID()
        newFolder.title = title
        newFolder.parent = folder
        
        var currentChildren = folder.childrenArray
        currentChildren.append(newFolder)
        folder.children = NSSet(array: currentChildren)
        
        do {
            try viewContext.save()
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

struct FolderContextMenuView: View {
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
        
        var currentChildren = folder.childrenArray
        currentChildren.append(newFolder)
        folder.children = NSSet(array: currentChildren)
        
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
}

//

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.title, ascending: true)]
    ) var folders: FetchedResults<Folder>
    
    let maxLevel = 3
    let rootLevel = 0
    
    var body: some View {
        NavigationView {
            List {
                ForEach(folders) { folder in
                    RecursiveDisclosureGroup(folder: folder, level: rootLevel, maxLevel: maxLevel)
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
