library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Defines constants and function declarations.
package aes_128_pkg is
	-- Simple Constants
	constant Nb : integer := 4; -- Number of columns comprising the state.
	constant Nk : integer := 4; -- Number of 32 bit words that comprise the key.
	constant Nr : integer := 10; -- Number of encryption rounds.

	-- Types
	subtype byte is std_logic_vector(0 to 7);
	subtype word is std_logic_vector(0 to 31);
	subtype four_word is std_logic_vector(0 to 127);
	type key_type is array(0 to Nk - 1) of word;
	type state_type is array(0 to Nb - 1) of word;
	type rcon_type is array(1 to Nr) of word;
	type w_type is array(0 to 4 * (Nr + 1)) of word;
	type s_box_type is array(0 to 15, 0 to 15) of byte;
	
	-- Typed Constants
	constant Rcon : rcon_type := (
		(X"01000000"),
		(X"02000000"),
		(X"04000000"),
		(X"08000000"),
		(X"10000000"),
		(X"20000000"),
		(X"40000000"),
		(X"80000000"),
		(X"1B000000"),
		(X"36000000")
	);
	
	constant SBox : s_box_type := (
		(X"63", X"7c", X"77", X"7b", X"f2", X"6b", X"6f", X"c5", X"30", X"01", X"67", X"2b", X"fe", X"d7", X"ab", X"76"),
		(X"ca", X"82", X"c9", X"7d", X"fa", X"59", X"47", X"f0", X"ad", X"d4", X"a2", X"af", X"9c", X"a4", X"72", X"c0"),
		(X"b7", X"fd", X"93", X"26", X"36", X"3f", X"f7", X"cc", X"34", X"a5", X"e5", X"f1", X"71", X"d8", X"31", X"15"),
		(X"04", X"c7", X"23", X"c3", X"18", X"96", X"05", X"9a", X"07", X"12", X"80", X"e2", X"eb", X"27", X"b2", X"75"),
		(X"09", X"83", X"2c", X"1a", X"1b", X"6e", X"5a", X"a0", X"52", X"3b", X"d6", X"b3", X"29", X"e3", X"2f", X"84"),
		(X"53", X"d1", X"00", X"ed", X"20", X"fc", X"b1", X"5b", X"6a", X"cb", X"be", X"39", X"4a", X"4c", X"58", X"cf"),
		(X"d0", X"ef", X"aa", X"fb", X"43", X"4d", X"33", X"85", X"45", X"f9", X"02", X"7f", X"50", X"3c", X"9f", X"a8"),
		(X"51", X"a3", X"40", X"8f", X"92", X"9d", X"38", X"f5", X"bc", X"b6", X"da", X"21", X"10", X"ff", X"f3", X"d2"),
		(X"cd", X"0c", X"13", X"ec", X"5f", X"97", X"44", X"17", X"c4", X"a7", X"7e", X"3d", X"64", X"5d", X"19", X"73"),
		(X"60", X"81", X"4f", X"dc", X"22", X"2a", X"90", X"88", X"46", X"ee", X"b8", X"14", X"de", X"5e", X"0b", X"db"),
		(X"e0", X"32", X"3a", X"0a", X"49", X"06", X"24", X"5c", X"c2", X"d3", X"ac", X"62", X"91", X"95", X"e4", X"79"),
		(X"e7", X"c8", X"37", X"6d", X"8d", X"d5", X"4e", X"a9", X"6c", X"56", X"f4", X"ea", X"65", X"7a", X"ae", X"08"),
		(X"ba", X"78", X"25", X"2e", X"1c", X"a6", X"b4", X"c6", X"e8", X"dd", X"74", X"1f", X"4b", X"bd", X"8b", X"8a"),
		(X"70", X"3e", X"b5", X"66", X"48", X"03", X"f6", X"0e", X"61", X"35", X"57", X"b9", X"86", X"c1", X"1d", X"9e"),
		(X"e1", X"f8", X"98", X"11", X"69", X"d9", X"8e", X"94", X"9b", X"1e", X"87", X"e9", X"ce", X"55", X"28", X"df"),
		(X"8c", X"a1", X"89", X"0d", X"bf", X"e6", X"42", X"68", X"41", X"99", X"2d", X"0f", X"b0", X"54", X"bb", X"16")
	);
	
	constant InvSBox : s_box_type := (
		(X"52", X"09", X"6a", X"d5", X"30", X"36", X"a5", X"38", X"bf", X"40", X"a3", X"9e", X"81", X"f3", X"d7", X"fb"),
		(X"7c", X"e3", X"39", X"82", X"9b", X"2f", X"ff", X"87", X"34", X"8e", X"43", X"44", X"c4", X"de", X"e9", X"cb"),
		(X"54", X"7b", X"94", X"32", X"a6", X"c2", X"23", X"3d", X"ee", X"4c", X"95", X"0b", X"42", X"fa", X"c3", X"4e"),
		(X"08", X"2e", X"a1", X"66", X"28", X"d9", X"24", X"b2", X"76", X"5b", X"a2", X"49", X"6d", X"8b", X"d1", X"25"),
		(X"72", X"f8", X"f6", X"64", X"86", X"68", X"98", X"16", X"d4", X"a4", X"5c", X"cc", X"5d", X"65", X"b6", X"92"),
		(X"6c", X"70", X"48", X"50", X"fd", X"ed", X"b9", X"da", X"5e", X"15", X"46", X"57", X"a7", X"8d", X"9d", X"84"),
		(X"90", X"d8", X"ab", X"00", X"8c", X"bc", X"d3", X"0a", X"f7", X"e4", X"58", X"05", X"b8", X"b3", X"45", X"06"),
		(X"d0", X"2c", X"1e", X"8f", X"ca", X"3f", X"0f", X"02", X"c1", X"af", X"bd", X"03", X"01", X"13", X"8a", X"6b"),
		(X"3a", X"91", X"11", X"41", X"4f", X"67", X"dc", X"ea", X"97", X"f2", X"cf", X"ce", X"f0", X"b4", X"e6", X"73"),
		(X"96", X"ac", X"74", X"22", X"e7", X"ad", X"35", X"85", X"e2", X"f9", X"37", X"e8", X"1c", X"75", X"df", X"6e"),
		(X"47", X"f1", X"1a", X"71", X"1d", X"29", X"c5", X"89", X"6f", X"b7", X"62", X"0e", X"aa", X"18", X"be", X"1b"),
		(X"fc", X"56", X"3e", X"4b", X"c6", X"d2", X"79", X"20", X"9a", X"db", X"c0", X"fe", X"78", X"cd", X"5a", X"f4"),
		(X"1f", X"dd", X"a8", X"33", X"88", X"07", X"c7", X"31", X"b1", X"12", X"10", X"59", X"27", X"80", X"ec", X"5f"),
		(X"60", X"51", X"7f", X"a9", X"19", X"b5", X"4a", X"0d", X"2d", X"e5", X"7a", X"9f", X"93", X"c9", X"9c", X"ef"),
		(X"a0", X"e0", X"3b", X"4d", X"ae", X"2a", X"f5", X"b0", X"c8", X"eb", X"bb", X"3c", X"83", X"53", X"99", X"61"),
		(X"17", X"2b", X"04", X"7e", X"ba", X"77", X"d6", X"26", X"e1", X"69", X"14", X"63", X"55", X"21", X"0c", X"7d")
	);
	
	-- Shared Functions
	function RotWord(ORIGINAL : word) return word;
	function KeyExpansion(KEY : key_type) return w_type;
	function XTimes(INPUT : byte; MULTIPLIER : integer) return byte;
	function AddRoundKey(STATE : state_type; ROUNDKEY : key_type) return state_type;
	
	-- Encryption Functions
	function SubWord(ORIGINAL : word) return word;
	function SubBytes(STATE : state_type) return state_type;
	function ShiftRows(STATE : state_type) return state_type;
	function MixColumns(STATE : state_type) return state_type;
	function Cipher(INPUT : state_type; w : w_type) return state_type;
	
	-- Decryption Functions
	function InvSubWord(ORIGINAL : word) return word;
	function InvSubBytes(STATE : state_type) return state_type;
	function InvShiftRows(STATE : state_type) return state_type;
	function InvMixColumns(STATE : state_type) return state_type;
	function InvCipher(INPUT : state_type; w : w_type) return state_type;
