*# step 0

*pp(j) := -5;
*multiplicadores(i,sc)$dominio_multip(i,sc) := 0.31808719;

*bundle_gamma := 1;
bundle_x(i,sc)$dominio_multip(i,sc) :=  multiplicadores(i,sc);
bundle_z(i,sc)$dominio_multip(i,sc) := bundle_x(i,sc);
bundle_erro := 10**7;
bundle_iterations := 0;
bundle_fe_usado(bundle_fe) := no;
bundle_ultimo_feixe_usado := 0;
feixe_1(bundle_fe,i,sc) := 0;
feixe_2(bundle_fe) := 0;
bundle_gamma = 1000;


multiplicadores(i,sc)$dominio_multip(i,sc) :=  bundle_z(i,sc);
$include "D:\p-LD\numerical experiments\v9\problema_convetido\Oraculo.gms"

* Captura o tempo e ajusta o tempo limite dos pr�ximos modelos
time_current = TimeElapsed - time_Start;
if(time_current < time_limit,
         Rel_lagrange.reslim = time_limit - time_current;
         m_fixa_primeiro_estagio_fixed.reslim = min(50, time_limit - time_current);
else
         Rel_lagrange.reslim = 0;
         m_fixa_primeiro_estagio_fixed.reslim = 0;
);
* escreve resultado parcial no arquivo "Results"
         put Results;
         put '----------' /
             'Iterecao ', iteracao_grande /
             'Iterecao Bundle ', bundle_iterations  /
             'Time elapsed ', time_current  /
             'UB_iteracao ', UB_iteracao /
             'LB_iteracao ', LB_iteracao /
             'UB ', UB /
             'LB ', LB /
             'bundle ', '---' /
             'passo serio ', '---' /
             'bundle_erro ', '---' /
             'gamma ', bundle_gamma /
             'viavel ', local_viavel
             ;
         putclose;

bundle_fe_usado('1') := yes;
bundle_y(i,sc)$dominio_multip(i,sc) :=  subgradient(i,sc);
feixe_1(bundle_fe,i,sc)$(dominio_multip(i,sc) and bundle_fe_usado(bundle_fe)) := bundle_y(i,sc);
feixe_2(bundle_fe)$(bundle_fe_usado(bundle_fe)) := 0;
bundle_fx := UB_iteracao;
bundle_fz := UB_iteracao;
bundle_ultimo_feixe_usado = 1;


