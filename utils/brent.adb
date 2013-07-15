package body brent is
   --
   --  implements brent's method for finding a miminum of an arbtrary functio
   --  from Numerical Recipies (Pascal) ch 10.,
   --  from Numerical Recipies (Pascal) ch 9.3,
   --
   --

   function f
     (x       : real;
      control : Control_Rec;
      calc    : Minimand)
      return    Optimisation_Output
   is
   begin
      return calc (control, x);
   end f;

   function Sign (a, b : real) return real is
   begin
      if b >= 0.0 then
         return abs (a);
      else
         return -1.0 * abs (a);
      end if;
   end Sign;

   procedure Optimise
     (control           : in out Control_Rec;
      calc              : Minimand;
      optimum_x         : in out real;
      optimum_y         : in out real;
      stored_points     : in out Point_Array;
      intermediate_data : in out Intermediate_Data_Array;
      num_iterations    : in out Integer;
      err               : in out Error_Conditions)
   is
      a, b, d, ax, bx, cx, tol, e, eTemp, fu, fv, fw, fx, p, q, r, tol1, tol2, u, v, w, x, xm :
        real := 0.0;
      iter                                                                                    :
        Integer := 0;
      --  bracketing: min is between ax and cx and (f(bx) < f(ax)) & (f(bx) < f(cx))  *)
      done   : Boolean := False;
      output : Optimisation_Output;
   begin
      ax  := control.start;
      cx  := control.stop;
      tol := control.tol;
      x   := ax; -- 26/10: x was unassigned check this !!!!!! *)
      bx  := (ax + cx) / 2.0;
      if ax < cx then
         a := ax;
      else
         a := cx;
      end if;
      if ax > cx then
         b := ax;
      else
         b := cx;
      end if;
      v                   := bx;
      w                   := v;
      e                   := 0.0;
      output              := f (x, control, calc);
      fx                  := output.minimum;
      stored_points (1).x := x;
      stored_points (1).y := fx;

      fv   := fx;
      fw   := fx;
      done := False;
      err  := NoError;
      iter := 0;
      while not done loop
         iter := iter + 1;
         xm   := (a + b) / 2.0;
         tol1 := (tol * abs (x)) + NEARLY_ZERO;
         tol2 := 2.0 * tol1;
         if abs (x - xm) <= (tol2 - ((b - a) / 2.0)) then
            done := True;
            err  := NoError;
         elsif iter > MAX_ITERATIONS then
            done := True;
            err  := TooManyIterations;
         else
            if abs (e) > tol1 then
               r := (x - w) * (fx - fv);
               q := (x - v) * (fx - fw);
               p := ((x - v) * q) - ((x - w) * r);
               q := 2.0 * (q - r);
               if q < 0.0 then
                  p := -1.0 * p;
               end if;
               q     := abs (q);
               eTemp := e;
               e     := d;
               if (abs (p) >= abs ((q * eTemp) / 2.0)) or
                  (p <= (q * (a - x))) or
                  (p >= (q * (b - x)))
               then
                  if x >= xm then
                     e := a - x;
                  else
                     e := b - x;
                  end if;
                  d := GOLDEN_RATIO * e;
               else
                  d := p / q;
                  u := x + d;
                  if ((u - a) < tol2) or ((b - u) < tol2) then
                     d := Sign (tol1, (xm - x));
                  end if;
               end if; -- if abs( p ) *)
            else
               if x >= xm then
                  e := a - x;
               else
                  e := b - x;
               end if;
               d := GOLDEN_RATIO * e;
            end if;   -- ABS( e ) < tol *)
            if abs (d) >= tol1 then
               u := x + d;
            else
               u := x + Sign (tol1, d);
            end if;
            output                     := f (u, control, calc);
            fu                         := output.minimum;
            stored_points (iter + 1).x := x;
            stored_points (iter + 1).y := fx;

            if fu <= fx then
               if u >= x then
                  a := x;
               else
                  b := x;
               end if;
               v  := w;
               fv := fw;
               w  := x;
               fw := fx;
               x  := u;
               fx := fu;
            else
               if u < x then
                  a := u;
               else
                  b := u;
               end if;
               if (fu <= fw) or (w = x) then
                  v  := w;
                  fv := fw;
                  w  := u;
                  fw := fu;
               elsif (fu <= fv) or (v = x) or (v = w) then
                  v  := u;
                  fv := fu;
               end if; -- fu <= fv etc. *)
            end if;    -- fu > fx *)
         end if;       -- ABS( x - m ) *)
      end loop;        --  whilenot done *)

      optimum_x      := x;
      optimum_y      := fx;
      num_iterations := iter;
      -- this is a hack, but we're going to run one more time
      -- so we end up with the intermediate data from the optimal
      -- point. I think the routime may stop after a non-optimal point.
      -- If I was smarter, I'd work out saving this above
      output := f (x, control, calc);

      intermediate_data := output.intermediate_data;
   end Optimise;

end brent;
