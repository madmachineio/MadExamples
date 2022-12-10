import SwiftIO

/// Play music using the given tracks.
/// The sound sample is generated based on a triangle wave and be sent using I2S protocol.
public class Player {
    public typealias NoteInfo = (note: Note, noteValue: Int)
    public typealias TimeSignature = (beatsPerBar: Int, noteValuePerBeat: Int)

    /// Beats per minute. It sets the speed of the music.
    public var bpm: Int = 60
    /// The beat count per bar and the note value for a beat.
    public var timeSignature: TimeSignature = (4,4)
    /// Set the overall note pitch. 12 half steps constitute an octave.
    public var halfStep = 0
    /// Fade in/out duration for each note in second.
    public var fadeDuration: Float = 0.01

    let amplitude = 16383
    var beatDuration: Float { 60.0 / Float(bpm) }

    var sampleRate: Float
    var speaker: I2SOut

    var buffer32 = [Int32](repeating: 0, count: 200_000)
    var buffer16 = [Int16](repeating: 0, count: 200_000)


    /// Initialize a player.
    /// - Parameters:
    ///   - speaker: An I2SOut interface.
    ///   - sampleRate: the sample count per second. It should be the same as that of I2S.
    public init(_ speaker: I2SOut, sampleRate: Float) {
        self.speaker = speaker
        self.sampleRate = sampleRate
    }

    /// Calculate and combine the data of all tracks, and then play the sound.
    ///
    /// - Parameters:
    ///   - tracks: different tracks of a piece of music. A track consists of
    ///   notes and note value. For example, note value of a quarter note is 4,
    ///   note value of a half note is 2.
    ///   - waveforms: the waveforms for each track used to generate sound samples.
    ///   - amplitudeRatios: the ratios used to control the sound loudness of each track.
    public func playTracks(
        _ tracks: [[NoteInfo]],
        waveforms: [Waveform],
        amplitudeRatios: [Float]
    ) {
        let beatCount = tracks[0].reduce(0) {
            $0 + Float(timeSignature.noteValuePerBeat) / Float($1.noteValue)
        }

        let barCount = Int(beatCount / Float(timeSignature.beatsPerBar))

        for barIndex in 0..<barCount {
            getBarData(tracks, barIndex: barIndex, waveforms: waveforms, amplitudeRatios: amplitudeRatios, data: &buffer32)

            let count = Int(Float(timeSignature.beatsPerBar) * beatDuration * sampleRate * 2)
            for i in 0..<count {
                buffer16[i] = Int16(buffer32[i] / Int32(tracks.count))
            }
            sendData(data: buffer16, count: count)
        }
    }


    /// Calculate all data of the track and play the sound.
    /// - Parameters:
    ///   - track: score of a melody in forms of notes and note value.
    ///   For example, note value of a quarter note is 4, note value of a half note is 2.
    ///   - waveform: the waveform used to generate sound samples.
    ///   - amplitudeRatio: the ratio used to control the sound loudness.
    public func playTrack(
        _ track: [NoteInfo],
        waveform: Waveform,
        amplitudeRatio: Float
    ) {
        for noteInfo in track {
            playNote(noteInfo, waveform: waveform, amplitudeRatio: amplitudeRatio)
        }
    }


    /// Generate data for specified note and play the sound.
    /// - Parameters:
    ///   - noteInfo: the notes and its note value.
    ///   - waveform: the waveform used to generate sound samples.
    ///   - amplitudeRatio: the ratio used to control the sound loudness.
    public func playNote(
        _ noteInfo: NoteInfo,
        waveform: Waveform,
        amplitudeRatio: Float
    ) {
        let duration  = calculateNoteDuration(noteInfo.noteValue)

        var frequency: Float = 0

        if noteInfo.note == .rest {
            frequency = 0
        } else {
            frequency = frequencyTable[noteInfo.note.rawValue + halfStep]!
        }

        let sampleCount = Int(duration * sampleRate)

        for i in 0..<sampleCount {
            let sample = getNoteSample(
                at: i, frequency: frequency,
                noteDuration: duration,
                waveform: waveform,
                amplitudeRatio: amplitudeRatio)

            buffer16[i * 2] = sample
            buffer16[i * 2 + 1] = sample
        }

        sendData(data: buffer16, count: sampleCount * 2)
    }
}



