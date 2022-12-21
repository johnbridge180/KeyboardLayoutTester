//
//  KeyboardGestureRecognizer.swift
//  TestingKeyboard
//
//  Created by John Bridge on 12/1/22.
//

import Foundation
import UIKit

class KeyboardGestureRecognizer: UIGestureRecognizer, NSCoding {
    var samples: [TouchEvent] = []
    var trackedTouch: UITouch?
    var start_timestamp: TimeInterval = 0
    
    func encode(with coder: NSCoder) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        start_timestamp=Date().timeIntervalSince1970
        for touch in touches {
            addSample(for: touch)
        }
        state = .began
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            addSample(for: touch)
        }
       state = .changed
    }
     
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            addSample(for: touch)
        }
        state = .ended
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.samples.removeAll()
        state = .cancelled
    }
    override func reset() {
       self.samples.removeAll()
       self.trackedTouch = nil
    }
    
    func addSample(for touch: UITouch) {
        let newSample = TouchEvent(location: touch.location(in: self.view), touch:touch, timestamp: touch.timestamp)
        self.samples.append(newSample)
    }
}

struct TouchEvent {
    let location: CGPoint
    let touch: UITouch?
    let timestamp: TimeInterval
    
    init(location: CGPoint, touch: UITouch?, timestamp: TimeInterval) {
        self.location=location
        self.touch=touch
        self.timestamp=timestamp
    }
}
