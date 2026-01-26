//
//  ContentView.swift
//  ColorWalk
//
//  Created by Clara on 2026/1/22.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        TabView {
            PhotoPickingView(modelContext: modelContext)
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
