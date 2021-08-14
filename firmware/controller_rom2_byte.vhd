
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"bf",x"e4",x"f9",x"c2"),
     1 => (x"c2",x"80",x"c8",x"48"),
     2 => (x"26",x"58",x"e8",x"f9"),
     3 => (x"26",x"4c",x"26",x"4d"),
     4 => (x"1e",x"4f",x"26",x"4b"),
     5 => (x"4b",x"71",x"1e",x"73"),
     6 => (x"02",x"9a",x"4a",x"13"),
     7 => (x"49",x"72",x"87",x"cb"),
     8 => (x"13",x"87",x"e1",x"fe"),
     9 => (x"f5",x"05",x"9a",x"4a"),
    10 => (x"26",x"4b",x"26",x"87"),
    11 => (x"f9",x"c2",x"1e",x"4f"),
    12 => (x"c2",x"49",x"bf",x"e4"),
    13 => (x"c1",x"48",x"e4",x"f9"),
    14 => (x"c0",x"c4",x"78",x"a1"),
    15 => (x"db",x"03",x"a9",x"b7"),
    16 => (x"48",x"d4",x"ff",x"87"),
    17 => (x"bf",x"e8",x"f9",x"c2"),
    18 => (x"e4",x"f9",x"c2",x"78"),
    19 => (x"f9",x"c2",x"49",x"bf"),
    20 => (x"a1",x"c1",x"48",x"e4"),
    21 => (x"b7",x"c0",x"c4",x"78"),
    22 => (x"87",x"e5",x"04",x"a9"),
    23 => (x"c8",x"48",x"d0",x"ff"),
    24 => (x"f0",x"f9",x"c2",x"78"),
    25 => (x"26",x"78",x"c0",x"48"),
    26 => (x"00",x"00",x"00",x"4f"),
    27 => (x"00",x"00",x"00",x"00"),
    28 => (x"00",x"00",x"00",x"00"),
    29 => (x"5f",x"00",x"00",x"00"),
    30 => (x"00",x"00",x"00",x"5f"),
    31 => (x"00",x"03",x"03",x"00"),
    32 => (x"00",x"00",x"03",x"03"),
    33 => (x"14",x"7f",x"7f",x"14"),
    34 => (x"00",x"14",x"7f",x"7f"),
    35 => (x"6b",x"2e",x"24",x"00"),
    36 => (x"00",x"12",x"3a",x"6b"),
    37 => (x"18",x"36",x"6a",x"4c"),
    38 => (x"00",x"32",x"56",x"6c"),
    39 => (x"59",x"4f",x"7e",x"30"),
    40 => (x"40",x"68",x"3a",x"77"),
    41 => (x"07",x"04",x"00",x"00"),
    42 => (x"00",x"00",x"00",x"03"),
    43 => (x"3e",x"1c",x"00",x"00"),
    44 => (x"00",x"00",x"41",x"63"),
    45 => (x"63",x"41",x"00",x"00"),
    46 => (x"00",x"00",x"1c",x"3e"),
    47 => (x"1c",x"3e",x"2a",x"08"),
    48 => (x"08",x"2a",x"3e",x"1c"),
    49 => (x"3e",x"08",x"08",x"00"),
    50 => (x"00",x"08",x"08",x"3e"),
    51 => (x"e0",x"80",x"00",x"00"),
    52 => (x"00",x"00",x"00",x"60"),
    53 => (x"08",x"08",x"08",x"00"),
    54 => (x"00",x"08",x"08",x"08"),
    55 => (x"60",x"00",x"00",x"00"),
    56 => (x"00",x"00",x"00",x"60"),
    57 => (x"18",x"30",x"60",x"40"),
    58 => (x"01",x"03",x"06",x"0c"),
    59 => (x"59",x"7f",x"3e",x"00"),
    60 => (x"00",x"3e",x"7f",x"4d"),
    61 => (x"7f",x"06",x"04",x"00"),
    62 => (x"00",x"00",x"00",x"7f"),
    63 => (x"71",x"63",x"42",x"00"),
    64 => (x"00",x"46",x"4f",x"59"),
    65 => (x"49",x"63",x"22",x"00"),
    66 => (x"00",x"36",x"7f",x"49"),
    67 => (x"13",x"16",x"1c",x"18"),
    68 => (x"00",x"10",x"7f",x"7f"),
    69 => (x"45",x"67",x"27",x"00"),
    70 => (x"00",x"39",x"7d",x"45"),
    71 => (x"4b",x"7e",x"3c",x"00"),
    72 => (x"00",x"30",x"79",x"49"),
    73 => (x"71",x"01",x"01",x"00"),
    74 => (x"00",x"07",x"0f",x"79"),
    75 => (x"49",x"7f",x"36",x"00"),
    76 => (x"00",x"36",x"7f",x"49"),
    77 => (x"49",x"4f",x"06",x"00"),
    78 => (x"00",x"1e",x"3f",x"69"),
    79 => (x"66",x"00",x"00",x"00"),
    80 => (x"00",x"00",x"00",x"66"),
    81 => (x"e6",x"80",x"00",x"00"),
    82 => (x"00",x"00",x"00",x"66"),
    83 => (x"14",x"08",x"08",x"00"),
    84 => (x"00",x"22",x"22",x"14"),
    85 => (x"14",x"14",x"14",x"00"),
    86 => (x"00",x"14",x"14",x"14"),
    87 => (x"14",x"22",x"22",x"00"),
    88 => (x"00",x"08",x"08",x"14"),
    89 => (x"51",x"03",x"02",x"00"),
    90 => (x"00",x"06",x"0f",x"59"),
    91 => (x"5d",x"41",x"7f",x"3e"),
    92 => (x"00",x"1e",x"1f",x"55"),
    93 => (x"09",x"7f",x"7e",x"00"),
    94 => (x"00",x"7e",x"7f",x"09"),
    95 => (x"49",x"7f",x"7f",x"00"),
    96 => (x"00",x"36",x"7f",x"49"),
    97 => (x"63",x"3e",x"1c",x"00"),
    98 => (x"00",x"41",x"41",x"41"),
    99 => (x"41",x"7f",x"7f",x"00"),
   100 => (x"00",x"1c",x"3e",x"63"),
   101 => (x"49",x"7f",x"7f",x"00"),
   102 => (x"00",x"41",x"41",x"49"),
   103 => (x"09",x"7f",x"7f",x"00"),
   104 => (x"00",x"01",x"01",x"09"),
   105 => (x"41",x"7f",x"3e",x"00"),
   106 => (x"00",x"7a",x"7b",x"49"),
   107 => (x"08",x"7f",x"7f",x"00"),
   108 => (x"00",x"7f",x"7f",x"08"),
   109 => (x"7f",x"41",x"00",x"00"),
   110 => (x"00",x"00",x"41",x"7f"),
   111 => (x"40",x"60",x"20",x"00"),
   112 => (x"00",x"3f",x"7f",x"40"),
   113 => (x"1c",x"08",x"7f",x"7f"),
   114 => (x"00",x"41",x"63",x"36"),
   115 => (x"40",x"7f",x"7f",x"00"),
   116 => (x"00",x"40",x"40",x"40"),
   117 => (x"0c",x"06",x"7f",x"7f"),
   118 => (x"00",x"7f",x"7f",x"06"),
   119 => (x"0c",x"06",x"7f",x"7f"),
   120 => (x"00",x"7f",x"7f",x"18"),
   121 => (x"41",x"7f",x"3e",x"00"),
   122 => (x"00",x"3e",x"7f",x"41"),
   123 => (x"09",x"7f",x"7f",x"00"),
   124 => (x"00",x"06",x"0f",x"09"),
   125 => (x"61",x"41",x"7f",x"3e"),
   126 => (x"00",x"40",x"7e",x"7f"),
   127 => (x"09",x"7f",x"7f",x"00"),
   128 => (x"00",x"66",x"7f",x"19"),
   129 => (x"4d",x"6f",x"26",x"00"),
   130 => (x"00",x"32",x"7b",x"59"),
   131 => (x"7f",x"01",x"01",x"00"),
   132 => (x"00",x"01",x"01",x"7f"),
   133 => (x"40",x"7f",x"3f",x"00"),
   134 => (x"00",x"3f",x"7f",x"40"),
   135 => (x"70",x"3f",x"0f",x"00"),
   136 => (x"00",x"0f",x"3f",x"70"),
   137 => (x"18",x"30",x"7f",x"7f"),
   138 => (x"00",x"7f",x"7f",x"30"),
   139 => (x"1c",x"36",x"63",x"41"),
   140 => (x"41",x"63",x"36",x"1c"),
   141 => (x"7c",x"06",x"03",x"01"),
   142 => (x"01",x"03",x"06",x"7c"),
   143 => (x"4d",x"59",x"71",x"61"),
   144 => (x"00",x"41",x"43",x"47"),
   145 => (x"7f",x"7f",x"00",x"00"),
   146 => (x"00",x"00",x"41",x"41"),
   147 => (x"0c",x"06",x"03",x"01"),
   148 => (x"40",x"60",x"30",x"18"),
   149 => (x"41",x"41",x"00",x"00"),
   150 => (x"00",x"00",x"7f",x"7f"),
   151 => (x"03",x"06",x"0c",x"08"),
   152 => (x"00",x"08",x"0c",x"06"),
   153 => (x"80",x"80",x"80",x"80"),
   154 => (x"00",x"80",x"80",x"80"),
   155 => (x"03",x"00",x"00",x"00"),
   156 => (x"00",x"00",x"04",x"07"),
   157 => (x"54",x"74",x"20",x"00"),
   158 => (x"00",x"78",x"7c",x"54"),
   159 => (x"44",x"7f",x"7f",x"00"),
   160 => (x"00",x"38",x"7c",x"44"),
   161 => (x"44",x"7c",x"38",x"00"),
   162 => (x"00",x"00",x"44",x"44"),
   163 => (x"44",x"7c",x"38",x"00"),
   164 => (x"00",x"7f",x"7f",x"44"),
   165 => (x"54",x"7c",x"38",x"00"),
   166 => (x"00",x"18",x"5c",x"54"),
   167 => (x"7f",x"7e",x"04",x"00"),
   168 => (x"00",x"00",x"05",x"05"),
   169 => (x"a4",x"bc",x"18",x"00"),
   170 => (x"00",x"7c",x"fc",x"a4"),
   171 => (x"04",x"7f",x"7f",x"00"),
   172 => (x"00",x"78",x"7c",x"04"),
   173 => (x"3d",x"00",x"00",x"00"),
   174 => (x"00",x"00",x"40",x"7d"),
   175 => (x"80",x"80",x"80",x"00"),
   176 => (x"00",x"00",x"7d",x"fd"),
   177 => (x"10",x"7f",x"7f",x"00"),
   178 => (x"00",x"44",x"6c",x"38"),
   179 => (x"3f",x"00",x"00",x"00"),
   180 => (x"00",x"00",x"40",x"7f"),
   181 => (x"18",x"0c",x"7c",x"7c"),
   182 => (x"00",x"78",x"7c",x"0c"),
   183 => (x"04",x"7c",x"7c",x"00"),
   184 => (x"00",x"78",x"7c",x"04"),
   185 => (x"44",x"7c",x"38",x"00"),
   186 => (x"00",x"38",x"7c",x"44"),
   187 => (x"24",x"fc",x"fc",x"00"),
   188 => (x"00",x"18",x"3c",x"24"),
   189 => (x"24",x"3c",x"18",x"00"),
   190 => (x"00",x"fc",x"fc",x"24"),
   191 => (x"04",x"7c",x"7c",x"00"),
   192 => (x"00",x"08",x"0c",x"04"),
   193 => (x"54",x"5c",x"48",x"00"),
   194 => (x"00",x"20",x"74",x"54"),
   195 => (x"7f",x"3f",x"04",x"00"),
   196 => (x"00",x"00",x"44",x"44"),
   197 => (x"40",x"7c",x"3c",x"00"),
   198 => (x"00",x"7c",x"7c",x"40"),
   199 => (x"60",x"3c",x"1c",x"00"),
   200 => (x"00",x"1c",x"3c",x"60"),
   201 => (x"30",x"60",x"7c",x"3c"),
   202 => (x"00",x"3c",x"7c",x"60"),
   203 => (x"10",x"38",x"6c",x"44"),
   204 => (x"00",x"44",x"6c",x"38"),
   205 => (x"e0",x"bc",x"1c",x"00"),
   206 => (x"00",x"1c",x"3c",x"60"),
   207 => (x"74",x"64",x"44",x"00"),
   208 => (x"00",x"44",x"4c",x"5c"),
   209 => (x"3e",x"08",x"08",x"00"),
   210 => (x"00",x"41",x"41",x"77"),
   211 => (x"7f",x"00",x"00",x"00"),
   212 => (x"00",x"00",x"00",x"7f"),
   213 => (x"77",x"41",x"41",x"00"),
   214 => (x"00",x"08",x"08",x"3e"),
   215 => (x"03",x"01",x"01",x"02"),
   216 => (x"00",x"01",x"02",x"02"),
   217 => (x"7f",x"7f",x"7f",x"7f"),
   218 => (x"00",x"7f",x"7f",x"7f"),
   219 => (x"1c",x"1c",x"08",x"08"),
   220 => (x"7f",x"7f",x"3e",x"3e"),
   221 => (x"3e",x"3e",x"7f",x"7f"),
   222 => (x"08",x"08",x"1c",x"1c"),
   223 => (x"7c",x"18",x"10",x"00"),
   224 => (x"00",x"10",x"18",x"7c"),
   225 => (x"7c",x"30",x"10",x"00"),
   226 => (x"00",x"10",x"30",x"7c"),
   227 => (x"60",x"60",x"30",x"10"),
   228 => (x"00",x"06",x"1e",x"78"),
   229 => (x"18",x"3c",x"66",x"42"),
   230 => (x"00",x"42",x"66",x"3c"),
   231 => (x"c2",x"6a",x"38",x"78"),
   232 => (x"00",x"38",x"6c",x"c6"),
   233 => (x"60",x"00",x"00",x"60"),
   234 => (x"00",x"60",x"00",x"00"),
   235 => (x"5c",x"5b",x"5e",x"0e"),
   236 => (x"86",x"fc",x"0e",x"5d"),
   237 => (x"f9",x"c2",x"7e",x"71"),
   238 => (x"c0",x"4c",x"bf",x"f8"),
   239 => (x"c4",x"1e",x"c0",x"4b"),
   240 => (x"c4",x"02",x"ab",x"66"),
   241 => (x"c2",x"4d",x"c0",x"87"),
   242 => (x"75",x"4d",x"c1",x"87"),
   243 => (x"ee",x"49",x"73",x"1e"),
   244 => (x"86",x"c8",x"87",x"e1"),
   245 => (x"ef",x"49",x"e0",x"c0"),
   246 => (x"a4",x"c4",x"87",x"ea"),
   247 => (x"f0",x"49",x"6a",x"4a"),
   248 => (x"c8",x"f1",x"87",x"f1"),
   249 => (x"c1",x"84",x"cc",x"87"),
   250 => (x"ab",x"b7",x"c8",x"83"),
   251 => (x"87",x"cd",x"ff",x"04"),
   252 => (x"4d",x"26",x"8e",x"fc"),
   253 => (x"4b",x"26",x"4c",x"26"),
   254 => (x"71",x"1e",x"4f",x"26"),
   255 => (x"fc",x"f9",x"c2",x"4a"),
   256 => (x"fc",x"f9",x"c2",x"5a"),
   257 => (x"49",x"78",x"c7",x"48"),
   258 => (x"26",x"87",x"e1",x"fe"),
   259 => (x"1e",x"73",x"1e",x"4f"),
   260 => (x"0b",x"fc",x"4b",x"71"),
   261 => (x"4a",x"73",x"0b",x"7b"),
   262 => (x"c0",x"c1",x"9a",x"c1"),
   263 => (x"c5",x"ed",x"49",x"a2"),
   264 => (x"fc",x"dd",x"c2",x"87"),
   265 => (x"26",x"4b",x"26",x"5b"),
   266 => (x"4a",x"71",x"1e",x"4f"),
   267 => (x"72",x"1e",x"66",x"c4"),
   268 => (x"87",x"cb",x"ec",x"49"),
   269 => (x"4f",x"26",x"8e",x"fc"),
   270 => (x"48",x"d4",x"ff",x"1e"),
   271 => (x"ff",x"78",x"ff",x"c3"),
   272 => (x"e1",x"c0",x"48",x"d0"),
   273 => (x"48",x"d4",x"ff",x"78"),
   274 => (x"48",x"71",x"78",x"c1"),
   275 => (x"d4",x"ff",x"30",x"c4"),
   276 => (x"d0",x"ff",x"78",x"08"),
   277 => (x"78",x"e0",x"c0",x"48"),
   278 => (x"5e",x"0e",x"4f",x"26"),
   279 => (x"0e",x"5d",x"5c",x"5b"),
   280 => (x"a6",x"c8",x"86",x"ec"),
   281 => (x"c4",x"78",x"c0",x"48"),
   282 => (x"78",x"bf",x"ec",x"80"),
   283 => (x"f9",x"c2",x"80",x"f8"),
   284 => (x"c2",x"78",x"bf",x"f8"),
   285 => (x"4c",x"bf",x"c0",x"fa"),
   286 => (x"c2",x"4d",x"bf",x"e8"),
   287 => (x"49",x"bf",x"f8",x"dd"),
   288 => (x"c7",x"87",x"ff",x"e4"),
   289 => (x"87",x"ff",x"e8",x"49"),
   290 => (x"99",x"c2",x"49",x"70"),
   291 => (x"c2",x"87",x"d0",x"05"),
   292 => (x"49",x"bf",x"f0",x"dd"),
   293 => (x"66",x"cc",x"b9",x"ff"),
   294 => (x"02",x"99",x"c1",x"99"),
   295 => (x"c8",x"87",x"cb",x"c2"),
   296 => (x"c8",x"ff",x"48",x"a6"),
   297 => (x"49",x"c7",x"78",x"bf"),
   298 => (x"70",x"87",x"dc",x"e8"),
   299 => (x"71",x"7e",x"74",x"49"),
   300 => (x"87",x"cd",x"05",x"99"),
   301 => (x"c1",x"49",x"66",x"cc"),
   302 => (x"71",x"7e",x"74",x"99"),
   303 => (x"c4",x"c1",x"02",x"99"),
   304 => (x"4c",x"c8",x"ff",x"87"),
   305 => (x"cc",x"4b",x"66",x"c8"),
   306 => (x"bf",x"ec",x"48",x"a6"),
   307 => (x"87",x"f2",x"e3",x"78"),
   308 => (x"6c",x"5b",x"a6",x"cc"),
   309 => (x"d4",x"88",x"73",x"48"),
   310 => (x"e8",x"cf",x"58",x"a6"),
   311 => (x"87",x"d1",x"06",x"a8"),
   312 => (x"bf",x"ec",x"dd",x"c2"),
   313 => (x"c2",x"b9",x"c1",x"49"),
   314 => (x"71",x"59",x"f0",x"dd"),
   315 => (x"6c",x"87",x"c9",x"fd"),
   316 => (x"e7",x"49",x"c7",x"4b"),
   317 => (x"98",x"70",x"87",x"d1"),
   318 => (x"87",x"cb",x"ff",x"05"),
   319 => (x"c1",x"49",x"66",x"cc"),
   320 => (x"c2",x"ff",x"05",x"99"),
   321 => (x"c2",x"4c",x"6e",x"87"),
   322 => (x"4a",x"bf",x"f8",x"dd"),
   323 => (x"dd",x"c2",x"ba",x"c1"),
   324 => (x"0a",x"fc",x"5a",x"fc"),
   325 => (x"9a",x"c1",x"0a",x"7a"),
   326 => (x"49",x"a2",x"c0",x"c1"),
   327 => (x"c1",x"87",x"c7",x"e9"),
   328 => (x"e2",x"e6",x"49",x"da"),
   329 => (x"48",x"a6",x"c8",x"87"),
   330 => (x"dd",x"c2",x"78",x"c1"),
   331 => (x"66",x"cc",x"48",x"f0"),
   332 => (x"f8",x"dd",x"c2",x"78"),
   333 => (x"c7",x"c1",x"05",x"bf"),
   334 => (x"c0",x"c0",x"c8",x"87"),
   335 => (x"dc",x"dd",x"c2",x"4b"),
   336 => (x"14",x"4c",x"6e",x"7e"),
   337 => (x"87",x"ff",x"e5",x"49"),
   338 => (x"c0",x"02",x"98",x"70"),
   339 => (x"b5",x"73",x"87",x"c2"),
   340 => (x"05",x"2b",x"b7",x"c1"),
   341 => (x"75",x"87",x"ec",x"ff"),
   342 => (x"99",x"ff",x"c3",x"49"),
   343 => (x"49",x"c0",x"1e",x"71"),
   344 => (x"75",x"87",x"c6",x"fb"),
   345 => (x"29",x"b7",x"c8",x"49"),
   346 => (x"49",x"c1",x"1e",x"71"),
   347 => (x"c8",x"87",x"fa",x"fa"),
   348 => (x"49",x"fd",x"c3",x"86"),
   349 => (x"c3",x"87",x"d0",x"e5"),
   350 => (x"ca",x"e5",x"49",x"fa"),
   351 => (x"87",x"ce",x"c7",x"87"),
   352 => (x"ff",x"c3",x"49",x"75"),
   353 => (x"2d",x"b7",x"c8",x"99"),
   354 => (x"9d",x"75",x"b5",x"71"),
   355 => (x"87",x"e0",x"c0",x"02"),
   356 => (x"7e",x"bf",x"c8",x"ff"),
   357 => (x"dd",x"c2",x"49",x"6e"),
   358 => (x"c2",x"89",x"bf",x"f4"),
   359 => (x"c0",x"03",x"a9",x"e0"),
   360 => (x"4d",x"c0",x"87",x"c5"),
   361 => (x"c2",x"87",x"cf",x"c0"),
   362 => (x"6e",x"48",x"f4",x"dd"),
   363 => (x"87",x"c6",x"c0",x"78"),
   364 => (x"48",x"f4",x"dd",x"c2"),
   365 => (x"49",x"75",x"78",x"c0"),
   366 => (x"c0",x"05",x"99",x"c8"),
   367 => (x"f5",x"c3",x"87",x"ce"),
   368 => (x"87",x"c3",x"e4",x"49"),
   369 => (x"99",x"c2",x"49",x"70"),
   370 => (x"87",x"ea",x"c0",x"02"),
   371 => (x"bf",x"fc",x"f9",x"c2"),
   372 => (x"87",x"ca",x"c0",x"02"),
   373 => (x"c2",x"88",x"c1",x"48"),
   374 => (x"c0",x"58",x"c0",x"fa"),
   375 => (x"66",x"c4",x"87",x"d3"),
   376 => (x"80",x"e0",x"c1",x"48"),
   377 => (x"bf",x"6e",x"7e",x"70"),
   378 => (x"87",x"c5",x"c0",x"02"),
   379 => (x"73",x"49",x"ff",x"4b"),
   380 => (x"48",x"a6",x"c8",x"0f"),
   381 => (x"49",x"75",x"78",x"c1"),
   382 => (x"c0",x"05",x"99",x"c4"),
   383 => (x"f2",x"c3",x"87",x"ce"),
   384 => (x"87",x"c3",x"e3",x"49"),
   385 => (x"99",x"c2",x"49",x"70"),
   386 => (x"87",x"f1",x"c0",x"02"),
   387 => (x"bf",x"fc",x"f9",x"c2"),
   388 => (x"c7",x"48",x"6e",x"7e"),
   389 => (x"c0",x"03",x"a8",x"b7"),
   390 => (x"48",x"6e",x"87",x"cb"),
   391 => (x"fa",x"c2",x"80",x"c1"),
   392 => (x"d3",x"c0",x"58",x"c0"),
   393 => (x"48",x"66",x"c4",x"87"),
   394 => (x"70",x"80",x"e0",x"c1"),
   395 => (x"02",x"bf",x"6e",x"7e"),
   396 => (x"4b",x"87",x"c5",x"c0"),
   397 => (x"0f",x"73",x"49",x"fe"),
   398 => (x"c1",x"48",x"a6",x"c8"),
   399 => (x"49",x"fd",x"c3",x"78"),
   400 => (x"70",x"87",x"c4",x"e2"),
   401 => (x"02",x"99",x"c2",x"49"),
   402 => (x"c2",x"87",x"e6",x"c0"),
   403 => (x"02",x"bf",x"fc",x"f9"),
   404 => (x"c2",x"87",x"c9",x"c0"),
   405 => (x"c0",x"48",x"fc",x"f9"),
   406 => (x"87",x"d0",x"c0",x"78"),
   407 => (x"c1",x"4a",x"66",x"c4"),
   408 => (x"02",x"6a",x"82",x"e0"),
   409 => (x"4b",x"87",x"c5",x"c0"),
   410 => (x"0f",x"73",x"49",x"fd"),
   411 => (x"c1",x"48",x"a6",x"c8"),
   412 => (x"49",x"fa",x"c3",x"78"),
   413 => (x"70",x"87",x"d0",x"e1"),
   414 => (x"02",x"99",x"c2",x"49"),
   415 => (x"c2",x"87",x"ed",x"c0"),
   416 => (x"48",x"bf",x"fc",x"f9"),
   417 => (x"03",x"a8",x"b7",x"c7"),
   418 => (x"c2",x"87",x"c9",x"c0"),
   419 => (x"c7",x"48",x"fc",x"f9"),
   420 => (x"87",x"d3",x"c0",x"78"),
   421 => (x"c1",x"48",x"66",x"c4"),
   422 => (x"7e",x"70",x"80",x"e0"),
   423 => (x"c0",x"02",x"bf",x"6e"),
   424 => (x"fc",x"4b",x"87",x"c5"),
   425 => (x"c8",x"0f",x"73",x"49"),
   426 => (x"78",x"c1",x"48",x"a6"),
   427 => (x"f0",x"c3",x"48",x"75"),
   428 => (x"48",x"7e",x"70",x"98"),
   429 => (x"ce",x"c0",x"05",x"98"),
   430 => (x"49",x"da",x"c1",x"87"),
   431 => (x"70",x"87",x"c8",x"e0"),
   432 => (x"02",x"99",x"c2",x"49"),
   433 => (x"6e",x"87",x"ca",x"c1"),
   434 => (x"87",x"cd",x"c0",x"05"),
   435 => (x"ff",x"49",x"da",x"c1"),
   436 => (x"70",x"87",x"f4",x"df"),
   437 => (x"e8",x"c0",x"02",x"98"),
   438 => (x"49",x"bf",x"e8",x"87"),
   439 => (x"9b",x"ff",x"c3",x"4b"),
   440 => (x"71",x"29",x"b7",x"c8"),
   441 => (x"d9",x"db",x"ff",x"b3"),
   442 => (x"c3",x"49",x"73",x"87"),
   443 => (x"99",x"71",x"99",x"f0"),
   444 => (x"87",x"e5",x"ff",x"05"),
   445 => (x"ff",x"49",x"da",x"c1"),
   446 => (x"70",x"87",x"cc",x"df"),
   447 => (x"d8",x"ff",x"05",x"98"),
   448 => (x"fc",x"f9",x"c2",x"87"),
   449 => (x"cc",x"4b",x"49",x"bf"),
   450 => (x"83",x"66",x"c4",x"93"),
   451 => (x"73",x"71",x"4b",x"6b"),
   452 => (x"02",x"9c",x"74",x"0f"),
   453 => (x"6c",x"87",x"e9",x"c0"),
   454 => (x"87",x"e4",x"c0",x"02"),
   455 => (x"de",x"ff",x"49",x"6c"),
   456 => (x"49",x"70",x"87",x"e5"),
   457 => (x"c0",x"02",x"99",x"c1"),
   458 => (x"a4",x"c4",x"87",x"cb"),
   459 => (x"fc",x"f9",x"c2",x"4b"),
   460 => (x"4b",x"6b",x"49",x"bf"),
   461 => (x"02",x"84",x"c8",x"0f"),
   462 => (x"6c",x"87",x"c5",x"c0"),
   463 => (x"87",x"dc",x"ff",x"05"),
   464 => (x"c0",x"02",x"66",x"c8"),
   465 => (x"f9",x"c2",x"87",x"c8"),
   466 => (x"f1",x"49",x"bf",x"fc"),
   467 => (x"8e",x"ec",x"87",x"de"),
   468 => (x"4c",x"26",x"4d",x"26"),
   469 => (x"4f",x"26",x"4b",x"26"),
   470 => (x"00",x"00",x"00",x"10"),
   471 => (x"14",x"11",x"12",x"58"),
   472 => (x"23",x"1c",x"1b",x"1d"),
   473 => (x"94",x"91",x"59",x"5a"),
   474 => (x"f4",x"eb",x"f2",x"f5"),
   475 => (x"00",x"00",x"00",x"00"),
   476 => (x"00",x"00",x"00",x"00"),
   477 => (x"00",x"00",x"00",x"00"),
   478 => (x"00",x"00",x"00",x"00"),
   479 => (x"5c",x"5b",x"5e",x"0e"),
   480 => (x"4b",x"71",x"0e",x"5d"),
   481 => (x"d0",x"4c",x"d4",x"ff"),
   482 => (x"78",x"c0",x"48",x"66"),
   483 => (x"dd",x"ff",x"49",x"d6"),
   484 => (x"ff",x"c3",x"87",x"f2"),
   485 => (x"c3",x"49",x"6c",x"7c"),
   486 => (x"4d",x"71",x"99",x"ff"),
   487 => (x"99",x"f0",x"c3",x"49"),
   488 => (x"05",x"a9",x"e0",x"c1"),
   489 => (x"ff",x"c3",x"87",x"cb"),
   490 => (x"c3",x"48",x"6c",x"7c"),
   491 => (x"08",x"66",x"d0",x"98"),
   492 => (x"7c",x"ff",x"c3",x"78"),
   493 => (x"c8",x"49",x"4a",x"6c"),
   494 => (x"7c",x"ff",x"c3",x"31"),
   495 => (x"b2",x"71",x"4a",x"6c"),
   496 => (x"31",x"c8",x"49",x"72"),
   497 => (x"6c",x"7c",x"ff",x"c3"),
   498 => (x"72",x"b2",x"71",x"4a"),
   499 => (x"c3",x"31",x"c8",x"49"),
   500 => (x"4a",x"6c",x"7c",x"ff"),
   501 => (x"d0",x"ff",x"b2",x"71"),
   502 => (x"78",x"e0",x"c0",x"48"),
   503 => (x"c2",x"02",x"9b",x"73"),
   504 => (x"75",x"7b",x"72",x"87"),
   505 => (x"26",x"4d",x"26",x"48"),
   506 => (x"26",x"4b",x"26",x"4c"),
   507 => (x"4f",x"26",x"1e",x"4f"),
   508 => (x"5c",x"5b",x"5e",x"0e"),
   509 => (x"76",x"86",x"f8",x"0e"),
   510 => (x"49",x"a6",x"c8",x"1e"),
   511 => (x"c4",x"87",x"fd",x"fd"),
   512 => (x"6e",x"4b",x"70",x"86"),
   513 => (x"01",x"a8",x"c3",x"48"),
   514 => (x"73",x"87",x"f4",x"c2"),
   515 => (x"9a",x"f0",x"c3",x"4a"),
   516 => (x"02",x"aa",x"d0",x"c1"),
   517 => (x"e0",x"c1",x"87",x"c7"),
   518 => (x"e2",x"c2",x"05",x"aa"),
   519 => (x"c8",x"49",x"73",x"87"),
   520 => (x"87",x"c3",x"02",x"99"),
   521 => (x"73",x"87",x"c6",x"ff"),
   522 => (x"c2",x"9c",x"c3",x"4c"),
   523 => (x"c4",x"c1",x"05",x"ac"),
   524 => (x"49",x"66",x"c4",x"87"),
   525 => (x"1e",x"71",x"31",x"c9"),
   526 => (x"c1",x"4a",x"66",x"c4"),
   527 => (x"fa",x"c2",x"92",x"cc"),
   528 => (x"81",x"72",x"49",x"c4"),
   529 => (x"87",x"e6",x"ce",x"fe"),
   530 => (x"da",x"ff",x"49",x"d8"),
   531 => (x"c0",x"c8",x"87",x"f6"),
   532 => (x"fc",x"e6",x"c2",x"1e"),
   533 => (x"fc",x"e7",x"fd",x"49"),
   534 => (x"48",x"d0",x"ff",x"87"),
   535 => (x"c2",x"78",x"e0",x"c0"),
   536 => (x"cc",x"1e",x"fc",x"e6"),
   537 => (x"cc",x"c1",x"4a",x"66"),
   538 => (x"c4",x"fa",x"c2",x"92"),
   539 => (x"fe",x"81",x"72",x"49"),
   540 => (x"cc",x"87",x"fc",x"cc"),
   541 => (x"05",x"ac",x"c1",x"86"),
   542 => (x"c4",x"87",x"c4",x"c1"),
   543 => (x"31",x"c9",x"49",x"66"),
   544 => (x"66",x"c4",x"1e",x"71"),
   545 => (x"92",x"cc",x"c1",x"4a"),
   546 => (x"49",x"c4",x"fa",x"c2"),
   547 => (x"cd",x"fe",x"81",x"72"),
   548 => (x"e6",x"c2",x"87",x"dc"),
   549 => (x"66",x"c8",x"1e",x"fc"),
   550 => (x"92",x"cc",x"c1",x"4a"),
   551 => (x"49",x"c4",x"fa",x"c2"),
   552 => (x"cb",x"fe",x"81",x"72"),
   553 => (x"49",x"d7",x"87",x"ca"),
   554 => (x"87",x"d8",x"d9",x"ff"),
   555 => (x"c2",x"1e",x"c0",x"c8"),
   556 => (x"fd",x"49",x"fc",x"e6"),
   557 => (x"cc",x"87",x"fb",x"e5"),
   558 => (x"48",x"d0",x"ff",x"86"),
   559 => (x"f8",x"78",x"e0",x"c0"),
   560 => (x"26",x"4c",x"26",x"8e"),
   561 => (x"1e",x"4f",x"26",x"4b"),
   562 => (x"b7",x"c4",x"4a",x"71"),
   563 => (x"87",x"ce",x"03",x"aa"),
   564 => (x"cc",x"c1",x"49",x"72"),
   565 => (x"c4",x"fa",x"c2",x"91"),
   566 => (x"81",x"c8",x"c1",x"81"),
   567 => (x"4f",x"26",x"79",x"c0"),
   568 => (x"5c",x"5b",x"5e",x"0e"),
   569 => (x"86",x"fc",x"0e",x"5d"),
   570 => (x"d4",x"ff",x"4a",x"71"),
   571 => (x"d4",x"4c",x"c0",x"4b"),
   572 => (x"b7",x"c3",x"4d",x"66"),
   573 => (x"c2",x"c2",x"01",x"ad"),
   574 => (x"02",x"9a",x"72",x"87"),
   575 => (x"1e",x"87",x"ec",x"c0"),
   576 => (x"cc",x"c1",x"49",x"75"),
   577 => (x"c4",x"fa",x"c2",x"91"),
   578 => (x"c8",x"80",x"71",x"48"),
   579 => (x"66",x"c4",x"58",x"a6"),
   580 => (x"e7",x"c4",x"fe",x"49"),
   581 => (x"70",x"86",x"c4",x"87"),
   582 => (x"87",x"d4",x"02",x"98"),
   583 => (x"c8",x"c1",x"49",x"6e"),
   584 => (x"6e",x"79",x"c1",x"81"),
   585 => (x"69",x"81",x"c8",x"49"),
   586 => (x"75",x"87",x"c5",x"4c"),
   587 => (x"87",x"d7",x"fe",x"49"),
   588 => (x"c8",x"48",x"d0",x"ff"),
   589 => (x"7b",x"dd",x"78",x"e1"),
   590 => (x"ff",x"c3",x"48",x"74"),
   591 => (x"74",x"7b",x"70",x"98"),
   592 => (x"29",x"b7",x"c8",x"49"),
   593 => (x"ff",x"c3",x"48",x"71"),
   594 => (x"74",x"7b",x"70",x"98"),
   595 => (x"29",x"b7",x"d0",x"49"),
   596 => (x"ff",x"c3",x"48",x"71"),
   597 => (x"74",x"7b",x"70",x"98"),
   598 => (x"28",x"b7",x"d8",x"48"),
   599 => (x"7b",x"c0",x"7b",x"70"),
   600 => (x"7b",x"7b",x"7b",x"7b"),
   601 => (x"7b",x"7b",x"7b",x"7b"),
   602 => (x"ff",x"7b",x"7b",x"7b"),
   603 => (x"e0",x"c0",x"48",x"d0"),
   604 => (x"dc",x"1e",x"75",x"78"),
   605 => (x"f0",x"d6",x"ff",x"49"),
   606 => (x"fc",x"86",x"c4",x"87"),
   607 => (x"26",x"4d",x"26",x"8e"),
   608 => (x"26",x"4b",x"26",x"4c"),
   609 => (x"00",x"1c",x"e7",x"4f"),
   610 => (x"00",x"1c",x"e7",x"00"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;
