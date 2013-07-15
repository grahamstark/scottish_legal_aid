with model_household;  use model_household;
with base_model_types; use base_model_types;
with Text_IO;

package body criminal_legal_aid_costs_model is

        subtype Age_Range_Type is Integer range 1 .. 14;

        type Costs_Lookup_Table is array (Age_Range_Type, Gender) of Criminal_Cost_Type_Array;

        type Decile_Array is array (Decile_Number) of real;

        type Age_Range_Upper_Limit_Type is array (Age_Range_Type) of Integer;

        Age_Range_Upper_Limit : constant Age_Range_Upper_Limit_Type :=
               (16,
                17,
                21,
                24,
                29,
                34,
                39,
                44,
                49,
                54,
                59,
                64,
                69,
                999);

        Decile_Weighting : constant Decile_Array :=
               (2.65,
                1.46,
                1.16,
                1.0,
                0.75,
                0.78,
                0.74,
                0.58,
                0.48,
                0.28);
        --p_summ, =, p_magis
        CRIMINAL_LOOKUP : constant Costs_Lookup_Table :=
               (1  => (male   => (p_indict => 0.010998,
                                  p_summ   => 0.004174,
                                  p_moto   => 0.002002,
                                  p_magis  => 0.017174),
                       female => (0.051824, 0.029695, 0.037326, 0.118845)),
                2  => (male   => (0.070871, 0.034932, 0.106584, 0.212387),
                       female => (0.050867, 0.025358, 0.104620, 0.180845)),
                3  => (male   => (0.033153, 0.017206, 0.089619, 0.139978),
                       female => (0.022512, 0.014074, 0.067193, 0.103780)),
                4  => (male   => (0.015091, 0.011870, 0.052410, 0.079370),
                       female => (0.010632, 0.009663, 0.039689, 0.059984)),
                5  => (male   => (0.006569, 0.005636, 0.030055, 0.042259),
                       female => (0.003907, 0.004516, 0.023974, 0.032398)),
                6  => (male   => (0.002706, 0.002467, 0.016988, 0.022161),
                       female => (0.001253, 0.001034, 0.010278, 0.012565)),
                7  => (male   => (0.000710, 0.000648, 0.005721, 0.007078),
                       female => (0.000304, 0.000096, 0.001864, 0.002264)),
                8  => (male   => (0.001651, 0.000588, 0.000128, 0.002367),
                       female => (0.016513, 0.011246, 0.013405, 0.041163)),
                9  => (male   => (0.008584, 0.004808, 0.013329, 0.026721),
                       female => (0.008524, 0.004573, 0.020226, 0.033323)),
                10 => (male   => (0.004350, 0.002750, 0.013843, 0.020943),
                       female => (0.002985, 0.002244, 0.010843, 0.016072)),
                11 => (male   => (0.002145, 0.002193, 0.009059, 0.013397),
                       female => (0.001822, 0.001870, 0.007092, 0.010785)),
                12 => (male   => (0.001329, 0.000904, 0.005680, 0.007913),
                       female => (0.000891, 0.000856, 0.003901, 0.005648)),
                13 => (male   => (0.000323, 0.000578, 0.002756, 0.003656),
                       female => (0.000115, 0.000209, 0.001766, 0.002089)),
                14 => (male   => (0.000093, 0.000118, 0.000844, 0.001054),
                       female => (0.000019, 0.000010, 0.000127, 0.000157)));

        function get_Age_Range (age : Integer) return Age_Range_Type is
        begin
                for arange in  Age_Range_Type'First .. Age_Range_Type'Last loop
                        if (age < Age_Range_Upper_Limit (arange)) then
                                return arange;
                        end if;
                end loop;
        end get_Age_Range;

        function lookup( decile : Decile_Number; age : modelint; sex : Gender ) return Criminal_Cost_Type_Array is
                a   : Criminal_Cost_Type_Array;
                dec_weight : constant Real := Decile_Weighting( decile );
                age_range : constant Age_Range_Type := get_Age_Range( age );
        begin
                a := CRIMINAL_LOOKUP( age_range, sex );
                for c in Criminal_Cost_Type'First .. Criminal_Cost_Type'Last loop
                        a(c) := a(c) * dec_weight;
                end loop;
                return a;
        end lookup;

        function add_to_costs( a, b : Criminal_Cost_Type_Array ) return Criminal_Cost_Type_Array is
        outx : Criminal_Cost_Type_Array;
        begin
                for c in Criminal_Cost_Type'First .. Criminal_Cost_Type'Last loop
                        outx(c) := a(c) + b(c);
                end loop;
                return outx;
        end add_to_costs;

        function Calculate_Costs( bu : Model_Benefit_Unit;
        			  decile : Decile_Number;
                                  la_state : Legal_Aid_State ) return Criminal_Cost_Type_Array is
                working_costs, costs : Criminal_Cost_Type_Array := ( others=>0.0 );
        begin
                if( la_state /= disqualified ) and ( la_state /= na ) then
                        for chno in 1 .. bu.numChildren loop
                                working_costs := lookup( decile, bu.children ( chno ).age, bu.children ( chno ).sex );
                                costs := add_to_costs( costs, working_costs );
                        end loop;
                        for adno in head .. bu.last_adult loop
                                working_costs := lookup( decile, bu.adults ( adno ).age, bu.adults ( adno ).sex );
                                costs := add_to_costs( costs, working_costs );
                        end loop;
                end if;
                for c in Criminal_Cost_Type'First .. Criminal_Cost_Type'Last loop
                        text_io.put( "criminal_legal_aid_costs_model.Calculate_Costs:: cost[ "&c'Img&" ] = " & costs(c)'Img );
                end loop;
                text_io.new_line;
                return costs;
        end Calculate_Costs ;

end criminal_legal_aid_costs_model;
