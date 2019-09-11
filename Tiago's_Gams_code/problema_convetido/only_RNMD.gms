$offorder

* scalares de tempo
Scalar tcomp, texec, telapsed;


* Indices das vari�veis x
*Sets i;
$include "C:\Users\tiago.andrade\Desktop\problems QCQP\problems QCQP\problema_convetido\teste_sets.inc";
alias(i,j);

* Indice de precis�o
Set l /1*100/;

* Indice de fun��es
*Set r;
alias(r,r1,r2);
SET re_FO(r) /0/;

* Incide representando os pares i,j de vari�veis que aparecem nas fun��es r
Set BL(r,i,j);




Scalar p;
p = -20;

Parameter LB_x(i), UB_x(i);


Parameter a(r,i,j);




Parameter b(r,i);


Parameter c(r);


Parameter r_dsdp(r,i);

Parameter r_dd(r,i);

display r, l;

$include "C:\Users\tiago.andrade\Desktop\problems QCQP\problems QCQP\problema_convetido\teste.inc";

$include "C:\Users\tiago.andrade\Desktop\problems QCQP\problems QCQP\problema_convetido\r_DSDP.inc";
$include "C:\Users\tiago.andrade\Desktop\problems QCQP\problems QCQP\problema_convetido\r_DD.inc";

Positive Variable x(i);
Positive Variable w(i);
Binary Variable z(i,l);
Positive Variable hat_x(i,l);
Positive Variable delta_x(i);
Positive Variable v(i);
variable FO;

Equations
R_FO
Main
Def_w
Def_x
UB_hat_x
LB_hat_x
UB_prod
LB_prod
MC_1
MC_2
MC_3
MC_4

MC_w_1
MC_w_2
MC_w_3

LB_w
;

Equations
R_FO_Or
R_FO_rel
Main_Or
R_FO_decom
Main_decom
;

*R_FO_rel(r)$(re_FO(r))..
*         sum((i,j)$BL(r,i,j),a(r,i,j)*w(i)) + sum(i,b(r,i)*x(i)) =E= FO;

R_FO_Or(r)$(re_FO(r))..
         sum((i,j)$BL(r,i,j),a(r,i,j)*x(i)*x(j)) + sum(i,b(r,i)*x(i)) =E= FO;

R_FO_decom(r)$(re_FO(r))..
         sum((i,j)$BL(r,i,j),a(r,i,j)*x(i)*x(j)) + sum(i,b(r,i)*x(i)) + sum(i, r_dd(r,i)*power(x(i),2)) - sum(i, r_dd(r,i)*w(i)) =E= FO;

Main_Or(r)$(not re_FO(r))..
         sum((i,j)$BL(r,i,j),a(r,i,j)*x(i)*x(j)) + sum(i,b(r,i)*x(i)) + c(r) =L= 0;

Main_decom(r)$(not re_FO(r))..
         sum((i,j)$BL(r,i,j),a(r,i,j)*x(i)*x(j)) + sum(i,b(r,i)*x(i)) + c(r) + sum(i, r_dd(r,i)*power(x(i),2)) - sum(i, r_dd(r,i)*w(i)) =L= 0;

parameter mult(r);
mult(r) = 0;

*R_FO(r)$(re_FO(r))..
*         sum((i,j)$BL(r,i,j),a(r,i,j)*w(i,j)) + sum(i,b(r,i)*x(i)) + sum(r1$(not re_FO(r1)), mult(r1)*( sum((i,j)$BL(r1,i,j),a(r1,i,j)*w(i,j)) + sum(i,b(r1,i)*x(i)) + c(r1))) =E= FO;

*Main(r)$(not re_FO(r))..
*         sum((i,j)$BL(r,i,j),a(r,i,j)*w(i,j)) + sum(i,b(r,i)*x(i)) + c(r) =L= 0;

Def_w(i)..
         w(i) =E= (x.up(i)-x.lo(i))*sum(l$(ord(l)<=-p),2**(-ord(l))*hat_x(i,l)) + (x.up(i)-x.lo(i))*v(i) + x(i)*x.lo(i);

Def_x(i)..
         x(i) =E= (x.up(i)-x.lo(i))*sum(l$(ord(l)<=-p),2**(-ord(l))*z(i,l)) + (x.up(i)-x.lo(i))*delta_x(i) + x.lo(i);

UB_hat_x(i,l)$(ord(l)<=-p)..
         hat_x(i,l) =L= x.up(i)*z(i,l);

LB_hat_x(i,l)$(ord(l)<=-p)..
         hat_x(i,l) =G= x.lo(i)*z(i,l);

UB_prod(i,l)$(ord(l)<=-p)..
         x(i) - hat_x(i,l) =L= x.up(i)*(1-z(i,l));

