import SwiftIO

/// Play music using the given tracks.
/// The sound sample is generated based on a triangle wave and be sent using I2S protocol.
public class Player {
    public typealias NoteInfo = (note: Note, noteValue: Int)
    public typealias TimeSignature = (beatsPerBar: Int, noteValuePerBeat: Int)

    var bpm: Int
    var sampleRate: Float
    var timeSignature: TimeSignature
    let amplitude = 16383

    var beatDuration: Float { 60.0 / Float(bpm) }

    var speaker: I2SOut

    var buffer = [Int16](repeating: 0, count: 200_000)

    public init(
        _ speaker: I2SOut,
        bpm: Int,
        sampleRate: Float,
        timeSignature: TimeSignature
    ) {
        self.bpm = bpm
        self.speaker = speaker
        self.timeSignature = timeSignature
        self.sampleRate = sampleRate
    }

    /// Calculate and combine the samples of all tracks, and then play the sound.
    ///
    /// - Parameters:
    ///   - tracks: different tracks of a piece of music. A track consists of
    ///   notes and note value. For example, note value of a quarter note is 4,
    ///   note value of a half note is 2.
    ///   - fadeDuration: fade duration in second.
    ///   - halfStep: raise the overall note pitch. 12 half steps constitute an octave.
    public func playTracks(
        _ tracks: [[NoteInfo]],
        fadeDuration: Float = 0.01,
        halfStep: Int = 0
    ) {
        let beatCount = tracks[0].reduce(0) {
            $0 + Float(timeSignature.noteValuePerBeat) / Float($1.noteValue)
        }

        let barCount = Int(beatCount / Float(timeSignature.beatsPerBar))

        for i in 0..<barCount {
            getBarSamples(tracks, barIndex: i, fadeDuration: fadeDuration, halfStep: halfStep, data: &buffer)
            let count = Float(timeSignature.beatsPerBar) * beatDuration * sampleRate * 2
            sendData(data: buffer, count: Int(count))
        }
    }


    /// Calculate all samples of the track and play the sound.
    /// - Parameters:
    ///   - track: score of a melody in forms of notes and note value.
    ///   For example, note value of a quarter note is 4, note value of a half note is 2.
    ///   - fadeDuration: fade duration in second.
    ///   - halfStep: raise the overall note pitch. 12 half steps constitute an octave.
    public func playTrack(
        _ track: [NoteInfo],
        fadeDuration: Float = 0.01,
        halfStep: Int = 0
    ) {
        for noteInfo in track {
            playNote(noteInfo)
        }
    }

    public func playNote(
        _ noteInfo: NoteInfo,
        fadeDuration: Float = 0.01,
        halfStep: Int = 0
    ) {
        let sampleCount = Int(calculateNoteDuration(noteInfo.noteValue) * sampleRate)
        getNoteSamples(noteInfo, fadeDuration: fadeDuration, halfStep: halfStep, data: &buffer)
        sendData(data: buffer, count: sampleCount * 2)
    }

