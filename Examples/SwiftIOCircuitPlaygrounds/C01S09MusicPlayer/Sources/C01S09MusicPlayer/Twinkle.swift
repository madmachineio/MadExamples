struct Twinkle {
    static let track0: [Player.NoteInfo] = [
        (.C4, 4),
        (.C4, 4),

        (.G4, 4),
        (.G4, 4),

        (.A4, 4),
        (.A4, 4),

        (.G4, 4),
        (.G4, 4),

        (.F4, 4),
        (.F4, 4),

        (.E4, 4),
        (.E4, 4),

        (.D4, 4),
        (.D4, 8),
        (.D4, 16),
        (.E4, 16),

        (.C4, 2)
    ]

    static let track1: [Player.NoteInfo] = [
        (.C2, 4),
        (.C3, 4),
        
        (.E3, 4),
        (.C3, 4),

        (.F3, 4),
        (.C3, 4),

        (.E3, 4),
        (.C3, 4),

        (.D3, 4),
        (.B2, 4),

        (.C3, 4),
        (.A2, 4),

        (.F2, 4),
        (.G2, 4),
        
        (.C2, 2)
    ]

    static let tracks = [track0, track1]

    static let bpm = 120
    static let timeSignature = (2, 4)
}
