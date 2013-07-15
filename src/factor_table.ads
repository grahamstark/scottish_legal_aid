--
--  $Author: graham_s $
--  $Date: 2007-08-17 21:32:50 +0100 (Fri, 17 Aug 2007) $
--  $Revision: 3846 $
-- 
--  Very Very simple n by n table with examples;
--  FIXME: see discrimimated record types (pp196-) for a simpler way of doing this
--  alternatively, maybe have cell content and examples as private types declared in the generic bit.
--  But this is good enough for now.
-- 
with base_model_types; use base_model_types;

generic
   Row_Size, 
	Num_Data_Values, 
	Num_Breakdowns, 
	Max_Breakdown_Size, 
	Num_Examples, 
	Num_Example_Components : Integer;

package factor_table is

   NO_EXAMPLE : constant := -999;

   --
   --  a very simple set of numbers that can be pulled out of a table and
   --  used as a view of the table's main contents
   --
   type Basic_Factor_Array is array (1 .. Row_Size + 1, 1 .. Row_Size + 1) of money;
   subtype Values_Range is Integer range 1 .. Num_Data_Values;
   type Values_Array is array (Values_Range) of real;

   type Compare_Cell is (current_cell, row_total, col_total, total);
   type Cell_Compare_Type is (counter, sys1_level, sys2_level, abs_change, pct_change);

   type Breakdown_Array is array (1 .. Max_Breakdown_Size) of money;
   type Cell_Contents is array (1 .. Num_Breakdowns) of Breakdown_Array;
   type Breakdown_Sizes is array (1 .. Num_Breakdowns) of Integer;
   type Example_Component is array (1 .. Num_Example_Components) of Integer;
   type Examples_array is array (1 .. Num_Examples) of Example_Component;
   
   --
   --  A single cell in a table.
   --  Contains a counter
   --
   type Cell_Rec is
      record
         count                   : money          := 0.0;
         pre_values, post_values : Values_Array   := (others => 0.0);
         breakdown               : Cell_Contents;
         examples                : Examples_array := (others => (others => NO_EXAMPLE));
      end record;
		
   type Cell_Array is array (1 .. Row_Size) of Cell_Rec;
   type Table_Cells is array (1 .. Row_Size) of Cell_Array;

   --
   -- A table. This is a bit un-generic, really.
   --
   type Table_Rec is
      record
         cells     : Table_Cells :=
           (others => (others => (count       => 0.0,
                                  pre_values  => (others => 0.0),
                                  post_values => (others => 0.0),
                                  examples    => (others => (others => NO_EXAMPLE)),
                                  breakdown   => (others => (others => 0.0)))));
         row_totals : Cell_Array  :=
           (others => (count       => 0.0,
                       pre_values  => (others => 0.0),
                       post_values => (others => 0.0),
                       examples    => (others => (others => NO_EXAMPLE)),
                       breakdown   => (others => (others => 0.0))));
         col_totals : Cell_Array  :=
           (others => (count       => 0.0,
                       pre_values  => (others => 0.0),
                       post_values => (others => 0.0),
                       examples    => (others => (others => NO_EXAMPLE)),
                       breakdown   => (others => (others => 0.0))));
         total     : Cell_Rec    :=
           (count       => 0.0,
            pre_values  => (others => 0.0),
            post_values => (others => 0.0),
            examples    => (others => (others => NO_EXAMPLE)),
            breakdown   => (others => (others => 0.0)));
      end record;

   type breakdowns is array (1 .. Num_Breakdowns) of Integer;

   --
   --  this is used for storing a default null table in sessions
   --
   BLANK_TABLE : constant Table_Rec :=
     (cells     => (others => (others => (count       => 0.0,
                                          pre_values  => (others => 0.0),
                                          post_values => (others => 0.0),
                                          examples    => (others => (others => NO_EXAMPLE)),
                                          breakdown   => (others => (others => 0.0))))),
      row_totals => (others => (count       => 0.0,
                               pre_values  => (others => 0.0),
                               post_values => (others => 0.0),
                               examples    => (others => (others => NO_EXAMPLE)),
                               breakdown   => (others => (others => 0.0)))),
      col_totals => (others => (count       => 0.0,
                               pre_values  => (others => 0.0),
                               post_values => (others => 0.0),
                               examples    => (others => (others => NO_EXAMPLE)),
                               breakdown   => (others => (others => 0.0)))),
      total     => (count       => 0.0,
                    pre_values  => (others => 0.0),
                    post_values => (others => 0.0),
                    examples    => (others => (others => NO_EXAMPLE)),
                    breakdown   => (others => (others => 0.0))));

   --
   -- Add an observation to a table.
   -- 
   --
   procedure add
     (table        : in out Table_Rec;
      row, col     : Integer; --  row, col to add add
      gross        : real;    --  grossing factor: the weight of this observation
      counts_gross : real;    --  grossing factor used to accumulate the example data - in practice this is the same as gross, and I can't remember why I included this.
      pre_values   : Values_Array; -- a list of reals to add to the table cell. For example, payments, contribution, etc.
      post_values  : Values_Array; -- list of same things, for the post- system.
      info         : breakdowns;   -- a collection of characteristics to add for this observation, for example 1=tenure type, 2=region and so on;
      example      : Example_Component := (others => NO_EXAMPLE)); -- record needed so we can look up example observations in this table (for example, household reference numbers);
   
   -- pretty print the table
   function toString (table : Table_Rec) return String;
   
   -- dump it to comma-delimited ascii
   function toCDA (table : Table_Rec) return String;
   
   --
   -- return the differences (as percents) between the composition of cell (row)(col) and some
   -- totals cell.
   --
   --  for example, we have 10% more council tenants in cell(1,2) than in the sample as a whole.
   --
   function get_breakdown_differences
     (table    : Table_Rec;
      row, col : Integer;
      compare  : Compare_Cell) return Cell_Contents;
   --
   -- use -1 for row/col totals -1,-1 for overall totals
   --
   function get_cell_breakdown (table : Table_Rec; row, col : Integer) return Cell_Contents;

   --
   -- Extract a view from a table, as a little n x n matrix of reals
   -- 
   --
   function expressTable
     (table        : Table_Rec;
      comp_Cell    : Compare_Cell; -- compare the cells to this, for example differences to the row totals, col totals, etc;
      cell_op      : Cell_Compare_Type; -- show levels, percentage changes and so on;
      value_To_Use : Integer) return Basic_Factor_Array; -- which of the pre/post values to use (might be income tax, la contributions, etc.)

end factor_table;
