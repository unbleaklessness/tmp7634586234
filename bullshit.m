syms t real;
syms Rd Rg Rp real;
syms md Md mg Mg Mp real;
syms mpj mpi mpk real;
syms Id Jd Kd real;
syms Ig Jg Kg real;
syms Ip Jp Kp real;

masses = [
    md / 4, (Md - md) / 2, md / 4, md / 4, (Md - md) / 2, md / 4, ...
    mg / 4, (Mg - mg) / 2, mg / 4, mg / 4, (Mg - mg) / 2, mg / 4
];
% masses = [masses masses masses masses mpj mpi mpk mpj mpi mpk];
masses = [masses masses masses masses mpi mpj mpk mpi mpj mpk];

basis = [eye(3), -eye(3)];

giroA = [Rz(gam * t) * Rd * basis, Rg * basis];
giroB = [Rz(-gam * t) * Rd * basis, Rg * basis];

giro1 = Rz(pi) * Rx(nu1 + alph1 + t * alph1D) * giroB + [0; c2y; c2z];
giro2 = Rz(0) * Rx(nu2 + alph2 + t * alph2D) * giroA + [0; -c2y; c2z];
giro3 = Rz(3 * pi / 2) * giroA + [-c6x; 0; c6z];
giro4 = Rz(pi / 2) * giroB + [c6x; 0; c6z];

pendulum = Rp * basis + [0; 0; c1z];

giroAll1 = [giro1, giro2, giro3, giro4, pendulum];
giroAll2 = Rz(psih + t * psihD) * Ry(thet + t * thetD) * giroAll1;

giroAllD = diff(giroAll2, t);
giroAllD0 = subs(giroAllD, t, 0);

giroAll20 = subs(giroAll2, t, 0);
crossVector = cross(giroAll20, giroAllD0);
momentumsZ = simplify(sum([0 1 0] * (crossVector .* masses)));

MI = Linearize(momentumsZ, [psih thet alph1 alph2 psihD thetD alph1D alph2D]);
MI = subs(MI, {md * Rd^2, mg * Rg^2, Md * Rd^2, Mg * Rg^2 }, {Id, Ig, Jd + Id / 2, Jg + Ig / 2});
MI = subs(MI, {mpi * Rp^2, mpj * Rp^2, mpk * Rp^2}, {(Jp + Kp - Ip) / 4, (Ip + Kp - Jp) / 4, (Ip + Jp - Kp) / 4}); 
MI = subs(MI, Mp * Rp^2, (Jp + Kp + Ip) / 2); 
MI = subs(MI, {mpi, mpj, mpk}, {(Jp + Kp - Ip) / (Jp + Kp + Ip) * Mp / 2, (Ip + Kp - Jp) / (Jp + Kp + Ip) * Mp / 2, (Ip + Jp - Kp) / (Jp + Kp + Ip) * Mp / 2}); 
MI = simplify(expand(MI));

AMd = MI;

modelParameters.Id = modelParameters.J3(1); % Disk inertia.
modelParameters.Jd = modelParameters.J3(2);
modelParameters.Kd = modelParameters.J3(1);

modelParameters.Ig = modelParameters.J2(1); % Gyro box inertia.
modelParameters.Jg = modelParameters.J2(2);
modelParameters.Kg = modelParameters.J2(3);

modelParameters.Ip = modelParameters.J1(3); % Body inertia.
modelParameters.Jp = modelParameters.J1(1);
modelParameters.Kp = modelParameters.J1(2);

modelParameters.Md = modelParameters.m3; % Disk mass.
modelParameters.Mg = modelParameters.m2; % Gyro box mass.
modelParameters.Mp = modelParameters.m1; % Body mass.

function C = Linearize(EQL, qD)
    C = sym(7);
    qD0 = zeros(size(qD));
    for j = 1:length(qD)
        C(j) = diff(EQL, qD(j));
        C(j) = subs(C(j), qD, qD0);
        C(j) = simplify(expand(C(j)));
    end
end

