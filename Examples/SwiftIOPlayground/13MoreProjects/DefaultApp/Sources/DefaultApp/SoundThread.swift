import SwiftIO
import MadBoard

func soundThread(_ a: UnsafeMutableRawPointer?, _ b: UnsafeMutableRawPointer?, _ c: UnsafeMutableRawPointer?) -> () {


// BPM is beat count per minute. 
// Timer signature specifies beats per bar and note value of a beat.
let player = Speaker()



var startPlay = false

while true {
    sleep(ms: 100)
    ioLock.lock()
    if globalIOValue[d19Module]! == 3 {
        globalIOValue[d19Module] = 2
        startPlay = true
    }
    ioLock.unlock()
    if startPlay {
        player.play()
        startPlay = false
        ioLock.lock()
        globalIOValue[d19Module] = 0
        ioLock.unlock()
    }
}
}