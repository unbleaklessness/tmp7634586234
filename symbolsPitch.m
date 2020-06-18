function [M, C, Cs, Cx, G, Gd] = symbolsRoll()
    syms sigm sigmD sigmDD real; % Pendulum base angle (around X axis).
    syms alph3 alph3D alph3DD real; % Actuator angle.
    syms gam gamD gamDD real; % Disc angle.
    syms J1xx J1yy J1zz real; % Pendulum moment of inertia.
    syms J2xx J2yy J2zz real; % Gyro box moment of inertia.
    syms J3xx J3yy J3zz real; % Disc moment of inertia.
    syms m1 m2 m3 real; % Masses.
    syms c1x c1y c1z real; % Pendulum center of mass.
    syms c2x c2y c2z real; % Gyro box 1 center of mass.
    syms c3x c3y c3z real; % Disc 1 center of mass.
    syms c4x c4y c4z real; % Gyro box 2 center of mass.
    syms c5x c5y c5z real; % Disc 2 center of mass.
    syms c6x c6y c6z real; % Gyro box 3 center of mass.
    syms c7x c7y c7z real; % Disc 3 center of mass.
    syms c8x c8y c8z real; % Gyro box 4 center of mass.
    syms c9x c9y c9z real; % Disc 4 center of mass.
    syms g real; % Gravitational acceleration.

    % Generalized coordiantes:
    q = [sigm; alph3; gam];
    qD = [sigmD; alph3D; gamD];
    qDD = [sigmDD; alph3DD; gamDD];

    % Bodies moments of inertia.
    J(:, :, 1) = sym(diag([J1xx J1yy J1zz]));
    J(:, :, 2) = sym(diag([J2xx J2yy J2zz]));
    J(:, :, 3) = sym(diag([J3xx J3yy J3zz]));
    J(:, :, 4) = sym(diag([J2xx J2yy J2zz]));
    J(:, :, 5) = sym(diag([J3xx J3yy J3zz]));
    J(:, :, 6) = sym(diag([J2xx J2yy J2zz]));
    J(:, :, 7) = sym(diag([J3xx J3yy J3zz]));
    J(:, :, 8) = sym(diag([J2xx J2yy J2zz]));
    J(:, :, 9) = sym(diag([J3xx J3yy J3zz]));

    % Bodies rotations:
    R(:, :, 1) = simplify(Rx(sigm));
    R(:, :, 2) = simplify(R(:, :, 1) * Rz(pi));
    R(:, :, 3) = simplify(R(:, :, 2) * Rz(-gam));
    R(:, :, 4) = simplify(R(:, :, 1) * Rz(0));
    R(:, :, 5) = simplify(R(:, :, 4) * Rz(gam));
    R(:, :, 6) = simplify(R(:, :, 1) * Rz(3 * pi / 2) * Rx(alph3));
    R(:, :, 7) = simplify(R(:, :, 6) * Rz(gam));
    R(:, :, 8) = simplify(R(:, :, 1) * Rz(pi / 2) * Rx(alph3));
    R(:, :, 9) = simplify(R(:, :, 8) * Rz(-gam));

    % Bodies center of mass locations:
    L(:, 1) = R(:, :, 1) * [c1x; c1y; c1z];
    L(:, 2) = R(:, :, 1) * [c2x; c2y; c2z];
    L(:, 3) = R(:, :, 1) * [c3x; c3y; c3z];
    L(:, 4) = R(:, :, 1) * [c4x; c4y; c4z];
    L(:, 5) = R(:, :, 1) * [c5x; c5y; c5z];
    L(:, 6) = R(:, :, 1) * [c6x; c6y; c6z];
    L(:, 7) = R(:, :, 1) * [c7x; c7y; c7z];
    L(:, 8) = R(:, :, 1) * [c8x; c8y; c8z];
    L(:, 9) = R(:, :, 1) * [c9x; c9y; c9z];

    % Body masses:
    masses = [m1; m2; m3; m2; m3; m2; m3; m2; m3];

    % Skew-simmetric rotational matrices:
    s = sym(zeros(size(R)));
    for a = 1:size(R, 3)
        for b = 1:size(q, 1)
            s(:, :, a) = s(:, :, a) + simplify(diff(R(:, :, a), q(b))) * qD(b);
        end
        s(:, :, a) = simplify(R(:, :, a)' * s(:, :, a));
    end

    % Angular velocity of bodies:
    w = sym(zeros(size(s, 1), size(s, 3)));
    for a = 1:size(s, 3)
        w(:, a) = skewToAngular(s(:, :, a));
    end

    % Linear velocities of bodies:
    v = sym(zeros(size(L)));
    for a = 1:size(L, 2)
        for b = 1:size(q, 1)
            v(:, a) = v(:, a) + simplify(diff(L(:, a), q(b))) * qD(b);
        end
    end

    % Linear kinetic energy:
    TLinear = simplify(0.5 * trace(v' * v .* diag(masses)));

    % Rotational kinetic energy:
    TRotational = sym(0);
    for a = 1:size(w, 2)
        TRotational = TRotational + w(:, a)' * J(:, :, a) * w(:, a);
    end

    assume(J3xx == J3yy);
    TRotational = 0.5 * simplify(subs(TRotational, J3yy, J3xx));

    % Total kinetic energy:
    T = TLinear + TRotational;

    % Potential energy:
    U = simplify(g * [0, 0, 1] * L * masses);

    % Lagrangian:
    L = T - U;
    LEquations0 = Lagrange(L, reshape([q qD qDD]', 1, size(q, 1) + size(qD, 1) + size(qDD, 1)));
    LEquations = sym(size(q, 1));

    for a = 1:size(q, 1)
        LEquations(a, 1) = simplify(LEquations0(1, a));
    end
    disp('Simplification of Lagrange equations is finished.');

    % Inertia matrix:
    M = sym(zeros(size(q, 1)));
    for a = 1:size(q, 1)
        for b = 1:size(q, 1)
            M(a, b) = simplify(diff(LEquations(a), qDD(b)));
        end
    end
    disp('Inertia matrix is ready.');

    % Coriolis and gravitational forces:
    h = simplify(subs(LEquations, qDD, zeros(size(qDD, 1), 1)));

    % Components of manipulator equations:
    G = simplify(subs(h, qD, zeros(size(qD, 1), 1)));

    hC = subs(h, g, 0);

    % Coriolis matrix:
    C = sym(zeros(size(q, 1)));
    for a = 1:size(q, 1)
        for b = 1:size(q, 1)
            if a == b
                C(a, b) = simplify(diff(hC(a), qD(b)));
            else
                C(a, b) = simplify(diff(diff(hC(a), qD(b)) / 2, qD(b)) * qD(b));
            end
        end
    end

    % Canonical mass matrix:
    Cs = sym(zeros(size(q, 1)));
    for a = 1:size(q, 1)
        for b = 1:size(q, 1)
            for c = 1:size(q, 1)
                Cs(a, b) = Cs(a, b) + 0.5 * simplify(diff(M(a, b), q(c)) + diff(M(a, c), q(b)) - diff(M(c, b), q(a))) * qD(c);
            end
        end
    end
    Cs = simplify(Cs);

    assume(J3yy > 0);

    fprintf('Coriolis matrix correctness test: ');
    if simplify(hC - Cs * qD) == zeros(size(q))
        fprintf('success. \n');
    else
        fprintf('failed. \n');
    end

    % Derivative of mass matrix:
    Md = sym(zeros(size(q, 1)));
    for a = 1:size(q, 1)
        for b = 1:size(q, 1)
             for c = 1:size(q, 1)
                   Md(a, b) = Md(a, b) + simplify(diff(M(a, b), q(c)) * qD(c));
             end
        end
    end

    fprintf('Skew-simmetry test `Md - 2 * C`: ');
    if simplify(simplify(Md - 2 * Cs) + simplify(Md - 2 * Cs)') == zeros(size(Md))
        fprintf('success. \n');
    else
        fprintf('failed. \n');
    end

    % Non-convervative forces:
    ncf = Cs(1:end - 1, end) * qD(end);

    assume(gamDD == 0);
    q = [sigm; alph3];
    qD = [sigmD; alph3D];
    qDD = [sigmDD; alph3DD];

    M = M(1:size(q, 1), 1:size(q, 1));
    Cs = Cs(1:size(q, 1), 1:size(q, 1));
    C = C(1:size(q, 1), 1:size(q, 1));
    G = G(1:size(q, 1), 1);

    % Matrix of non-conservative forces:
    Cx = sym(zeros(size(q, 1)));
    for a = 1:size(q, 1)
        for b = 1:size(q, 1)
            Cx(a, b) = simplify(diff(ncf(a), qD(b)));
        end
    end

    % Gravity derivative:
    Gd = simplify(jacobian(G, q'));

    qI = reshape([q qD], size(q, 1) + size(qD, 1), 1);
end