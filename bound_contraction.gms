scalar mudanca_bound_variavel /1/;
parameter novo_LB(i), novo_UB(i);
parameter Escolhe_Variavel(i);

display x.lo, x.up;
while(mudanca_bound_variavel = 1,
         mudanca_bound_variavel = 0;
         Escolhe_Variavel(i) = 0;
         display x.lo, x.up;
         loop(ii,
                  Escolhe_Variavel(ii) = 1;
                  solve Rel_bound us MIP min FO_Bound_variavel;
                  novo_LB(ii) = FO_Bound_variavel.l;
                  solve Rel_bound us MIP max FO_Bound_variavel;
                  novo_UB(ii) = FO_Bound_variavel.l;
                  display Escolhe_Variavel, novo_LB, x.lo, novo_UB, x.up;
                  Escolhe_Variavel(ii) = 0;
         );
*         if ( sum(i, novo_LB(i) > x.lo(i)) + sum(i, novo_UB(i) < x.up(i)),
*                 mudanca_bound_variavel = 1;
*         );
         LB_x(ii) =  max(novo_LB(ii), x.lo(ii));
         UB_x(ii) =  min(novo_UB(ii), x.up(ii));
         x.lo(ii) = LB_x(ii);
         x.up(ii) = UB_x(ii);
);
display novo_LB, novo_UB;
*display x.lo, novo_UB, x.up;