library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library aes_128_pkg;
use aes_128_pkg.aes_128_pkg.all;

entity aes_128_decrypt is
	port (
		CLK      : in std_logic; -- System clock.
		RESET    : in std_logic; -- Asynchronous active high system reset.
		START    : in std_logic; -- After reset or system start. Set high for 1 clock cycle to begin.
		KEY_LOAD : in std_logic; -- After START. When high the next 4 successive clock cycles will load the key on DATA_IN.
		IV_LOAD  : in std_logic; -- After KEY_LOAD. When high, the next 4 successive clock cycles will load the initialization vector on DATA_IN. IV = 0 if not set.
		DB_LOAD  : in std_logic; -- After STREAM & Mode. When high, the next 4 successive clock cycles will load the data block (plain text) on DATA_IN.
		STREAM   : in std_logic; -- After IV/Key load. Set high for 1 clock cycle. The next clock cycle will check one of the modes below.
		ECB_MODE : in std_logic; -- Electronic code book. Blocks are encrypted independently using the original key/IV.
		CBC_MODE : in std_logic; -- Cypher block chaining. Cyphertext of current block is IV for next block.
		DATA_IN  : in std_logic_vector(0 to 31); -- bus used to input data
		DATA_OUT : out std_logic_vector(0 to 31); -- bus used output data
		DONE     : out std_logic -- Turn on when encryption is completed. First 32 bits of cyphertext is output when Done is turned on and remaining are output in the next 3 clock cycles.
	);
end entity aes_128_decrypt;

architecture aes_128_decrypt_behavioral of aes_128_decrypt is
	signal state, nextState : integer range 0 to 20 := 0;
begin
	process(state, RESET, START, KEY_LOAD, IV_LOAD, DB_LOAD, STREAM, ECB_MODE, CBC_MODE, DATA_IN)
		constant zeroKey : key_type := (X"00000000", X"00000000", X"00000000", X"00000000");
		constant zeroState : state_type := (X"00000000", X"00000000", X"00000000", X"00000000");
		
		variable key : key_type := zeroKey;
		variable initVec : state_type := zeroState;
		variable previousState : state_type := zeroState;
		variable currentState : state_type := zeroState;
		variable isECBMode : std_logic := '0';
	begin
		if RESET = '1' then
			key := zeroKey;
			initVec := zeroState;
			previousState := zeroState;
			currentState := zeroState;
			isECBMode := '0';
			nextState <= 0;
			DONE <= '0';
		else
			case state is
				when 0 =>
					if START = '1' then
						nextState <= 1;
					end if;
				when 1 =>
					if KEY_LOAD = '1' then
						nextState <= 2;
					end if;
				when 2 =>
					key(0) := DATA_IN;
					nextState <= 3;
				when 3 =>
					key(1) := DATA_IN;
					nextState <= 4;
				when 4 =>
					key(2) := DATA_IN;
					nextState <= 5;
				when 5 =>
					key(3) := DATA_IN;
					nextState <= 6;
				when 6 =>
					if IV_LOAD = '1' and STREAM = '0' then
						nextState <= 7;
					elsif IV_LOAD = '0' and STREAM = '1' then
						nextState <= 11;
					end if;
				when 7 =>
					initVec(0) := DATA_IN;
					nextState <= 8;
				when 8 =>
					initVec(1) := DATA_IN;
					nextState <= 9;
				when 9 =>
					initVec(2) := DATA_IN;
					nextState <= 10;
				when 10 =>
					initVec(3) := DATA_IN;
					nextState <= 6;
				when 11 =>
					if ECB_MODE = '1' and CBC_MODE = '0' then
						isECBMode := '1';
					elsif ECB_MODE = '0' and CBC_MODE = '1' then
						isECBMode := '0';
					end if;
					
					nextState <= 12;
				when 12 =>
					if DB_LOAD = '1' then
						nextState <= 13;
					end if;
				when 13 =>
					currentState(0) := DATA_IN;
					nextState <= 14;
				when 14 =>
					currentState(1) := DATA_IN;
					nextState <= 15;
				when 15 =>
					currentState(2) := DATA_IN;
					nextState <= 16;
				when 16 =>
					currentState(3) := DATA_IN;
					nextState <= 17;
				when 17 =>
					if isECBMode = '1' then
						currentState := InvCipher(currentState, KeyExpansion(key));
					else
						for i in 0 to Nb - 1 loop
							previousState(i) := currentState(i);
						end loop;
						
						currentState := InvCipher(currentState, KeyExpansion(key));
						
						for i in 0 to Nb - 1 loop
							currentState(i) := currentState(i) XOR initVec(i);
						end loop;
						
						for i in 0 to Nb - 1 loop
							initVec(i) := previousState(i);
						end loop;
					end if;
					nextState <= 17;
					
					DONE <= '1';
					DATA_OUT <= currentState(0);
					nextState <= 18;
				when 18 =>
					DATA_OUT <= currentState(1);
					nextState <= 19;
				when 19 =>
					DATA_OUT <= currentState(2);
					nextState <= 20;
				when 20 =>
					DATA_OUT <= currentState(3);
					DONE <= '0';
					nextState <= 12;
			end case;
		end if;
	end process;
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			if RESET = '1' then
				state <= 0;
			else
				state <= nextState;
			end if;
		end if;
	end process;
end architecture;
