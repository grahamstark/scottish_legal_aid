--
--  $Author: graham_s $
--  $Date: 2007-03-18 10:38:27 +0000 (Sun, 18 Mar 2007) $
--  $Revision: 2378 $
--
--  basic types for our model;
--
with Ada.Text_IO; use Ada.Text_IO;

with Ada.Strings.Bounded; use Ada.Strings.Bounded;

package body base_model_types is

        function safe_mult( a, b : real ) return Money is
                as : real := a;
                bs : real := b;
        begin
                if( a = MISS_R ) then as := 0.0; end if;
                if( b = MISS_R ) then bs := 0.0; end if;
                return Money( as * bs );
        end safe_mult;


        function safe_add ( a, b : real; c, d, e, f, g, h : real := 0.0 ) return money is
                as : real := a;
                bs : real := b;
                cs : real := c;
                ds : real := d;
                es : real := e;
                fs : real := f;
                gs : real := g;
                hs : real := h;
        begin
                if( as = MISS_R ) then as := 0.0; end if;
                if( bs = MISS_R ) then bs := 0.0; end if;
                if( cs = MISS_R ) then cs := 0.0; end if;
                if( ds = MISS_R ) then ds := 0.0; end if;
                if( es = MISS_R ) then es := 0.0; end if;
                if( fs = MISS_R ) then fs := 0.0; end if;
                if( gs = MISS_R ) then gs := 0.0; end if;
                if ( hs = MISS_R ) then hs := 0.0; end if;
                return money( as+bs+cs+ds+es+fs+gs+hs );

        end;

        function safe_add ( a, b : modelint ) return modelint is
                as : modelint := a;
                bs : modelint := b;
        begin
                if( as = MISS ) then as := 0; end if;
                if( bs = MISS ) then bs := 0; end if;
                return as+bs;
        end safe_add;

        function safe_add ( a, b : money ) return money is
                as : money := a;
                bs : money := b;
        begin
                if( as = money(MISS_R) ) then as := 0.0; end if;
                if( bs = money(MISS_R) ) then bs := 0.0; end if;
                return as+bs;
        end safe_add;

  	function safe_add ( a : money; b : real ) return money is
        begin
                return safe_add( a, money( b ) );
        end safe_add;
end base_model_types;