extension Player {
    /// Calculate data of all notes in a bar.
    func getBarData(
        _ tracks: [[NoteInfo]],
        barIndex: Int,
        waveforms: [Waveform],
        amplitudeRatios: [Float],
        data: inout [Int32]
    ) {
        for i in data.indices {
            data[i] = 0
        }

        for trackIndex in tracks.indices {
            let track = tracks[trackIndex]
            let noteIndices = getNotesInBar(at: barIndex, in: track)
            var start = 0

            for index in noteIndices {
                getNoteData(
                    noteInfo: track[index],
                    startIndex: start,
                    waveform: waveforms[trackIndex],
                    amplitudeRatio: amplitudeRatios[trackIndex],
                    data: &data)

                start += Int(calculateNoteDuration(track[index].noteValue) * sampleRate * 2)
            }
        }
    }

    /// Calculate data of a note.
    func getNoteData(
        noteInfo: NoteInfo,
        startIndex: Int,
        waveform: Waveform,
        amplitudeRatio: Float,
        data: inout [Int32]
    ) {
        guard noteInfo.noteValue > 0 else { return }

        let duration  = calculateNoteDuration(noteInfo.noteValue)

        var frequency: Float = 0
        if noteInfo.note == .rest {
            frequency = 0
        } else {
            frequency = frequencyTable[noteInfo.note.rawValue + halfStep]!
        }

        for i in 0..<Int(duration * sampleRate) {
            let sample = Int32(getNoteSample(at: i, frequency: frequency, noteDuration: duration, waveform: waveform, amplitudeRatio: amplitudeRatio))

            data[i * 2 + startIndex] += sample
            data[i * 2 + startIndex + 1] += sample
        }
    }

    /// Get the indices of notes in the track within a specified bar.
    func getNotesInBar(at barIndex: Int, in track: [NoteInfo]) -> [Int] {
        var indices: [Int] = []
        var index = 0
        var sum: Float = 0

        while Float(timeSignature.beatsPerBar * (barIndex + 1)) - sum > 0.1 && index < track.count {
            sum += Float(timeSignature.noteValuePerBeat) / Float(track[index].noteValue)

            if sum - Float(timeSignature.beatsPerBar * barIndex) > 0.1 {
                indices.append(index)
            }

            index += 1
        }

        return indices
    }

    /// Send the generated data using I2S protocol to play the sound.
    func sendData(data: [Int16], count: Int) {
        data.withUnsafeBytes { ptr in
            let u8Array = ptr.bindMemory(to: UInt8.self)
            speaker.write(Array(u8Array), count: count * 2)
        }
    }

    /// Calculate the duration of the given note value in second.
    func calculateNoteDuration(_ noteValue: Int) -> Float {
        return beatDuration * (Float(timeSignature.noteValuePerBeat) / Float(noteValue))
    }

    /// Calculate a sample at a specified index of a note.
    /// The samples within fade (in/out) duration will be reduced to get a more
    /// natural sound effect.
    func getNoteSample(
        at index: Int,
        frequency: Float,
        noteDuration: Float,
        waveform: Waveform,
        amplitudeRatio: Float
    ) -> Int16 {
        if frequency == 0 { return 0 }

        var sample: Float  = 0

        switch waveform {
        case .square:
            sample = getSquareSample(at: index, frequency: frequency, amplitudeRatio: amplitudeRatio)
        case .triangle:
            sample = getTriangleSample(at: index, frequency: frequency, amplitudeRatio: amplitudeRatio)
        }

        let fadeInEnd = Int(fadeDuration * sampleRate)
        let fadeOutStart = Int((noteDuration - fadeDuration) * sampleRate)
        let fadeSampleCount = fadeDuration * sampleRate
        let sampleCount = Int(noteDuration * sampleRate)

        switch index {
        case 0..<fadeInEnd:
            sample *= Float(index) / fadeSampleCount
        case fadeOutStart..<sampleCount:
            sample *= Float(sampleCount - index) / fadeSampleCount
        default:
            break
        }

        return Int16(sample * Float(amplitude))
    }

    /// Calculate the raw sample of a specified point from a triangle wave.
    /// It sounds much softer than square wave.
    func getTriangleSample(
        at index: Int,
        frequency: Float,
        amplitudeRatio: Float
    ) -> Float {
        let period = sampleRate / frequency

        let sawWave = Float(index) / period - Float(Int(Float(index) / period + 0.5))
        let triWave = 2 * abs(2 * sawWave) - 1

        return triWave * amplitudeRatio
    }

    /// Calculate the raw sample of a specified point from a square wave.
    /// The sound from it will sound a little sharp.
    func getSquareSample(at index: Int,
        frequency: Float,
        amplitudeRatio: Float
    ) -> Float {
        let period = Int(sampleRate / frequency)

        if index % period < period / 2 {
            return -amplitudeRatio
        } else {
            return amplitudeRatio
        }
    }
}