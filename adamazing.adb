with Ada.Text_IO;
use Ada.Text_IO;

with Maze;

procedure Adamazing is
   Size : Integer;
begin
   Put_Line("Enter Difficulty (1 to 25), you may have to zoom out.");
   -- Making the size an odd number improves impearance.
   Size := Integer'Value(Get_Line) * 10 + 1;
   Maze (Size);
   Put_Line("");
end Adamazing;
