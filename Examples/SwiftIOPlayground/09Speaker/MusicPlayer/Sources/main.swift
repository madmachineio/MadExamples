// Play a song using a speaker.
import SwiftIO
import MadBoard


// The sample rate of I2SOut and Player should be the same.
// Note: the speaker needs stereo channel but only uses the samples of left channel. 
// And the frequencies below 200Hz may sound a little fuzzy with this speaker.
let speaker = I2S(Id.I2S0, rate: 16_000)

// BPM is beat count per minute. 
// Timer signature specifies beats per bar and note value of a beat.
let player = Player(speaker, sampleRate: 16_000)

player.bpm = Mario.bpm
player.timeSignature = Mario.timeSignature

// Play the music using the tracks.
player.playTracks(Mario.tracks, waveforms: Mario.trackWaveforms, amplitudeRatios: Mario.amplitudeRatios)

while true {
    sleep(ms: 1000)
}
