--////////////////////////////////////////////////////////////////////////////////
--//  Company: 成都锐创智能科技 Ruichuang Smart Technology                      //
--//           http://ruicstech.taobao.com                                      // 
--//  Engineer:      Youzhiyu                                                   //
--//  QQ      :      4016682                                                    //
--//  Target Device: MAXII240T100C5N                                            //
--//  Tool versions: Quartus II 7.2                                             //
--//  Create Date:   2007-09-06 10:09                                           //
--//  Description:                                                              //
--//                                                                            //
--////////////////////////////////////////////////////////////////////////////////
--// 	   Copyright (C) 2011-2012  Youzhiyu   All rights reserved              //
--//----------------------------------------------------------------------------//
--////////////////////////////////////////////////////////////////////////////////
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;

entity clkdiv is
	port( 
	      clkin     : in std_logic;
		  reset_n   : in std_logic;
		  clkout    : out std_logic
		);
end clkdiv;

Architecture fun of clkdiv is
	signal s_clk :std_logic;
Begin
    clkout<=s_clk;

	clk_div:Process(clkin,reset_n)
		Variable cnt : integer range 0 to 2000000:=0;
	Begin
		if reset_n='0' then
			s_clk<='0';
			cnt:=0;
		elsif clkin'event and clkin='1' then
			cnt:=cnt+1;
			if cnt=2000000 then
				s_clk<= not s_clk;
				cnt:=0;
			end if;
		end if;
	end process clk_div;
end fun; 