--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
with base_model_types; use base_model_types;
with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;
--
--
--
package body model_output is

        --
        --  a fresh output record
        --
        function newOutput return One_LA_Output is
                diff : One_LA_Output;
        begin
                return diff;
        end newOutput;

        function toString ( res : One_LA_Output ) return string is
        begin
                return LF & "Legal Aid State = " & res.la_State'Img &
                LF & LF &
                " assessable_Capital " & res.assessable_Capital'Img &
                " excess_Capital " & res.excess_Capital'Img &
                " excess_Income " & res.excess_Income'Img &
                " allowances " & res.allowances'Img &
                LF &
                "    of which: child_Allowances " & res.child_Allowances'Img &
                " partners allowances " & res. partners_Allowances'Img &
                LF &
                " capital_Allowances " & res.capital_Allowances'Img &
                " assessable_Income " & res.assessable_Income'Img &
                " gross_Income " & res.gross_Income'Img &
                LF &
                " benefits_In_Kind " & res.benefits_In_Kind'Img &
                " deductions_From_Income " & res.deductions_From_Income'Img &
                " income_Contribution " & res.income_Contribution'Img &
                " capital_Contribution " & res.capital_Contribution'Img &
                " housing_Costs " & res.housing_Costs'Img &
                " rent_Share_Deduction " & res.rent_Share_Deduction'Img &
                LF &
                "    => disposable_Income " & res.disposable_Income'Img &
                " disposable_Capital " & res.disposable_Capital'Img &
                LF &
                " targetting_index " & res.targetting_index'Img &
                LF ;
        end toString;

        function toCDA ( res : One_LA_Output ) return string is
        begin
                return res.assessable_Capital'Img &
                "," & res.excess_Capital'Img &
                "," & res.excess_Income'Img &
                "," & res.allowances'Img &
                "," & res.capital_Allowances'Img &
                "," & res.assessable_Income'Img &
                "," & res.disposable_Capital'Img &
                "," & res.gross_Income'Img &
                "," & res.benefits_In_Kind'Img &
                "," & res.deductions_From_Income'Img &
                "," & res.income_Contribution'Img &
                "," & res.capital_Contribution'Img &
                "," & res.housing_Costs'Img &
                "," & res.rent_Share_Deduction'Img &
                "," & res.targetting_index'Img &
                LF;
        end toCDA;

        function difference ( res1, res2 : One_LA_Output ) return One_LA_Output is
                diff : One_LA_Output;
        begin
                diff.assessable_Capital := res2.assessable_Capital - res1.assessable_Capital;
                diff.excess_Capital := res2.excess_Capital - res1.excess_Capital;
                diff.excess_Income := res2.excess_Income - res1.excess_Income;
                diff.allowances := res2.allowances - res1.allowances;
                diff.capital_Allowances := res2.capital_Allowances - res1.capital_Allowances;
                diff.assessable_Income := res2.assessable_Income - res1.assessable_Income;
                diff.disposable_Capital := res2.disposable_Capital - res1.disposable_Capital;
                diff.gross_Income := res2.gross_Income - res1.gross_Income;
                diff.benefits_In_Kind := res2.benefits_In_Kind - res1.benefits_In_Kind;
                diff.deductions_From_Income := res2.deductions_From_Income - res1.deductions_From_Income;
                --  diff.la_State := res2.la_State - res1.la_State;
                diff.income_Contribution := res2.income_Contribution - res1.income_Contribution;
                diff.capital_Contribution := res2.capital_Contribution - res1.capital_Contribution;
                diff.housing_Costs  := res2.housing_Costs - res1.housing_Costs;
                diff.rent_Share_Deduction := res2.rent_Share_Deduction - res1.rent_Share_Deduction;
                diff.targetting_index := res2.targetting_index - res1.targetting_index;
                return diff;
        end difference;

	function recode_LA_State( st : Legal_Aid_State  ) return modelint is
        begin
        	return Legal_Aid_State'Pos( st ) + 1;
        end recode_LA_State;


        function recode_Gross_Income_Test_State_Type( gt : Gross_Income_Test_State_Type ) return modelint is
        m : integer := MISS;
        begin
                case gt is
                when na => m := MISS;
                when below_mininum => m := 2;
                when means_tested => m := 3;
                when above_maximum => m := 4;
                when passported => m := 1;
                end case;
                return m;
        end recode_Gross_Income_Test_State_Type;


end model_output;
