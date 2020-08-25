LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Generates a 16-bit signed triangle wave sequence at a sampling rate determined
-- by input clk and with a frequency of (clk*pitch)/65,536
ENTITY tone IS
	PORT (
		clk : IN STD_LOGIC; -- 48.8 kHz audio sampling clock
		pitch : IN UNSIGNED (13 DOWNTO 0); -- frequency (in units of 0.745 Hz)
	data : OUT SIGNED (15 DOWNTO 0); -- signed triangle wave out
	bt_zero: in STD_LOGIC);
END tone;

ARCHITECTURE Behavioral OF tone IS
	SIGNAL count : unsigned (15 DOWNTO 0); -- represents current phase of waveform
	SIGNAL quad : std_logic_vector (1 DOWNTO 0); -- current quadrant of phase
	SIGNAL index : signed (15 DOWNTO 0); -- index into current quadrant
BEGIN
sel : PROCESS(bt_zero,index)
BEGIN
    if bt_zero = '1' then
        if quad = "00" then data <= to_signed(600,16);
        elsif quad = "01" then data <= to_signed (0,16);
        elsif quad = "10" then data <= to_signed (600,16);
        else data <= to_signed (0,16);
        end if;
    else
        if quad = "00" then data <= index;
        elsif quad = "01" then data <= 16383 - index;
        elsif quad = "10" then data <= 0 - index;
        else data <= index - 16383;
        end if;
    end if;
END process;
	quad <= std_logic_vector (count (15 DOWNTO 14)); -- splits count range into 4 phases
	index <= signed ("00" & count (13 DOWNTO 0)); -- 14-bit index into the current phase
	-- This select statement converts an unsigned 16-bit sawtooth that ranges from 65,535
	-- into a signed 12-bit triangle wave that ranges from -16,383 to +16,383
	WITH quad SELECT
	data <= index WHEN "00", -- 1st quadrant
	        16383 - index WHEN "01", -- 2nd quadrant
	        0 - index WHEN "10", -- 3rd quadrant
	        index - 16383 WHEN OTHERS; -- 4th quadrant

END Behavioral;

