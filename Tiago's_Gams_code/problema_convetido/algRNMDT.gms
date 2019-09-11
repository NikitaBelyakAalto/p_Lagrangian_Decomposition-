while(not stop,
         delta_x_ws.up(j,sc)$sum((r,i),BL(r,i,j)) := 2**pp_ws(j,sc);
*         x_value(i,l) := LB_x(i) + (UB_x(i) - LB_x(i))*sum(ll$(ord(ll)<ord(l)), 2**(p));
         iter_O = iter_O + 1;
$ontext
         loop(i,
                 aux_x = (x.l(i)-x.lo(i))/(x.up(i)-x.lo(i));
                 loop(l$(ord(l)<=-p),
                         if(aux_x >= 2**(-ord(l)),
                                 z.l(i,l) = 1;
                                 aux_x = aux_x - 2**(-ord(l));
                         else
                                 z.l(i,l) = 0;
                         );
                 );
                 delta_x.l(i) = aux_x;
         );
         w.l(i,j) = x.l(i)*x.l(j);
         hat_x.l(i,j,l) = x.l(j)*z.l(i,l);
         v.l(i,j) = 0;
         display x.l, z.l, w.l, y.l, delta_x.l;
$offtext

         time_current = TimeElapsed - time_Start;
                 if(time_current < time_limit,
                         Rel_ws.reslim = time_limit - time_current;
                         Fixed_ws.reslim =  min(100,time_limit - time_current);
                 else
                         Rel_ws.reslim = 0;
                         Fixed_ws.reslim = 0;
                 );

*                  iter_tot = iter_tot + 1;
*                 Rel.cutoff = UB;

                 solve Rel_ws max FO us MIP;
                 x_relaxado_ws(i,sc) = x_ws.l(i,sc);
                 w_relaxado_ws(i,j,sc) = w_ws.l(i,j,sc);
                 v_relaxado_ws(i,j,sc) = v_ws.l(i,j,sc);
                 delta_x_relaxado_ws(i,sc) = delta_x_ws.l(i,sc);
                 if(sum((j,sc), pp_ws(j,sc)) = 0 and card(e) = 0,
                         FO_atual = FO.l;
                 else
                         FO_atual = Rel_ws.objest;
                 );
                 UB = min(UB,FO_atual);
                 display FO_atual;
* fixa o valor das variáveis inteiras originais do problema
                 y_fixed_ws(e,sc) = y_ws.l(e,sc);

                 solve Fixed_ws max FO us NLP;
                 if(Fixed_ws.modelstat <= 2,
                         LB = max(LB,FO.l);
                 );
                 display UB, LB, p, y_fixed_ws;

                 Bound_UB = UB;
*$include "C:\Artigos\p-LD\numerical experiments\v7\problema_convetido\bound_contraction.gms";
         telapsed = TimeElapsed;
         UB_externo = Bound_UB;
         LB_externo = LB;

         put Results_iterations;
                 put iter_O, ' ',
                 telapsed, ' ',
                 UB_externo:10:4, ' ',
                 LB_externo:10:4, ' ',
                 p;
         putclose;



         if((UB - LB < 10**(-2)) or (UB-LB)/abs(LB) < 10**(-4) or TimeElapsed > time_limit,
                 stop = 1;
         else
                 maior_valor = smax(j, sum((r,i,sc)$BL(r,i,j), abs(a(r,i,j)*(w_relaxado_ws(i,j,sc) - x_relaxado_ws(i,sc)*x_relaxado_ws(j,sc)))));
                 maior_j_ws(j,sc) = 0;
                 if((mod(iter_O+1,10) = 0),
                         pp_ws(j,sc)$sum((r,i),BL(r,i,j)) := pp_ws(j,sc) -1;
                 else
                         maior_j(j) = no;
                         while(sum((j,sc)$maior_j_ws(j,sc), 1) < 3 and sum((j,sc)$(not maior_j_ws(j,sc) and sum((r,i),BL(r,i,j))), 1) > 0,
                                 stop_2 = 0;
                                 maior_valor = smax((j,sc)$(not maior_j_ws(j,sc)), sum((r,i)$BL(r,i,j), abs(a(r,i,j)*(w_relaxado_ws(i,j,sc) - x_relaxado_ws(i,sc)*x_relaxado_ws(j,sc)))));
                                 loop((j,sc)$(not maior_j_ws(j,sc) and stop_2 = 0),
                                         if(sum((r,i)$BL(r,i,j), abs(a(r,i,j)*(w_relaxado_ws(i,j,sc) - x_relaxado_ws(i,sc)*x_relaxado_ws(j,sc)))) >= maior_valor*.999,        maior_j_ws(j,sc) = yes; stop_2 = 1;);
                                 );
                         );
*                        loop(j$(sum((r,i)$BL(r,i,j), abs(a(r,i,j)*(w.l(i,j) - x.l(i)*x.l(j)))) >= maior_valor*.5 and sum((r,i),BL(r,i,j))),
*                                maior_j(j) = 1;
*                        );
                        pp_ws(j,sc)$maior_j_ws(j,sc) :=  pp_ws(j,sc) - 1;
*min(pp(j),ceil(smin(i$sum(r,BL(r,i,j) and (abs(v_relaxado(i,j)-x_relaxado(i)*delta_x_relaxado(j))>0)), log2(4*abs(v_relaxado(i,j)-x_relaxado(i)*delta_x_relaxado(j))/(UB_x(i)-LB_x(i))))) - 1) ;
                        display maior_j, pp, maior_valor;
                 );
                 p = p - 1;
         );
);
