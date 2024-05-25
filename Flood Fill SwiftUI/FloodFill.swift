//
//  FloodFill.swift
//  Flood Fill
//
//  Created by Paul Solt on 5/23/24.
//

import SwiftUI

struct FloodFill: View {
    
    @ObservedObject var grid: Grid
    var spacing: CGFloat
    var maxSize: CGFloat = 100
    var minSize: CGFloat = 2
    
    init(grid: Grid, spacing: CGFloat) {
        self.grid = grid
        self.spacing = spacing
    }
    
    var body: some View {
        
        TabView {
            VStack {    // 2D coordinate math
                Spacer()
                Text("2D Canvas SwiftUI Grid")
                    .font(.headline)
                canvasGrid
                resetButton
                Slider(value: $grid.size, in: minSize...maxSize) { isEditing in
                    // Always show updates when sliding for Canvas
                        self.grid.objectWillChange.send()
                }
                Spacer()
            }
            .tabItem {
                Label("2D Canvas", systemImage: "view.2d")
            }
            VStack {    // Rectangles with individual gesture recognizers
                Spacer()
                Text("Rectangle SwiftUI Grid")
                    .font(.headline)
                
                rectangleGrid
                resetButton
                Slider(value: $grid.size, in: minSize...maxSize) { isEditing in
                    if !isEditing {
                        // Only update when finished editing, too slow to update
                        self.grid.objectWillChange.send()
                        reset()
                    }
                }
                Spacer()
            }
            .tabItem {
                Label("Rectangle Grid", systemImage: "square.grid.2x2")
            }
        }
        .overlay(
            VStack {
                Text("Flood Fill")
                    .font(.title)
                Text("Two grid renders for same data. Tap to fill.")
                    .multilineTextAlignment(.center)
                Spacer()
            }
        )
    }
    
    var resetButton: some View {
        Button(action:reset, label: {
            Text("Reset")
        })
    }
    
    // Works for small numbers of views < 10-20, not good performance for large numbers of pixels
    var rectangleGrid: some View {
        VStack(spacing: spacing) {
            ForEach(grid.rows) { row in
                HStack(spacing: spacing) {
                    ForEach(row.cells) { cell in
                        if let filled = cell.filled {
                            
                            Rectangle()
                                .foregroundColor(filled ? Color.blue : Color.white)
                                .onTapGesture {
                                    grid.objectWillChange.send() // Force layout update because we have nested ObservableObjects
                                    grid.floodFill(x: cell.point.x, y: cell.point.y)
                                }
                        } else {
                            // border black cell
                            Rectangle()
                                .foregroundColor(Color.black)
                        }
                        
                    }
                }
            }
        }
        .aspectRatio(contentMode: .fit)
        .padding(spacing)
        .background(Color.init(white: 0.9))
    }
    
    @State var canvasSize: CGSize = CGSize.zero
    
    // Alternate canvas view - uses cellAtPoint(x:,y:) logic
    var canvasGrid: some View {
        Canvas { context, size in
            let width = (size.width - spacing * CGFloat(grid.size + 1)) / CGFloat(grid.size)
            
            for y in 0 ..< Int(grid.size) {
                for x in 0 ..< Int(grid.size) {
                    let x1 = CGFloat(x) * (width + spacing) + spacing
                    let y1 = CGFloat(y) * (width + spacing) + spacing
                    let frame = CGRect(x: x1, y: y1, width: width, height: width)
                    
                    var color: Color = .black
                    
                    if let filled = grid.rows[y].cells[x].filled { // FIXME: Thread 1: Fatal error: Index out of range
                        color = filled ? .blue : .white
                    }
                    context.fill(Rectangle().path(in: frame), with: .color(color))
                }
            }
        }
        .overlay( // Measure size for cellAtPoint()
            GeometryReader { proxy in
                Color.clear
                    .onAppear() {
                        canvasSize = proxy.size
                    }
            }
        )
        .background(Color(white: 0.9))
        .aspectRatio(contentMode: .fit)
        .onTapGesture { location in
            let point = cellAtPoint(location)
            print("Cell: \(point))")
            grid.floodFill(x: point.x, y: point.y)
            grid.objectWillChange.send()
        }
    }
    
    // Determine touch point, grid top left edges are considered part of
    // pixel for touch input so that we always get visual feedback when tapping
    func cellAtPoint(_ point: CGPoint) -> (x: Int, y: Int) {
        var xPos: CGFloat = 0
        var yPos: CGFloat = 0
        var xOut: Int = 0
        var yOut: Int = 0
        let cellWidth = canvasSize.width / CGFloat(grid.size) // Treat top left edge as part of grid
        
        for i in 0 ..< Int(grid.size) {
            if point.x >= xPos && point.x < xPos + cellWidth {
                xOut = i
                break
            }
            xPos += cellWidth
        }
        
        for i in 0 ..< Int(grid.size) {
            if point.y >= yPos && point.y < yPos + cellWidth {
                yOut = i
                break
            }
            yPos += cellWidth
        }
        return (Int(xOut), Int(yOut))
    }
    
    func reset() {
        grid.reset()
    }
}

class Grid: Identifiable, ObservableObject {
    let id: UUID = UUID()
    @Published var rows: [Row]
    @Published var size: CGFloat
    
    init(_ size: Int) {
        self.size = CGFloat(size)
        self.rows = [Row]()
        self.rows = generateBoard(size: size)
    }
    
    func generateBoard(size: Int) -> [Row] {
        var newGrid = [Row]()
        // randomly choose not filled or empty (nil)
        for y in 0 ..< size {
            var cells = [Cell]()
            for x in 0 ..< size {
                let isBorder = Int.random(in: 0...1)
                cells.append(Cell(isBorder == 0 ? nil : false, point: (x: x, y: y)))
            }
            newGrid.append(Row(cells))
        }
        return newGrid
    }
    
    func reset() {
        rows = generateBoard(size: Int(size))
    }
    
    func floodFill(x: Int, y: Int) {
        if isValidCell(x: x, y: y) {
            rows[y].cells[x].filled = true
        }
        
        // Recursive search for neighbors
        if isValidCell(x: x, y: y - 1) { // up
            floodFill(x: x, y: y - 1)
        }
        if isValidCell(x: x + 1, y: y) { // right
            floodFill(x: x + 1, y: y)
        }
        if isValidCell(x: x, y: y + 1) { // down
            floodFill(x: x, y: y + 1)
        }
        if isValidCell(x: x - 1, y: y) { // left
            floodFill(x: x - 1, y: y)
        }
    }
    
    func isValidCell(x: Int, y: Int) -> Bool {
        guard x >= 0 && y >= 0 && x < Int(size) && y < Int(size)
        else { return false }
        return rows[y].cells[x].filled == false
    }
}

class Cell: Identifiable, ObservableObject {
    let id: UUID = UUID()
    let point: (x: Int, y: Int)
    
    @Published var filled: Bool?
    
    init(_ filled: Bool?, point: (x: Int, y: Int)) {
        self.filled = filled
        self.point = point
    }
}

class Row: Identifiable, ObservableObject {
    let id: UUID = UUID()
    @Published var cells: [Cell]
    
    init(_ cells: [Cell]) {
        self.cells = cells
    }
}

#Preview {
    FloodFill(grid: Grid(9), spacing: 1)
}