end package aes_128_pkg;

-- Defines function definitions.
package body aes_128_pkg is	
	function RotWord(ORIGINAL : word) return word is
		variable temp : byte;
		variable rotated : word;
	begin
		temp := ORIGINAL(0 to 7);
		
		rotated(0 to 7) := ORIGINAL(8 to 15); 
		rotated(8 to 15) := ORIGINAL(16 to 23);
		rotated(16 to 23) := ORIGINAL(24 to 31);
		rotated(24 to 31) := temp;
		
		return rotated;
	end function;
	
	function KeyExpansion(KEY : key_type) return w_type is	
		variable i : integer := 0;
		variable w : w_type;
		variable temp : word;
	begin
		while i <= Nk - 1 loop
			w(i) := KEY(i);
			i := i + 1;
		end loop;
		
		while i <= (4 * Nr + 3) loop
			temp := w(i - 1);
			
			if i mod Nk = 0 then
				temp := SubWord(RotWord(temp)) XOR Rcon(i/Nk);
			end if;
			
			w(i) := w(i - Nk) XOR temp;
			i := i + 1;
		end loop;
		
		return w;
	end function;
	
	function XTimes(INPUT : byte; MULTIPLIER : integer) return byte is
		variable original : byte;
		variable multiplied : byte;
	begin
		original := INPUT;
		multiplied := INPUT;
		
		multiplied := multiplied sll 1;
		
		if original(0) = '1' then
			multiplied := multiplied XOR X"1B";
		end if;
		
		if (MULTIPLIER = 3) then
			multiplied := multiplied XOR original;
		end if;
		
		return multiplied;
	end function;
	
	function AddRoundKey(STATE : state_type; ROUNDKEY : key_type) return state_type is
		variable added : state_type;
	begin
		added(0) := STATE(0) XOR ROUNDKEY(0);
		added(1) := STATE(1) XOR ROUNDKEY(1);
		added(2) := STATE(2) XOR ROUNDKEY(2);
		added(3) := STATE(3) XOR ROUNDKEY(3);
		
		return added;
	end function;
	
	function SubWord(ORIGINAL : word) return word is
		variable row : integer;
		variable column : integer;
		variable substitute : word;
	begin
		row := to_integer(unsigned(ORIGINAL(0 to 3)));
		column := to_integer(unsigned(ORIGINAL(4 to 7)));
 		substitute(0 to 7) :=  SBox(row, column);
		
		row := to_integer(unsigned(ORIGINAL(8 to 11)));
		column := to_integer(unsigned(ORIGINAL(12 to 15)));
		substitute(8 to 15) :=  SBox(row, column);
		
		row := to_integer(unsigned(ORIGINAL(16 to 19)));
		column := to_integer(unsigned(ORIGINAL(20 to 23)));
		substitute(16 to 23) :=  SBox(row, column);
		
		row := to_integer(unsigned(ORIGINAL(24 to 27)));
		column := to_integer(unsigned(ORIGINAL(28 to 31)));
		substitute(24 to 31) :=  SBox(row, column);
		
		return substitute;
	end function;
	
	function SubBytes(STATE : state_type) return state_type is
		variable substitute : state_type;
	begin
		substitute(0) := SubWord(STATE(0));
		substitute(1) := SubWord(STATE(1));
		substitute(2) := SubWord(STATE(2));
		substitute(3) := SubWord(STATE(3));
		
		return substitute;
	end function;
	
	function ShiftRows(STATE : state_type) return state_type is
		variable first : integer;
		variable last : integer;
		variable temp0 : byte;
		variable temp1 : byte;
		variable shifted : state_type;
	begin
		shifted := STATE;
		
		-- Shift row 2.
		first := 8;
		last := 15;
		
		temp0 := shifted(0)(first to last);
		shifted(0)(first to last) := shifted(1)(first to last);
		shifted(1)(first to last) := shifted(2)(first to last);
		shifted(2)(first to last) := shifted(3)(first to last);
		shifted(3)(first to last) := temp0;
		
		-- Shift row 3.
		first := 16;
		last := 23;
		
		temp0 := shifted(0)(first to last);
		temp1 := shifted(1)(first to last);
		shifted(0)(first to last) := shifted(2)(first to last);
		shifted(1)(first to last) := shifted(3)(first to last);
		shifted(2)(first to last) := temp0;
		shifted(3)(first to last) := temp1;
		
		-- Shift row 4.
		first := 24;
		last := 31;
		
		temp0 := shifted(3)(first to last);
		shifted(3)(first to last) := shifted(2)(first to last);
		shifted(2)(first to last) := shifted(1)(first to last);
		shifted(1)(first to last) := shifted(0)(first to last);
		shifted(0)(first to last) := temp0;
		
		return shifted;
	end function;
	
	function MixColumns(STATE : state_type) return state_type is
		variable b0, b1, b2, b3 : byte;
		variable mixedColumn : word;
		variable mixed : state_type;
	begin
		for i in 0 to Nb - 1 loop
			b0 := STATE(i)(0 to 7);
			b1 := STATE(i)(8 to 15);
			b2 := STATE(i)(16 to 23);
			b3 := STATE(i)(24 to 31);
			
			mixedColumn(0 to 7) := XTimes(b0, 2) XOR XTimes(b1, 3) XOR b2 XOR b3;
			mixedColumn(8 to 15) := b0 XOR XTimes(b1, 2) XOR XTimes(b2, 3) XOR b3;
			mixedColumn(16 to 23) := b0 XOR b1 XOR XTimes(b2, 2) XOR XTimes(b3, 3);
			mixedColumn(24 to 31) := XTimes(b0, 3) XOR b1 XOR b2 XOR XTimes(b3, 2);
			
			mixed(i) := mixedColumn;
		end loop;
		
		return mixed;
	end function;
	
	function Cipher(INPUT : state_type; w : w_type) return state_type is
		variable state : state_type;
		variable roundKey : key_type;
	begin
		state := INPUT;
		
		roundKey(0) := w(0);
		roundKey(1) := w(1);
		roundKey(2) := w(2);
		roundKey(3) := w(3);
		
		state := AddRoundKey(state, roundKey);
		
		for i in 1 to Nr - 1 loop
			state := SubBytes(state);
			state := ShiftRows(state);
			state := MixColumns(state);
			
			roundKey(0) := w(4 * i);
			roundKey(1) := w(4 * i + 1);
			roundKey(2) := w(4 * i + 2);
			roundKey(3) := w(4 * i + 3);
			
			state := AddRoundKey(state, roundKey);
		end loop;
		
		state := SubBytes(state);
		state := ShiftRows(state);
		
		roundKey(0) := w(4 * Nr);
		roundKey(1) := w(4 * Nr + 1);
		roundKey(2) := w(4 * Nr + 2);
		roundKey(3) := w(4 * Nr + 3);
		
		state := AddRoundKey(state, roundKey);
		
		return state;
	end function;
	
	function InvSubWord(ORIGINAL : word) return word is
		variable row : integer;
		variable column : integer;
		variable substitute : word;
	begin
		row := to_integer(unsigned(ORIGINAL(0 to 3)));
		column := to_integer(unsigned(ORIGINAL(4 to 7)));
 		substitute(0 to 7) :=  InvSBox(row, column);
		
		row := to_integer(unsigned(ORIGINAL(8 to 11)));
		column := to_integer(unsigned(ORIGINAL(12 to 15)));
		substitute(8 to 15) :=  InvSBox(row, column);
		
		row := to_integer(unsigned(ORIGINAL(16 to 19)));
		column := to_integer(unsigned(ORIGINAL(20 to 23)));
		substitute(16 to 23) :=  InvSBox(row, column);
		
		row := to_integer(unsigned(ORIGINAL(24 to 27)));
		column := to_integer(unsigned(ORIGINAL(28 to 31)));
		substitute(24 to 31) :=  InvSBox(row, column);
		
		return substitute;
	end function;
	
	function InvSubBytes(STATE : state_type) return state_type is
		variable substituted : state_type;
	begin
		substituted(0) := InvSubWord(STATE(0));
		substituted(1) := InvSubWord(STATE(1));
		substituted(2) := InvSubWord(STATE(2));
		substituted(3) := InvSubWord(STATE(3));
		
		return substituted;
	end function;
	
	function InvShiftRows(STATE : state_type) return state_type is
		variable first : integer;
		variable last : integer;
		variable temp0 : byte;
		variable temp1 : byte;
		variable shifted : state_type;
	begin
		shifted := STATE;
		
		-- Shift row 2.
		first := 8;
		last := 15;
		
		temp0 := shifted(3)(first to last);
		shifted(3)(first to last) := shifted(2)(first to last);
		shifted(2)(first to last) := shifted(1)(first to last);
		shifted(1)(first to last) := shifted(0)(first to last);
		shifted(0)(first to last) := temp0;
		
		-- Shift row 3.
		first := 16;
		last := 23;
		
		temp0 := shifted(2)(first to last);
		temp1 := shifted(3)(first to last);
		shifted(3)(first to last) := shifted(1)(first to last);
		shifted(2)(first to last) := shifted(0)(first to last);
		shifted(1)(first to last) := temp1;
		shifted(0)(first to last) := temp0;
		
		-- Shift row 4.
		first := 24;
		last := 31;
		
		temp0 := shifted(0)(first to last);
		shifted(0)(first to last) := shifted(1)(first to last);
		shifted(1)(first to last) := shifted(2)(first to last);
		shifted(2)(first to last) := shifted(3)(first to last);
		shifted(3)(first to last) := temp0;
		
		return shifted;
	end function;
	
	function InvMixColumns(STATE : state_type) return state_type is
		variable b0, b1, b2, b3 : byte;
		variable mixedColumn : word;
		variable mixed : state_type;
	begin
		for i in 0 to Nb - 1 loop
			b0 := STATE(i)(0 to 7);
			b1 := STATE(i)(8 to 15);
			b2 := STATE(i)(16 to 23);
			b3 := STATE(i)(24 to 31);
			
			mixedColumn(0 to 7) := (XTimes(XTimes(XTimes(b0, 2) XOR b0, 2) XOR b0, 2)) XOR (XTimes((XTimes(XTimes(b1, 2), 2) XOR b1), 2) XOR b1) XOR (XTimes(XTimes(XTimes(b2, 2) XOR b2, 2), 2) XOR b2) XOR (XTimes(XTimes(XTimes(b3, 2), 2), 2) XOR b3);
			mixedColumn(8 to 15) := (XTimes(XTimes(XTimes(b0, 2), 2), 2) XOR b0) XOR (XTimes(XTimes(XTimes(b1, 2) XOR b1, 2) XOR b1, 2)) XOR (XTimes((XTimes(XTimes(b2, 2), 2) XOR b2), 2) XOR b2) XOR (XTimes(XTimes(XTimes(b3, 2) XOR b3, 2), 2) XOR b3);
			mixedColumn(16 to 23) := (XTimes(XTimes(XTimes(b0, 2) XOR b0, 2), 2) XOR b0) XOR (XTimes(XTimes(XTimes(b1, 2), 2), 2) XOR b1) XOR (XTimes(XTimes(XTimes(b2, 2) XOR b2, 2) XOR b2, 2)) XOR (XTimes((XTimes(XTimes(b3, 2), 2) XOR b3), 2) XOR b3);
			mixedColumn(24 to 31) := (XTimes((XTimes(XTimes(b0, 2), 2) XOR b0), 2) XOR b0) XOR (XTimes(XTimes(XTimes(b1, 2) XOR b1, 2), 2) XOR b1) XOR (XTimes(XTimes(XTimes(b2, 2), 2), 2) XOR b2) XOR (XTimes(XTimes(XTimes(b3, 2) XOR b3, 2) XOR b3, 2));
			
			mixed(i) := mixedColumn;
		end loop;
		
		return mixed;
	end function;
	
	function InvCipher(INPUT : state_type; w : w_type) return state_type is
		variable state : state_type;
		variable roundKey : key_type;
	begin
		state := INPUT;
		
		roundKey(0) := w(4 * Nr);
		roundKey(1) := w(4 * Nr + 1);
		roundKey(2) := w(4 * Nr + 2);
		roundKey(3) := w(4 * Nr + 3);
		
		state := AddRoundKey(state, roundKey);
		
		for i in Nr - 1 downto 1 loop
			state := InvShiftRows(state);
			state := InvSubBytes(state);
			
			roundKey(0) := w(4 * i);
			roundKey(1) := w(4 * i + 1);
			roundKey(2) := w(4 * i + 2);
			roundKey(3) := w(4 * i + 3);
			
			state := AddRoundKey(state, roundKey);
			state := InvMixColumns(state);
		end loop;
		
		state := InvShiftRows(state);
		state := InvSubBytes(state);
		
		roundKey(0) := w(0);
		roundKey(1) := w(1);
		roundKey(2) := w(2);
		roundKey(3) := w(3);
		
		state := AddRoundKey(state, roundKey);
		
		return state;
	end function;
end package body aes_128_pkg;