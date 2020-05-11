FILE      = ExportMidiData
SRC       = $(FILE).cpp
OUTPUT    = -o $(FILE) 
INCDIR    = ./midifile/include
LIBFILE   = ./midifile/lib/libmidifile.a
COMPILER  = g++
PREFLAGS  = -Wall -O3 -I$(INCDIR)

# Using C++ 2011 standard:
PREFLAGS += -std=c++11

# targets which don't actually refer to files
.PHONY : all


all:
	$(COMPILER) $(SRC) $(LIBFILE) $(PREFLAGS) $(OUTPUT)