while(bundle_iterations < 1000 and time_current < time_limit and UB - LB > 1/10**2 and UB - LB > abs(LB)*(1/10**4) and bundle_erro > 1/10**3
*and UB-bundle_erro-LB < 1/10**2 and UB-bundle_erro-LB < abs(LB)*(1/10**4)
,
bundle_iterations := bundle_iterations + 1;
*display iteracao_grande, bundle_iterations, UB, LB, feixe_1, feixe_2;

*#step 1
solve m_bundle us QCP min bundle_FO;
bundle_z(i,sc)$dominio_multip(i,sc) :=  bundle_new_multiplier.l(i,sc);
multiplicadores(i,sc)$dominio_multip(i,sc) := bundle_z(i,sc);
$include "D:\p-LD\numerical experiments\v9\problema_convetido\Oraculo.gms"
bundle_y_novo(i,sc)$dominio_multip(i,sc) :=  subgradient(i,sc);
bundle_fz := UB_iteracao;
*# step 2
********** roda oraculo
bundle_delta := bundle_fx - bundle_FO.l;

* contas para o step 4 e para o criterio de parada
*bundle_v(bundle_fe) := 0;
bundle_v(bundle_fe)$bundle_fe_usado(bundle_fe) := bundle_con.m(bundle_fe);
bundle_d(i,sc)$dominio_multip(i,sc) := sum(bundle_fe$bundle_fe_usado(bundle_fe), bundle_v(bundle_fe)*feixe_1(bundle_fe,i,sc));
bundle_epsilon := sum(bundle_fe$bundle_fe_usado(bundle_fe), bundle_v(bundle_fe)*feixe_2(bundle_fe));
*bundle_erro := bundle_epsilon + sum((i,sc)$dominio_multip(i,sc), power(bundle_d(i,sc),2))/(2*bundle_gamma);
bundle_erro := bundle_delta;
display iteracao_grande, bundle_iterations, bundle_fe_usado, bundle_v, bundle_d, bundle_epsilon, bundle_erro, bundle_con.m, feixe_1, feixe_2;
put Results_feixes;
         put 'Grande_iteracao ', iteracao_grande /;
         put 'Bundle_iteracao ', bundle_iterations /;
         put 'feixe_usado ' /; loop(bundle_fe$bundle_fe_usado(bundle_fe), put bundle_fe.tl /);
         put 'feixe_1 ' /; loop((bundle_fe,i,sc)$(bundle_fe_usado(bundle_fe) and dominio_multip(i,sc)) , put feixe_1(bundle_fe,i,sc):10:4 /);
         put 'feixe_2 ' /; loop(bundle_fe$bundle_fe_usado(bundle_fe), put feixe_2(bundle_fe):10:4 /);
         put 'v ' /; loop(bundle_fe$bundle_fe_usado(bundle_fe), put bundle_v(bundle_fe):10:4/);
         put 'd ' /; loop((i,sc)$(dominio_multip(i,sc)), put bundle_d(i,sc):10:4 /);
         put 'epsilon ', bundle_epsilon:10:4 /;
         put 'bundle_erro ', bundle_erro:10:4 /;
         put 'multiplicadores ', loop((i,sc)$dominio_multip(i,sc), put multiplicadores(i,sc):10:4 /);
         put 'gamma ' , bundle_gamma:10:4 /;
         put 'fx ', bundle_fx:10:10 /;
         put 'fz ', bundle_fz:10:10 /;
         put 'Bundle Fo ', bundle_fo.l:10:10 /;
         put 'x '/; loop((i,sc)$dominio_multip(i,sc), put bundle_x(i,sc):10:10 /);
         put 'z '/; loop((i,sc)$dominio_multip(i,sc), put bundle_z(i,sc):10:10 /);
         put 'y '/; loop((i,sc)$dominio_multip(i,sc), put bundle_y(i,sc) /);
         put 'y_novo '/; loop((i,sc)$dominio_multip(i,sc), put bundle_y_novo(i,sc) /);
         put 'passo serio ', (bundle_fx - bundle_fz >= bundle_sigma * bundle_delta) /;
         put 'x estoc fstage ' /; loop((i,sc)$iVc(i), put i.tl, sc.tl, x_stoc_rel(i, sc):10:4 /);
         put 'extra term `' /; loop((i,sc)$iVc(i), put i.tl, sc.tl, par_extra_multiplicador(i,sc):10:4 / );
         put '--------------' / /;
putclose;

*# step 3
if( bundle_fx - bundle_fz >= bundle_sigma * bundle_delta,
*      # passo serio
         passo_serio := 1;
         bundle_fx_novo := bundle_fz;
         bundle_x_novo(i,sc)$dominio_multip(i,sc) := bundle_z(i,sc);
         if(sum((i,sc), power(bundle_y_novo(i,sc)-bundle_y(i,sc),2)) > 0,
                 bundle_gamma := 1/(1/bundle_gamma +  sum((i,sc), (bundle_x_novo(i,sc)-bundle_x(i,sc))*(bundle_y_novo(i,sc)-bundle_y(i,sc)))/sum((i,sc), power(bundle_y_novo(i,sc)-bundle_y(i,sc),2)));
         );
*      push!(K,iteracao+1)
*      push!(listDualBound,fxNovo)
*      push!(listSubgradient,y)
*      push!(listMultiplicadores,xNovo)
*      push!(listX,respostaOraculo[3])
*      @show "passo serio"
else
*      # passo nulo
         passo_serio := 0;
         bundle_fx_novo := bundle_fx;
         bundle_x_novo(i,sc)$dominio_multip(i,sc) := bundle_x(i,sc);
*bundle_z(i,sc);
);

*# step 4
*      #@show constraintCortes

if(sum(bundle_fe$bundle_fe_usado(bundle_fe), 1) < bundle_tamanho_maximo,
*    #push(feixe, (iteracao+1,y,e))
*    push!(B,(iteracao+1))
else        bundle_i1 := smin(bundle_fe$bundle_fe_usado(bundle_fe), ord(bundle_fe));
         bundle_i2 := smin(bundle_fe$(bundle_fe_usado(bundle_fe) and bundle_i1 <> ord(bundle_fe)), ord(bundle_fe));

         feixe_1(bundle_fe,i,sc)$(dominio_multip(i,sc) and ord(bundle_fe) = bundle_i2) := bundle_d(i,sc);
         feixe_2(bundle_fe)$(ord(bundle_fe) = bundle_i2) := bundle_epsilon;
         bundle_fe_usado(bundle_fe)$(ord(bundle_fe) = bundle_i1) := no;
);

*# step 5
* ja foi feita no passo serio do passo 4
*if (passo_serio = 1,
*         for fe in feixe
*                 fe[3] = fe[3] + fxNovo - fx + (fe[2]' * (x - xNovo))[1]
*         end
*);
if(passo_serio = 1,
*         feixe_2(bundle_fe)$bundle_fe_usado(bundle_fe) := bundle_fx - bundle_fz - sum((i,sc)$dominio_multip(i,sc), bundle_y_novo(i,sc)*(bundle_x(i,sc)-bundle_z(i,sc)));
         feixe_2(bundle_fe)$bundle_fe_usado(bundle_fe) :=  feixe_2(bundle_fe) + bundle_fx_novo - bundle_fx + sum((i,sc)$dominio_multip(i,sc), feixe_1(bundle_fe,i,sc)*(bundle_x(i,sc)-bundle_x_novo(i,sc)));
);
*bundle_ultimo_feixe_usado := bundle_ultimo_feixe_usado + 1;
*if(passo_serio = 0,
bundle_ultimo_feixe_usado := bundle_ultimo_feixe_usado + 1;
bundle_fe_usado(bundle_fe)$(ord(bundle_fe) = bundle_ultimo_feixe_usado) := yes;
feixe_1(bundle_fe,i,sc)$(ord(bundle_fe) = bundle_ultimo_feixe_usado and dominio_multip(i,sc)) := bundle_y_novo(i,sc);
feixe_2(bundle_fe)$(ord(bundle_fe) = bundle_ultimo_feixe_usado) := bundle_fx - bundle_fz - sum((i,sc)$dominio_multip(i,sc), bundle_y_novo(i,sc)*(bundle_x(i,sc) - bundle_z(i,sc)));

*);

*# step 6
*    # iteracao = iteracao + 1 e retorne ao step 1
bundle_x(i,sc)$dominio_multip(i,sc) := bundle_x_novo(i,sc);
bundle_fx = bundle_fx_novo;
bundle_y(i,sc)$dominio_multip(i,sc) := bundle_y_novo(i,sc);
multiplicadores(i,sc)$dominio_multip(i,sc) := bundle_x(i,sc);


*recalcula os tempos

         time_current = TimeElapsed - time_Start;
         if(time_current < time_limit,
                  Rel_lagrange.reslim = time_limit - time_current;
                 m_fixa_primeiro_estagio.reslim = min(50, time_limit - time_current);
         else
                 Rel_lagrange.reslim = 0;
                 m_fixa_primeiro_estagio.reslim = 0;
         );

         display UB, LB, x_stoc_rel, x_stoc_ori, subgradient, valor_fixado, multiplicadores;

         put Results;
         put '----------' /
             'Iteracao ', iteracao_grande /
             'Iterecao Bundle ', bundle_iterations  /
             'Time elapsed ', time_current  /
             'UB_iteracao ', UB_iteracao /
             'LB_iteracao ', LB_iteracao /
             'UB ', UB /
             'LB ', LB /
             'bundle ', bundle_FO.l  /
             'passo serio ', passo_serio /
             'bundle_erro ', bundle_erro /
             'gamma ', bundle_gamma  /
             'viavel ', local_viavel
             ;
         putclose;
*display iteracao_grande, bundle_iterations, passo_serio, bundle_gamma;
*display  bundle_FO.l, UB, LB, feixe_1, feixe_2;

);