    /// The table is listed to raise note pitch more easily.
    private let frequencyTable: [Int: Float] = [
        0    :    0         ,
        1    :    27.5      ,
        2    :    29.1352   ,
        3    :    30.8677   ,
        4    :    32.7032   ,
        5    :    34.6478   ,
        6    :    36.7081   ,
        7    :    38.8909   ,
        8    :    41.2034   ,
        9    :    43.6535   ,
        10   :    46.2493   ,
        11   :    48.9994   ,
        12   :    51.9131   ,
        13   :    55        ,
        14   :    58.2705   ,
        15   :    61.7354   ,
        16   :    65.4064   ,
        17   :    69.2957   ,
        18   :    73.4162   ,
        19   :    77.7817   ,
        20   :    82.4069   ,
        21   :    87.3071   ,
        22   :    92.4986   ,
        23   :    97.9989   ,
        24   :    103.826   ,
        25   :    110       ,
        26   :    116.541   ,
        27   :    123.471   ,
        28   :    130.813   ,
        29   :    138.591   ,
        30   :    146.832   ,
        31   :    155.563   ,
        32   :    164.814   ,
        33   :    174.614   ,
        34   :    184.997   ,
        35   :    195.998   ,
        36   :    207.652   ,
        37   :    220       ,
        38   :    233.082   ,
        39   :    246.942   ,
        40   :    261.626   ,
        41   :    277.183   ,
        42   :    293.665   ,
        43   :    311.127   ,
        44   :    329.628   ,
        45   :    349.228   ,
        46   :    369.994   ,
        47   :    391.995   ,
        48   :    415.305   ,
        49   :    440       ,
        50   :    466.164   ,
        51   :    493.883   ,
        52   :    523.251   ,
        53   :    554.365   ,
        54   :    587.33    ,
        55   :    622.254   ,
        56   :    659.255   ,
        57   :    698.456   ,
        58   :    739.989   ,
        59   :    783.991   ,
        60   :    830.609   ,
        61   :    880       ,
        62   :    932.328   ,
        63   :    987.767   ,
        64   :    1046.5    ,
        65   :    1108.73   ,
        66   :    1174.66   ,
        67   :    1244.51   ,
        68   :    1318.51   ,
        69   :    1396.91   ,
        70   :    1479.98   ,
        71   :    1567.98   ,
        72   :    1661.22   ,
        73   :    1760      ,
        74   :    1864.66   ,
        75   :    1975.53   ,
        76   :    2093      ,
        77   :    2217.46   ,
        78   :    2349.32   ,
        79   :    2489.02   ,
        80   :    2637.02   ,
        81   :    2793.83   ,
        82   :    2959.96   ,
        83   :    3135.96   ,
        84   :    3322.44   ,
        85   :    3520      ,
        86   :    3729.31   ,
        87   :    3951.07   ,
        88   :    4186.01
    ]

    public enum Note: Int {
        case    A0      =   1
        case    AS0     =   2
        case    B0      =   3
        case    C1      =   4
        case    CS1     =   5
        case    D1      =   6
        case    DS1     =   7
        case    E1      =   8
        case    F1      =   9
        case    FS1     =   10
        case    G1      =   11
        case    GS1     =   12
        case    A1      =   13
        case    AS1     =   14
        case    B1      =   15
        case    C2      =   16
        case    CS2     =   17
        case    D2      =   18
        case    DS2     =   19
        case    E2      =   20
        case    F2      =   21
        case    FS2     =   22
        case    G2      =   23
        case    GS2     =   24
        case    A2      =   25
        case    AS2     =   26
        case    B2      =   27
        case    C3      =   28
        case    CS3     =   29
        case    D3      =   30
        case    DS3     =   31
        case    E3      =   32
        case    F3      =   33
        case    FS3     =   34
        case    G3      =   35
        case    GS3     =   36
        case    A3      =   37
        case    AS3     =   38
        case    B3      =   39
        case    C4      =   40
        case    CS4     =   41
        case    D4      =   42
        case    DS4     =   43
        case    E4      =   44
        case    F4      =   45
        case    FS4     =   46
        case    G4      =   47
        case    GS4     =   48
        case    A4      =   49
        case    AS4     =   50
        case    B4      =   51
        case    C5      =   52
        case    CS5     =   53
        case    D5      =   54
        case    DS5     =   55
        case    E5      =   56
        case    F5      =   57
        case    FS5     =   58
        case    G5      =   59
        case    GS5     =   60
        case    A5      =   61
        case    AS5     =   62
        case    B5      =   63
        case    C6      =   64
        case    CS6     =   65
        case    D6      =   66
        case    DS6     =   67
        case    E6      =   68
        case    F6      =   69
        case    FS6     =   70
        case    G6      =   71
        case    GS6     =   72
        case    A6      =   73
        case    AS6     =   74
        case    B6      =   75
        case    C7      =   76
        case    CS7     =   77
        case    D7      =   78
        case    DS7     =   79
        case    E7      =   80
        case    F7      =   81
        case    FS7     =   82
        case    G7      =   83
        case    GS7     =   84
        case    A7      =   85
        case    AS7     =   86
        case    B7      =   87
        case    C8      =   88
        case    rest    =   0
    }
}



