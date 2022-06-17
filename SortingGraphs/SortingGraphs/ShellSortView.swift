//
//  ShellSort.swift
//  SortingCharts
//
//  Created by Arthur Garza on 6/12/22.
//

import SwiftUI
import Charts

struct ShellSortView: View {
    @ObservedObject var sortCoordinator = SortCoordinator()
    private let numValues = 50
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Sorting \(numValues) values")
                        .foregroundColor(.secondary)
                    Text(sortCoordinator.description)
                }
                Spacer()
            }
            
            
            Chart {
                ForEach(sortCoordinator.array) { barValue in
                    BarMark(
                        x: .value("", barValue.index),
                        y: .value("", barValue.value)
                    )
                    .foregroundStyle(Gradient(colors: [Color(barValue.color), .clear]))
                }
                .lineStyle(StrokeStyle(lineWidth: 3))
                .symbolSize(100)
            }
            .frame(height: 350)
            
            
            Button("Sort") {
                withAnimation {
                    sortCoordinator.prepare(count: numValues, sortType: .shellSort)
                    sortCoordinator.execute()
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ShellSort_Previews: PreviewProvider {
    static var previews: some View {
        ShellSortView()
    }
}
