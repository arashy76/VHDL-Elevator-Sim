-------------------------------------------------------------------------------
--
-- Title       : myPack
-- Design      : project982
-- Author      : arash yousefi
-- Company     : 
--
-------------------------------------------------------------------------------
--
-- File        : myPack.vhd
-- Generated   : Sat Jun 20 17:21:09 2020
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : by arash yousefi
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {myPack} architecture {myPack}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package myPack is
	
type list_element is record
	floor_num : integer;
	wait_time : integer;
end record;

--constant init_list_element : list_element := (floor_num => 0, wait_time => 0);
type my_list is array(integer range <>) of list_element;

end myPack;

