--
--  $Author: graham_s $
--  $Date: 2007-08-01 17:53:35 +0100 (Wed, 01 Aug 2007) $
--  $Revision: 3661 $
--
with base_model_types;       use base_model_types;
with Ada.Strings.Unbounded;
with Ada.Characters.Latin_1;
with Text_IO;

package body factor_table is

   package ustr renames Ada.Strings.Unbounded;
   package stda renames Ada.Characters.Latin_1;

   procedure breakdown_to_percent (contents : in out Cell_Contents) is
      sum : array (1 .. Num_Breakdowns) of money := (others => 0.0);
   begin
      for i in  1 .. Num_Breakdowns loop
         for j in  1 .. Max_Breakdown_Size loop
            sum (i) := sum (i) + contents (i) (j);
         end loop;
      end loop;
      for i in  1 .. Num_Breakdowns loop
         for j in  1 .. Max_Breakdown_Size loop
            if (sum (i) > 0.0) then
               contents (i) (j)  := money (100.0 * contents (i) (j)) / sum (i);
            end if;
         end loop;
      end loop;
   end breakdown_to_percent;

   function get_cell_breakdown (table : Table_Rec; row, col : Integer) return Cell_Contents is
   begin
      if (row > 0) and (col > 0) then
         return table.cells (row) (col).breakdown;
      elsif (row = -1) and (col = -1) then
         return table.total.breakdown;
      elsif (row = -1) then
         return table.col_totals (col).breakdown;
      else
         return table.row_totals (row).breakdown;
      end if;
   end get_cell_breakdown;

   --
   --  convert the breakdowns to percentages an
   --
   function get_breakdown_differences
     (table    : Table_Rec;
      row, col : Integer;
      compare  : Compare_Cell)
      return     Cell_Contents
   is
      cell, total_cell : Cell_Contents;
   begin
      cell := get_cell_breakdown (table, row, col);
      case compare is
         when row_total =>
            total_cell := get_cell_breakdown (table, row, -1);
         when col_total =>
            total_cell := get_cell_breakdown (table, -1, col);
         when current_cell =>
            total_cell := get_cell_breakdown (table, row, col);
         when total =>
            total_cell := get_cell_breakdown (table, -1, -1);
      end case;
      breakdown_to_percent (total_cell);
      breakdown_to_percent (cell);
      for i in  1 .. Num_Breakdowns loop
         for j in  1 .. Max_Breakdown_Size loop
            cell (i) (j)  := cell (i) (j) - total_cell (i) (j);
         end loop;
      end loop;
      return cell;
   end get_breakdown_differences;

   function extract_From_Cell
     (cell         : Cell_Rec;
      cell_op      : Cell_Compare_Type;
      value_To_Use : Integer)
      return         money
   is
      outx : money := 0.0;
   begin
      case cell_op is
         when counter =>
            outx := cell.count;
         when sys1_level =>
            outx := money (cell.pre_values (value_To_Use));
         when sys2_level =>
            outx := money (cell.post_values (value_To_Use));
         when abs_change =>
            outx := money (cell.post_values (value_To_Use) - cell.pre_values (value_To_Use));
         when pct_change =>
            if (cell.pre_values (value_To_Use) /= 0.0) then
               outx :=
                 money (100.0 *
                        (real (cell.post_values (value_To_Use) - cell.pre_values (value_To_Use))) /
                        real (cell.pre_values (value_To_Use)));
            end if;
      end case;
      Text_IO.Put ("extract_From_Cell; cell_op is " & cell_op'Img & " outx = " & outx'Img);
      Text_IO.New_Line;
      return outx;
   end extract_From_Cell;

   function re_express_basic_table
     (bt        : Basic_Factor_Array;
      comp_Cell : Compare_Cell)
      return      Basic_Factor_Array
   is
      outt  : Basic_Factor_Array := (others => (others => 0.0));
      comp  : money;
      rcell : real;
   begin
      for r in  1 .. Row_Size + 1 loop
         for c in  1 .. Row_Size + 1 loop
            case comp_Cell is
               when current_cell =>
                  comp := 1.0;
               when row_total =>
                  comp := bt (r, Row_Size + 1);
               when col_total =>
                  comp := bt (Row_Size + 1, c);
               when total =>
                  comp := bt (Row_Size + 1, Row_Size + 1);
            end case;
            if (comp /= 0.0) then
               rcell := (real (bt (r, c)) / real (comp));
               if (comp_Cell /= current_cell) then
                  rcell := rcell * 100.0;
               end if;
               outt (r, c) := money (rcell);
               Text_IO.Put
                 ("re_express table; outt(" & r'Img & "," & c'Img & ") = " & outt (r, c)'Img);
               Text_IO.New_Line;
            end if;
         end loop;
      end loop;
      return outt;
   end re_express_basic_table;

   function expressTable
     (table        : Table_Rec;
      comp_Cell    : Compare_Cell;
      cell_op      : Cell_Compare_Type;
      value_To_Use : Integer)
      return         Basic_Factor_Array
   is
      outt : Basic_Factor_Array;
   begin
      -- is (totals, pct_of_row, pct_of_col, pct_of_overall);
      -- type  is ( current_cell, row_total, col_total, total );
      for r in  1 .. Row_Size loop
         for c in  1 .. Row_Size loop
            outt (r, c) := extract_From_Cell (table.cells (r) (c), cell_op, value_To_Use);
            Text_IO.Put ("express table; outt(" & r'Img & "," & c'Img & ") = " & outt (r, c)'Img);
            Text_IO.New_Line;
         end loop;
      end loop;
      for r in  1 .. Row_Size loop
         outt (r, Row_Size + 1) := extract_From_Cell (table.row_totals (r), cell_op, value_To_Use);
      end loop;
      for c in  1 .. Row_Size loop
         outt (Row_Size + 1, c) := extract_From_Cell (table.col_totals (c), cell_op, value_To_Use);
      end loop;
      outt (Row_Size + 1, Row_Size + 1) := extract_From_Cell (table.total, cell_op, value_To_Use);
      return re_express_basic_table (outt, comp_Cell);
   end expressTable;

   --   is array (1 .. num_breakdowns) of Breakdown;

   procedure add
     (table        : in out Table_Rec;
      row, col     : Integer;
      gross        : real;
      counts_gross : real;
      pre_values   : Values_Array;
      post_values  : Values_Array;
      info         : breakdowns;
      example      : Example_Component := (others => NO_EXAMPLE))
   is

      gross_addition : money := money (gross);

   begin
      table.cells (row) (col).count  := table.cells (row) (col).count + gross_addition;
      table.col_totals (col).count    := table.col_totals (col).count + gross_addition;
      table.row_totals (row).count    := table.row_totals (row).count + gross_addition;
      table.total.count              := table.total.count + gross_addition;
      for i in  1 .. Num_Data_Values loop
         table.cells (row) (col).pre_values (i)   := table.cells (row) (col).pre_values (i) +
                                                     (pre_values (i) * counts_gross);
         table.cells (row) (col).post_values (i)  := table.cells (row) (col).post_values (i) +
                                                     (post_values (i) * counts_gross);

         table.col_totals (col).pre_values (i) := table.col_totals (col).pre_values (i) +
                                                 (pre_values (i) * counts_gross);
         table.row_totals (row).pre_values (i) := table.row_totals (row).pre_values (i) +
                                                 (pre_values (i) * counts_gross);

         table.total.pre_values (i) := table.total.pre_values (i) +
                                       (pre_values (i) * counts_gross);

         table.col_totals (col).post_values (i) := table.col_totals (col).post_values (i) +
                                                  (post_values (i) * counts_gross);
         table.row_totals (row).post_values (i) := table.row_totals (row).post_values (i) +
                                                  (post_values (i) * counts_gross);

         table.total.post_values (i) := table.total.post_values (i) +
                                        (post_values (i) * counts_gross);
      end loop;
      --  we'll only store examples of the cells for now
      if (example (1) /= NO_EXAMPLE) then
         for n in  1 .. Num_Examples loop
            if (table.cells (row) (col).examples (n) (1) = NO_EXAMPLE) then
               table.cells (row) (col).examples (n)  := example;
               exit;
            end if;
         end loop;
      end if;
      for b in  1 .. Num_Breakdowns loop
         table.cells (row) (col).breakdown (b) (info (b))    :=
           table.cells (row) (col).breakdown (b) (info (b)) + gross_addition;
         table.row_totals (row).breakdown (b) (info (b))      :=
           table.row_totals (row).breakdown (b) (info (b)) + gross_addition;
         table.col_totals (col).breakdown (b) (info (b))      :=
           table.col_totals (col).breakdown (b) (info (b)) + gross_addition;
         table.total.breakdown (b) (info (b))                :=
           table.total.breakdown (b) (info (b)) + gross_addition;
      end loop;
   end add;

   function toString (table : in Table_Rec) return String is
   begin
      return "";
   end toString;

   function toCDA (bd : Cell_Contents) return String is
      outs : ustr.Unbounded_String := ustr.To_Unbounded_String ("");
   begin
      ustr.Append (outs, stda.LF);
      for c in  1 .. Max_Breakdown_Size loop
         for b in  1 .. Num_Breakdowns loop
            ustr.Append (outs, bd (b) (c)'Img);
            if (b < (Num_Breakdowns)) then
               ustr.Append (outs, ",");
            end if;
         end loop;
         ustr.Append (outs, stda.LF);
      end loop;
      return ustr.To_String (outs);
   end toCDA;

   function toCDA (table : Table_Rec) return String is
      outs : ustr.Unbounded_String := ustr.To_Unbounded_String ("");
   begin
      ustr.Append (outs, Row_Size'Img & stda.LF);
      for row in  1 .. Row_Size loop
         for col in  1 .. Row_Size loop
            ustr.Append (outs, table.cells (row) (col).count'Img & ",");
         end loop;
         ustr.Append (outs, table.row_totals (row).count'Img);
         ustr.Append (outs, stda.LF);
      end loop;
      for col in  1 .. Row_Size loop
         ustr.Append (outs, table.col_totals (col).count'Img & ",");
      end loop;
      ustr.Append (outs, table.total.count'Img & stda.LF);
      for row in  1 .. Row_Size loop
         for col in  1 .. Row_Size loop
            ustr.Append (outs, row'Img & "," & col'Img);
            ustr.Append (outs, toCDA (table.cells (row) (col).breakdown));
         end loop;
      end loop;
      for row in  1 .. Row_Size loop
         ustr.Append (outs, row'Img & ",-1");
         ustr.Append (outs, toCDA (table.row_totals (row).breakdown));
      end loop;

      for col in  1 .. Row_Size loop
         ustr.Append (outs, "-1," & col'Img);
         ustr.Append (outs, toCDA (table.col_totals (col).breakdown));
      end loop;
      ustr.Append (outs, "-1,-1,");
      ustr.Append (outs, toCDA (table.total.breakdown));
      ustr.Append (outs, stda.LF);

      return ustr.To_String (outs);
   end toCDA;

end factor_table;
