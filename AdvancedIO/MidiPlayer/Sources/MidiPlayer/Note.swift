
enum Note: UInt8 {
    case NONE   =   0
	case C0	  	=	12
	case CS0  	=	13
	case D0	  	=	14
	case DS0  	=	15
	case E0	  	=	16
	case F0	  	=	17
	case FS0  	=	18
	case G0	  	=	19
	case GS0  	=	20
	case A0	  	=	21
	case AS0  	=	22
	case B0	  	=	23
	case C1	  	=	24
	case CS1  	=	25
	case D1	  	=	26
	case DS1  	=	27
	case E1	  	=	28
	case F1	  	=	29
	case FS1  	=	30
	case G1	  	=	31
	case GS1  	=	32
	case A1	  	=	33
	case AS1  	=	34
	case B1	  	=	35
	case C2	  	=	36
	case CS2  	=	37
	case D2	  	=	38
	case DS2  	=	39
	case E2	  	=	40
	case F2	  	=	41
	case FS2  	=	42
	case G2	  	=	43
	case GS2  	=	44
	case A2	  	=	45
	case AS2  	=	46
	case B2	  	=	47
	case C3	  	=	48
	case CS3  	=	49
	case D3	  	=	50
	case DS3  	=	51
	case E3	  	=	52
	case F3	  	=	53
	case FS3  	=	54
	case G3	  	=	55
	case GS3  	=	56
	case A3	  	=	57
	case AS3  	=	58
	case B3	  	=	59
	case C4	  	=	60
	case CS4  	=	61
	case D4	  	=	62
	case DS4  	=	63
	case E4	  	=	64
	case F4	  	=	65
	case FS4  	=	66
	case G4	  	=	67
	case GS4  	=	68
	case A4		=	69
	case AS4	=	70
	case B4		=	71
	case C5		=	72
	case CS5	=	73
	case D5		=	74
	case DS5	=	75
	case E5		=	76
	case F5		=	77
	case FS5	=	78
	case G5		=	79
	case GS5	=	80
	case A5		=	81
	case AS5	=	82
	case B5		=	83
	case C6		=	84
	case CS6	=	85
	case D6		=	86
	case DS6	=	87
	case E6		=	88
	case F6		=	89
	case FS6	=	90
	case G6		=	91
	case GS6	=	92
	case A6		=	93
	case AS6	=	94
	case B6		=	95
	case C7		=	96
	case CS7	=	97
	case D7		=	98
	case DS7	=	99
	case E7		=	100
	case F7		=	101
	case FS7	=	102
	case G7		=	103
	case GS7	=	104
	case A7		=	105
	case AS7	=	106
	case B7		=	107
	case C8		=	108
	case CS8	=	109
	case D8		=	110
	case DS8	=	111
	case E8		=	112
	case F8		=	113
	case FS8	=	114
	case G8		=	115
	case GS8	=	116
	case A8		=	117
	case AS8	=	118
	case B8		=	119
}

struct NotePeriodTable {
	static let table: [UInt16] = [
		61156,
		57724,
		54484,
		51426,
		48540,
		45815,
		43244,
		40817,
		38526,
		36364,
		34323,
		32396,
		30578,
		28862,
		27242,
		25713,
		24270,
		22908,
		21622,
		20408,
		19263,
		18182,
		17161,
		16198,
		15289,
		14431,
		13621,
		12856,
		12135,
		11454,
		10811,
		10204,
		9631,
		9091,
		8581,
		8099,
		7645,
		7215,
		6811,
		6428,
		6067,
		5727,
		5405,
		5102,
		4816,
		4545,
		4290,
		4050,
		3822,
		3608,
		3405,
		3214,
		3034,
		2863,
		2703,
		2551,
		2408,
		2273,
		2145,
		2025,
		1911,
		1804,
		1703,
		1607,
		1517,
		1432,
		1351,
		1276,
		1204,
		1136,
		1073,
		1012,
		956,
		902,
		851,
		804,
		758,
		716,
		676,
		638,
		602,
		568,
		536,
		506,
		478,
		451,
		426,
		402,
		379,
		358,
		338,
		319,
		301,
		284,
		268,
		253,
		239,
		225,
		213,
		201,
		190,
		179,
		169,
		159,
		150,
		142,
		134,
		127
	]

	static let range = 12...119
	static func getPeriod(_ note: Note) -> Int? {
		var mark = Int(note.rawValue)
		if NotePeriodTable.range.contains(mark) {
			mark -= NotePeriodTable.range.lowerBound
			return Int(NotePeriodTable.table[mark])
		} else {
			return nil
		}
	}
}