extension Player {
    /// Replace the data with the generated samples of a note.
    func getNoteSamples(
        _ noteInfo: NoteInfo,
        fadeDuration: Float, halfStep: Int,
        data: inout [Int16]
    ) {
        guard noteInfo.noteValue > 0 else { return }
        let duration  = calculateNoteDuration(noteInfo.noteValue)
        let frequency = frequencyTable[noteInfo.note.rawValue + halfStep]!

        for i in 0..<Int(duration * sampleRate) {
            let sample = getNoteSample(at: i, frequency: frequency, noteDuration: duration, fadeDuration: fadeDuration)

            data[i * 2] = sample
            data[i * 2 + 1] = sample
        }
    }

    /// Add the generated samples of a note to the existing samples in data.
    /// In this way, you can get final samples based on multiple tracks.
    func getBothNotesSamples(noteInfo: NoteInfo, startIndex: Int, fade: Float, halfStep: Int, data: inout [Int16]) {
        guard noteInfo.noteValue > 0 else { return }

        let duration  = calculateNoteDuration(noteInfo.noteValue)
        let frequency = frequencyTable[noteInfo.note.rawValue + halfStep]!

        for i in 0..<Int(duration * sampleRate) {
            let sample = getNoteSample(at: i, frequency: frequency, noteDuration: duration, fadeDuration: fade)

            var value: Int16 = 0

            let dataIndex = i * 2 + startIndex

            if sample < 0 {
                if Int16.min - sample <  data[dataIndex] {
                    value = data[dataIndex] + sample
                } else {
                    value = Int16.min
                }
            } else {
                if Int16.max - sample > data[dataIndex] {
                    value = data[dataIndex] + sample
                } else {
                    value = Int16.max
                }
            }

            data[dataIndex] = value
            data[dataIndex + 1] = value
        }
    }

    /// Get the indices of notes in the track within a certain bar.
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

    /// Calculate samples of all notes in a bar.
    func getBarSamples(
        _ tracks: [[NoteInfo]],
        barIndex: Int,
        fadeDuration: Float,
        halfStep: Int,
        data: inout [Int16]
    ) {
        for i in data.indices {
            data[i] = 0
        }

        for track in tracks {
            let noteIndices = getNotesInBar(at: barIndex, in: track)
            var start = 0
            print(noteIndices)

            for index in noteIndices {
                print(track[index])
                getBothNotesSamples(noteInfo: track[index], startIndex: start, fade: fadeDuration, halfStep: halfStep, data: &data)
                start += Int(calculateNoteDuration(track[index].noteValue) * sampleRate * 2)
            }
        }
    }

    /// Send the generated samples using I2S protocol to play the sound.
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
        fadeDuration: Float
    ) -> Int16 {
        if frequency == 0 { return 0 }

        let sampleCount = Int(noteDuration * sampleRate)
        guard index < sampleCount else { return 0 }

        var sample = getTriangleSample(at: index, frequency: frequency) * Float(amplitude)

        let fadeInEnd = Int(fadeDuration * sampleRate)
        let fadeOutStart = Int((noteDuration - fadeDuration) * sampleRate)
        let fadeSampleCount = fadeDuration * sampleRate

        switch index {
        case 0..<fadeInEnd:
            sample *= Float(index) / fadeSampleCount
        case fadeOutStart..<sampleCount:
            sample *= Float(sampleCount - index) / fadeSampleCount
        default:
            break
        }

        return Int16(sample)
    }

    /// Calculate the raw sample of a specified point from a triangle wave.
    func getTriangleSample(
        at index: Int,
        frequency: Float,
        amplitudeRatio: Float = 0.3
    ) -> Float {
        if frequency == 0 { return 0 }

        let period = sampleRate / frequency

        let sawWave = Float(index) / period - Float(Int(Float(index) / period + 0.5))
        let triWave = 2 * abs(2 * sawWave) - 1

        return triWave * amplitudeRatio
    }
}
