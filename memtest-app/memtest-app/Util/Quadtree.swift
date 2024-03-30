//
//  Quadtree.swift
//  memtest-app
//
//  Created by Christopher Witzl on 28.03.24.
//

import Foundation

class Quadtree<T> {
    let boundary: CGRect
    var points: [(point: CGPoint, value: T)] = []
    var divided = false
    var nw: Quadtree?
    var ne: Quadtree?
    var sw: Quadtree?
    var se: Quadtree?

    let capacity: Int

    init(boundary: CGRect, capacity: Int = 4) {
        self.boundary = boundary
        self.capacity = capacity
    }

    func insert(point: CGPoint, value: T) -> Bool {
        if !boundary.contains(point) {
            return false
        }

        if points.count < capacity {
            points.append((point, value))
            return true
        }

        if !divided {
            subdivide()
        }

        return nw!.insert(point: point, value: value) ||
               ne!.insert(point: point, value: value) ||
               sw!.insert(point: point, value: value) ||
               se!.insert(point: point, value: value)
    }

    private func subdivide() {
        let x = boundary.origin.x
        let y = boundary.origin.y
        let w = boundary.width / 2
        let h = boundary.height / 2

        nw = Quadtree(boundary: CGRect(x: x, y: y, width: w, height: h), capacity: capacity)
        ne = Quadtree(boundary: CGRect(x: x + w, y: y, width: w, height: h), capacity: capacity)
        sw = Quadtree(boundary: CGRect(x: x, y: y + h, width: w, height: h), capacity: capacity)
        se = Quadtree(boundary: CGRect(x: x + w, y: y + h, width: w, height: h), capacity: capacity)

        divided = true
    }
    
    func collect() -> [(point: CGPoint, value: T)] {
            var points = self.points
            
            if divided {
                points.append(contentsOf: nw?.collect() ?? [])
                points.append(contentsOf: ne?.collect() ?? [])
                points.append(contentsOf: sw?.collect() ?? [])
                points.append(contentsOf: se?.collect() ?? [])
            }
            
            return points
        }
    
    // Prüft ob die area bereits einen Punkt im Tree schneidet
    func query(in area: CGRect) -> Bool {
        
        if !boundary.intersects(area) {
            return false
        }
        
        for point in points {
            if area.contains(point.point) {
                return true // Bereich enthält mindestens einen Punkt
            }
        }
        
        // rekursiv
        if divided {
            return nw?.query(in: area) ?? false ||
                   ne?.query(in: area) ?? false ||
                   sw?.query(in: area) ?? false ||
                   se?.query(in: area) ?? false
        }
        
        return false
    }
}
