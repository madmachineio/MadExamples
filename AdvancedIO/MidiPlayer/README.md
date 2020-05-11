# MidiPlayer

This demo uses multiple PWM channels to produce audio from MIDI file. A MIDI exporter program is needed to generate a .swift file which is compiled with the project.

The PWM outputs are combined and amplified by LM386 audio amplifier.

![image](https://raw.githubusercontent.com/madmachineio/Examples/master/AdvancedIO/MidiPlayer/Amplifier.png)


## Compile the ExporterMidiData

```
cd Examples/AdvancedIO/MidiPlayer/ExportMidi
git clone https://github.com/craigsapp/midifile.git
cd midifile
make library
cd ..
make
```

## Generate MIDI data file

```
cd ExportMidi
./ExportMidiData TheOldDriver.mid
mv MidiData.swift ../Sources/MidiPlayer
```


## Reference Project

[Tiva-C-Embedded](https://github.com/jspicer-ltu/Tiva-C-Embedded/tree/master/Experiment16-PWM-Music)

[midifile](https://github.com/craigsapp/midifile)
