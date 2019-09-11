ultimo_corte := 0;
while(iteracao_grande < 10000 and time_current < time_limit and subdradient_modulo > 0 and UB - LB > 1/10**3 and UB - LB > abs(UB)*1/10**6,
         iteracao_grande := iteracao_grande + 1;
$include "C:\Artigos\p-LD\numerical experiments\v8\problema_convetido\Oraculo.gms"

* cutting planes method
*adiciona um corte
         tamanho_passo := 10;
         ultimo_corte := ultimo_corte + 1;
         cuts_used(cuts)$(ord(cuts)=ultimo_corte) := yes;
         cut_a(cuts,i,sc)$(ord(cuts) = ultimo_corte and domininio_multip(i,sc)) := subgradient(i, sc);
         cut_b(cuts)$(ord(cuts) = ultimo_corte) := UB_iteracao - sum((i,sc)$domininio_multip(i,sc), multiplicadores(i, sc)*subgradient(i, sc));
*         new_multiplier.lo(i,sc) := 0;
*         new_multiplier.up(i,sc): = 0;
         new_multiplier.lo(i,sc)$domininio_multip(i,sc) := multiplicadores(i,sc) - tamanho_passo;
         new_multiplier.up(i,sc)$domininio_multip(i,sc) := multiplicadores(i,sc) + tamanho_passo;
         solve planning_cuts us lp min cuts_Fo;
         multiplicadores(i,sc)$domininio_multip(i,sc) := new_multiplier.l(i,sc);

*recalcula os tempos
         time_current = TimeElapsed - time_Start;
         if(time_current < time_limit,
                  Rel_lagrange.reslim = time_limit - time_current;
         else
                  Rel_lagrange.reslim = 0;
         );

         display UB, LB, x_stoc_rel, x_stoc_ori, subgradient, valor_fixado, multiplicadores;

         put Results;
         put '----------' /
             'Iteration ', iteracao_grande  /
             'Time elapsed ', time_current  /
             'UB_iteracao ', UB_iteracao /
             'LB_iteracao ', LB_iteracao /
             'UB ', UB /
             'LB ', LB /
             'LB_cut ', cuts_Fo.l
             ;
         putclose;
);



display UB, LB, x_stoc_rel, x_stoc_ori, subgradient, valor_fixado, multiplicadores;
