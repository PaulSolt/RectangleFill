//
//  FloodFill.swift
//  Flood Fill
//
//  Created by Paul Solt on 5/23/24.
//

import SwiftUI

class Cell: Identifiable, ObservableObject {
    let id: UUID = UUID()
//    let color: Color
    @Published var filled: Bool? // nil = black, false = white, true = color
    
    init(_ filled: Bool?) {
        self.filled = filled
    }
}

class Row: Identifiable, ObservableObject {
    let id: UUID = UUID()
    @Published var cells: [Cell]
    
    init(_ cells: [Cell]) {
        self.cells = cells
    }
}

class Grid: Identifiable, ObservableObject {
    let id: UUID = UUID()
    @Published var rows: [Row]
    let size: Int
    
    init(_ size: Int) {
        self.size = size
        self.rows = [Row]()
        self.rows = generateBoard(size: size)
    }
    
    func generateBoard(size: Int) -> [Row] {
        var newGrid = [Row]()
        // randomly choose not filled or empty (nil)
        for _ in 0 ..< size {
            var cells = [Cell]()
            for _ in 0 ..< size {
                let isBorder = Int.random(in: 0...1)
                cells.append(Cell(isBorder == 0 ? nil : false))
            }
            newGrid.append(Row(cells))
        }
        return newGrid
    }
    
    func floodFill() {
        
       // Look in each direction
        // if isValid
            // fill the cell,
            // take a step in that direction
        
        
    }
    
    func isValidCell(x: Int, y: Int) -> Bool {
        
        guard x >= 0 || y >= 0 || x < size || y < size else { return false }
        
//        let row = rows[y]
//        let cell = row[x]
//        return cell.
        return false
    }
    
}

struct FloodFill: View {
    
    @ObservedObject var grid: Grid
//    = [
//        Row([Cell(false), Cell(nil), Cell(true)]),
//        Row([Cell(false), Cell(nil), Cell(true)]),
//        Row([Cell(false), Cell(nil), Cell(true)]),
//    ]
    
    init(grid: Grid) {
        self.grid = grid
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                ForEach(grid.rows) { row in
                    HStack {
                        ForEach(row.cells) { cell in
                            if let filled = cell.filled {
                                
                                Rectangle()
                                    .foregroundColor(filled ? Color.blue : Color.white)
                                    .onTapGesture {
                                        print("Tap")
                                        
//                                        if cell
                                        cell.filled = true
//                                        print(cell.filled)
                                        grid.objectWillChange.send()

                                        // TODO: fill the remaining
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
            .background(Color.init(white: 0.9))
            Spacer()
        }
        .background(Color.green)
    }
    
    
}

#Preview {
    FloodFill(grid: Grid(9))
}
