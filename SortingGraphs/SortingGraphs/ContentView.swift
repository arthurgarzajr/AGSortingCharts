//
//  ContentView.swift
//  SortingGraphs
//
//  Created by Arthur Garza on 6/9/22.
//

import SwiftUI
import Charts

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                BubbleSortView()
                ShellSortView()
            }
            .navigationTitle("Sorting Charts")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
