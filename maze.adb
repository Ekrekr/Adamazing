with Ada.Text_IO;
use Ada.Text_IO;

with Ada.Integer_Text_IO;
use Ada.Integer_Text_IO;

with Ada.Containers.Vectors;

with Ada.Numerics.Discrete_Random;

procedure Maze (Size : Integer) is
   -- A grid is a 2d array of cells. A cell can either be Fresh (not
   -- inspected), Front (Inspected but not set), Clear (inspected and
   -- traversable), Blocked (inspected and not traversable), Start or Finish.
   type Cell is (Fresh, Front, Clear, Blocked, Start, Finish);
   type Grid is array(NATURAL range 1..Size, NATURAL range 1..Size) of Cell;

   -- Coordinates are a vector of them are used to to keep track of the
   -- frontier.
   type Coord is array(NATURAL range 1..2) of NATURAL;
   package Coord_Vector is new Ada.Containers.Vectors
     (Index_Type   => Natural,
      Element_Type => Coord);

   Start_Coord : Coord := (2, 2);
   End_Coord : Coord := (Size-1, Size-1);
   Maze_Grid : Grid;

   -- Frontier cells are any uninspected cell adjacent to an inspected cell.
   Frontier : Coord_Vector.Vector;
   Frontier_Cursor : Coord_Vector.Cursor;

   -- Set every sell to Fresh, and resets frontier vector.
   procedure Clear_Maze is
   begin
      for I in Maze_Grid'Range (1) loop
         for J in Maze_Grid'Range (2) loop
            Maze_Grid (I, J) := Fresh;
         end loop;
      end loop;
      Frontier.Clear;
      Frontier.Append (Start_Coord);
      Maze_Grid (Start_Coord (1), Start_Coord (2)) := Front;
   end Clear_Maze;

   -- Draw a single cell given the enumerate representation.
   procedure Put_Cell (C : Cell) is
   begin
      if C = Clear then
         Put ("  ");
      elsif C = Blocked then
         Put ("██");
      elsif C = Start then
         Put ("S ");
      elsif C = Finish then
         Put ("F ");
      else
         Put ("  ");
      end if;
   end Put_Cell;

   -- Draw the full maze in its current form.
   procedure Put_Maze is
   begin
      New_Line(1);
      for I in Maze_Grid'Range (1) loop
         for J in Maze_Grid'Range (2) loop
            Put_Cell (Maze_Grid (I, J));
         end loop;
         New_Line (1);
      end loop;
   end Put_Maze;

   -- Generate the outside barrier of the maze.
   procedure Set_Border is
   begin
      for I in 1 .. Size loop
         Maze_Grid (1, I) := Blocked;
         Maze_Grid (Size, I) := Blocked;
         Maze_Grid (I, 1) := Blocked;
         Maze_Grid (I, Size) := Blocked;
      end loop;
   end Set_Border;

   -- Inspect and act on adjacent cells to a frontier coordinate.
   procedure Check_Frontier (C : Coord) is
      C_Y : Integer := C (1);
      C_X : Integer := C (2);
      Y : Integer;
      X : Integer;
      type Coord_Quad is array(NATURAL range 1..4) of Coord;
      New_Coords : Coord_Quad := ((C_Y - 2, C_X), (C_Y, C_X + 2),
                                  (C_Y + 2, C_X), (C_Y, C_X - 2));
      New_C : Coord;
   begin
      for I in New_Coords'Range loop
         New_C := New_Coords (I);
         Y := New_C (1);
         X := New_C (2);

         -- Only consider the node if it is within the bounds of the grid.
         if Y >= 2 and Y <= Size - 1 and X >= 2 and X <= Size - 1 then

            -- If the new node is a frontier then draw a 3-width barrier
            -- between, from the direction of the original node to the new
            -- node.
            if Maze_Grid(Y, X) = Front then
               if C_Y > Y then
                  Maze_Grid(Y + 1, X - 1) := Blocked;
                  Maze_Grid(Y + 1, X) := Blocked;
                  Maze_Grid(Y + 1, X + 1) := Blocked;
               elsif C_Y < Y then
                  Maze_Grid(Y - 1, X - 1) := Blocked;
                  Maze_Grid(Y - 1, X) := Blocked;
                  Maze_Grid(Y - 1, X + 1) := Blocked;
               end if;

               if C_X > X then
                  Maze_Grid(Y + 1, X + 1) := Blocked;
                  Maze_Grid(Y, X + 1) := Blocked;
                  Maze_Grid(Y - 1, X + 1) := Blocked;
               elsif C_X < X then
                  Maze_Grid(Y + 1, X - 1) := Blocked;
                  Maze_Grid(Y, X - 1) := Blocked;
                  Maze_Grid(Y - 1, X - 1) := Blocked;
               end if;

            elsif Maze_Grid(Y, X) = Fresh then
               Maze_Grid(Y, X) := Front;
               Frontier.Append (New_C);
            end if;
         end if;
      end loop;
   end Check_Frontier;

   -- Selects a random coordinate from the frontier.
   Function Rand_Int (Max : Integer) Return Integer is
      subtype Int_Range is Integer range 1 .. Max;
      package R is new Ada.Numerics.Discrete_Random (Int_Range);
      use R;
      G : Generator;
   Begin
      Reset (G);
      Return Random(G);
   End Rand_Int;

   -- Proceeds with a step through the breadth-first search generation.
   -- 1. Select a random frontier node from the list of frontier nodes.
   -- 2. For all nodes adjacent to this node:
   --   a. If the node is already a fontier, place a barrier between the two.
   --   b. If the node has not been traversed, and add it to the list.
   -- 3. Mark the selected node as traversable and remove it from the list.
   procedure Find_Route is
      C : Coord;
      Search : Integer;
   begin
      while Integer (Frontier.Length) > 0 loop
         Search := Rand_Int (Integer (Frontier.Length));
         C := Frontier.Element (Search - 1);
         Check_Frontier (C);
         Maze_Grid (C (1), C (2)) := Clear;
         Frontier.Delete (Search - 1, 1);
      end loop;
      Maze_Grid (Start_Coord (1), Start_Coord (2)) := Start;
      Maze_Grid (End_Coord (1), End_Coord (2)) := Finish;
   end Find_Route;

begin
   clear_maze;
   Set_Border;
   Find_Route;
   Put_Maze;
end Maze;