LB_prod(i,l)$(ord(l)<=-p)..
         x(i) - hat_x(i,l) =G= x.lo(i)*(1-z(i,l));

MC_1(i)..
         v(i) =G= delta_x(i)*x.lo(i);

MC_2(i)..
         v(i) =L= delta_x(i)*x.up(i);

MC_3(i)..
         v(i) =G= (2**p)*(x(i)-x.up(i)) + delta_x(i)*x.up(i);

MC_4(i)..
         v(i) =L= (2**p)*(x(i)-x.lo(i)) + delta_x(i)*x.lo(i);

MC_w_1(i)..
         w(i) =L= x.up(i)*x(i) + x.lo(i)*x(i) - x.up(i)*x.lo(i);

MC_w_2(i)..
         w(i) =G= 2*x.up(i)*x(i) - x.up(i)**2;

MC_w_3(i)..
         w(i) =G= 2*x.lo(i)*x(i) - x.lo(i)**2;

LB_w(i)..
         w(i) =G= power(x(i),2);

* Bounds das vari�veis
delta_x.up(i) = 2**p;
x.lo(i) = LB_x(i);
x.up(i) = UB_x(i);

model m /
R_FO
*Main
Def_w
Def_x
UB_hat_x
LB_hat_x
UB_prod
LB_prod
MC_1
MC_2
MC_3
MC_4
/;
*solve m min FO us MIP;

model Ori /
R_FO_Or
Main_Or
/;

model Rel /
R_FO_rel
Main
Def_w
Def_x
UB_hat_x
LB_hat_x
UB_prod
LB_prod
MC_1
MC_2
MC_3
MC_4
/;

model Decom /
R_FO_decom
Main_decom
Def_w
Def_x
UB_hat_x
LB_hat_x
UB_prod
LB_prod
MC_1
MC_2
MC_3
MC_4

MC_w_1
MC_w_2
MC_w_3

LB_w
/;

scalar best /-1000/;
scalar iter /0/;
scalar step /1/;
Parameter melhor_multiplicador(r);
*7,28
scalar stop /0/;
scalar mod /0/;

parameter subg(r);
parameter mult_old(r);
Parameter s_subg(r);
s_subg(r) = 0;
subg(r)$(ord(r)<card(r)) = 10;

scalar p_aux;
scalar Iter_O /0/;
scalar Iter_i /0/;
scalar stop_2 /0/;
scalar iter_tot /0/;
scalar UB;
scalar LB;
UB = 10**8;
LB = -UB;
scalar FO_atual;
*option MIP = GUROBI;
option MIP = CPLEX;
option NLP = baron;
option miqcp = cplex;
option qcp = conopt;
option optcr = 0.0001;
stop = 0;
p = -6;
delta_x.up(i) = 2**p;

scalar time_Start, time_current, time_limit;
time_limit = 3600.0;
time_Start = TimeElapsed;
Decom.reslim = time_limit

*solve ori min FO us nlp
solve Decom min FO us miqcp
display FO.l
solve Ori min FO us qcp
display FO.l

*display mult, subg, mod, LB, UB, p, iter_O, iter_i;
*display UB, LB, p, iter_i, iter_tot, iter_O, iter_i, telapsed;

$ontext
file results /C:\Users\TA\Desktop\problems QCQP\problema_convetido\results.csv/;
put results;
         put telapsed /;
         put LB:10:4 /;
         put UB:10:4 /;
         put iter_i /;
         put iter_o /;
         put iter_tot /;
         put p;
putclose;
$offtext

$ontext
while(not stop,
         iter = iter + 1;
*         step = 0.1;
         solve m min FO us MIP;

         subg(r1)$(ord(r1)<card(r1)) = sum((i,j)$BL(r1,i,j),a(r1,i,j)*w.l(i,j)) + sum(i,b(r1,i)*x.l(i)) + c(r1);
         s_subg(r1) = 0.3*s_subg(r1) + 0.7*subg(r1);
         mod = (sum(r1$(ord(r1)<card(r1)), s_subg(r1)*s_subg(r1)))**(1/2);
         display mod, subg;
*         subg(r1) = subg(r1)/mod;
         step = (7049.25 - FO.l)/(mod**2);
         display iter, step, mult, mod, FO.l;
         mult(r1)$(ord(r1)<card(r1)) = max(0,mult(r1) + step*s_subg(r1));

         display subg, mult;

         if(FO.l > best,
                 best = FO.l;
                 melhor_multiplicador(r) = mult(r);
         );

         if(iter > 2000,
                 stop = 1;
         );
);

display best, melhor_multiplicador;
$offtext
