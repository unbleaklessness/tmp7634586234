clear t;
clear Rd Rg Rp;
clear md Md mg Mg Mp;
clear mpj mpi mpk;
clear Id Jd Kd;
clear Ig Jg Kg;
clear Ip Jp Kp;
clear Gam;
clear phi3 phi4;
clear q3 q4 dq3 dq4;
clear b h1 h2 l1 l2;
clear q0 q1 q3 q4 dq0 dq1 dq3 dq4;

%%

syms t real;
syms Rd Rg Rp real;
syms md Md mg Mg Mp real;
syms mpj mpi mpk real;
syms Id Jd Kd real;
syms Ig Jg Kg real;
syms Ip Jp Kp real;
syms Gam real;
syms phi3 phi4 real;
syms q3 q4 dq3 dq4 real;
syms b h1 h2 l1 l2 real;
syms q0 q1 q3 q4 dq0 dq1 dq3 dq4 real;

%%

baz=[eye(3) -eye(3)];

mass=[md/4  (Md-md)/2  md/4 md/4 (Md-md)/2  md/4   ... 
          mg/4 (Mg-mg)/2 mg/4   mg/4  (Mg-mg)/2 mg/4];
%md/4  (Md-md)/2  md/4 (Md-md)/2 md/4 md/4 = диск гиродина
%mg/4 (Mg-mg)/2 mg/4 mg/4  (Mg-mg)/2 mg/4 = оснастка
mass=[mass mass mass mass mpj mpi mpk mpj mpi mpk];
%mpj mpk mpi mpj mpk mpi = условные массы рамы



giro=[Ry(Gam*t)*Rd*baz,Rg*baz]
girm=[Ry(-Gam*t)*Rd*baz,Rg*baz];
giro1=Rx((phi3+q3+t*dq3))*girm+[0;h2;l1];
giro2=Rx(-(phi4+q4+t*dq4))*giro+[0;h2;-l1];
giro3=giro+[l2;0;0];
giro4=girm+[-l2;0;0];
giroAll=[giro1,giro2,giro3,giro4]+[0;h1;0];
pend=Rp*baz+[0;b;0];
giroAll=[giroAll pend]
giroAll2=Ry(q0+t*dq0)*Rz(q1+t*dq1)*giroAll;

dgiroAll=diff(giroAll2,t);
dgiroAll0=subs(dgiroAll,t,0)

%подсчет момента импульса относительно z
giroAll20=subs(giroAll2,t,0) %координаты (условных) точек
croVec=cross(giroAll20,dgiroAll0);
momentumsz=simplify(sum([0 0 1]*(croVec.*mass)))
% for Sokolov 
% momentumsz =simplify(subs(momentumsz, {q1, dq1, phi3, phi4},{0,0, 0, 0}))
diff(momentumsz,dq3)

MomLin=linearof(momentumsz,[dq0 dq1 dq3 dq4 q0 q1 q3 q4]);
MomLin=subs(MomLin, {md*Rd^2, mg*Rg^2, Md*Rd^2, Mg*Rg^2 },{Id, Ig, Jd+Id/2, Jg+Ig/2});
MomLin=subs(MomLin, {mpi*Rp^2, mpj*Rp^2, mpk*Rp^2},{(Jp+Kp-Ip)/4,(Ip+Kp-Jp)/4,(Ip+Jp-Kp)/4}); 
MomLin=subs(MomLin, Mp*Rp^2,(Jp+Kp+Ip)/2); 
MomLin=subs(MomLin, {mpi, mpj,mpk},{(Jp+Kp-Ip)/(Jp+Kp+Ip)*Mp/2,(Ip+Kp-Jp)/(Jp+Kp+Ip)*Mp/2,(Ip+Jp-Kp)/(Jp+Kp+Ip)*Mp/2}); 
MomLin=simplify(expand(MomLin))  

%%

% Gam = 10000 * 2 * pi / 60;
% 
% Id = modelParameters.J3(1); % Disk inertia.
% Jd = modelParameters.J3(2);
% Kd = modelParameters.J3(1);
% Ig = modelParameters.J2(1); % Gyro box inertia.
% Jg = modelParameters.J2(2);
% Kg = modelParameters.J2(3);
% Ip = modelParameters.J1(3); % Body inertia.
% Jp = modelParameters.J1(1);
% Kp = modelParameters.J1(2);
% Md = modelParameters.m3; % Disk mass.
% Mg = modelParameters.m2; % Gyro box mass.
% Mp = modelParameters.m1; % Body mass.
% 
% b = 0.6;
% h1 = modelParameters.r9;
% h2 = modelParameters.r8 - modelParameters.r9;
% l1 = modelParameters.r6 / 2;
% l2 = modelParameters.r6 / 2;

%%

MomLin = subs( ...
    MomLin, ...
    [ ...
        Gam, ...
        Id, Jd, Kd, ...
        Ig, Jg, Kg, ...
        Ip, Jp, Kp, ...
        Md, Mg, Mp, ...
        b, ...
        h1, h2, l1, l2, ...
        phi3, phi4 ...
    ], ...
    [ ...
        10000 * 2 * pi / 60, ...
        modelParameters.J3(3), modelParameters.J3(2), modelParameters.J3(3), ...
        modelParameters.J2(3), modelParameters.J2(2), modelParameters.J2(1), ...
        modelParameters.J1(3), modelParameters.J1(1), modelParameters.J1(2), ...
        modelParameters.m3, modelParameters.m2, modelParameters.m1, ...
        0.6, ...
        modelParameters.r9, modelParameters.r8 - modelParameters.r9, modelParameters.r6 / 2, modelParameters.r6 / 2, ...
        15 / 180 * pi, 45 / 180 * pi ...
    ] ...
);

MomLin = double(MomLin);
MomLin = [MomLin(5:8), MomLin(1:4)];
% MomLin(5:6) = flip(MomLin(5:6));