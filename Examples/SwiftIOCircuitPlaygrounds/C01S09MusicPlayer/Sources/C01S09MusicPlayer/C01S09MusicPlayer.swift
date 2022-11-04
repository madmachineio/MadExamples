// Play a song fragment Twinkle twinkle little star.
import SwiftIO
import MadBoard

@main
public struct C01S09MusicPlayer {
    public static func main() {
        // The sample rate of I2SOut and Player should be the same.
        // Note: the speaker needs stereo channel but only uses the samples of left channel. 
        // And the frequencies below 200Hz may sound a little fuzzy with this speaker.
        let speaker = I2SOut(Id.I2SOut0, rate: 16_000, channel: .stereo)

        // BPM is beat count per minute. 
        // Timer signature specifies beats per bar and note value of a beat.
        let player = Player(speaker, bpm: 120, sampleRate: 16_000, timeSignature: (4,2))

        // Raise the song an octave and play it.
        player.playTracks([track, track2], halfStep: 12)

        while true {
            sleep(ms: 1000)
        }
    }
}
