// Play a song using a speaker.
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
        let player = Player(speaker, bpm: Mario.bpm, sampleRate: 16_000, timeSignature: Mario.timeSignature)

        // Play the music using the tracks.
        player.playTracks(Mario.tracks)

        while true {
            sleep(ms: 1000)
        }
    }
}
