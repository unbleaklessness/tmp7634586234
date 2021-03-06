timeStep = 0.001;
trajectoryTimeStep = 0.005;
parameters;

load('trajectory.mat');
load('trajectoryWalk.mat');
load('trajectoryToWalk.mat');

load('trajectoryToUpslope15.mat');
load('trajectoryUpslope15.mat');

% trajectoryWalk = trajectoryUpslope15;
% trajectoryToWalk = trajectoryToUpslope15;

%%

recalculate = false;
cachedSymbolsFileName1 = 'cachedSymbols1.mat';
cachedSymbolsFileName2 = 'cachedSymbols2.mat';
cachedSymbolsFileName3 = 'cachedSymbols3.mat';
if recalculate
    [M1, C1, Cs1, Cx1, G1, Gd1, AMd1, AMTd1, artefacts] = symbolsPitchYaw();
    save(cachedSymbolsFileName1, 'M1', 'C1', 'Cs1', 'Cx1', 'G1', 'Gd1', 'AMd1', 'AMTd1');
%     [M2, C2, Cs2, Cx2, G2, Gd2] = symbolsRoll();
%     save(cachedSymbolsFileName2, 'M2', 'C2', 'Cs2', 'Cx2', 'G2', 'Gd2');
%     [M3, C3, Cs3, Cx3, G3, Gd3] = symbolsPitch();
%     save(cachedSymbolsFileName3, 'M3', 'C3', 'Cs3', 'Cx3', 'G3', 'Gd3');
else
    load(cachedSymbolsFileName1);
    load(cachedSymbolsFileName2);
    load(cachedSymbolsFileName3);
end

fprintf('Done!\n');

%%

Mn1 = symbolicToNumerical(modelParameters, M1);
Cn1 = symbolicToNumerical(modelParameters, C1);
Csn1 = symbolicToNumerical(modelParameters, Cs1);
Cxn1 = symbolicToNumerical(modelParameters, Cx1);
Gn1 = symbolicToNumerical(modelParameters, G1);
Gdn1 = symbolicToNumerical(modelParameters, Gd1);
AMdn1 = symbolicToNumerical(modelParameters, AMd1);
AMTdn1 = symbolicToNumerical(modelParameters, AMTd1);

Mn2 = symbolicToNumerical(modelParameters, M2);
Cn2 = symbolicToNumerical(modelParameters, C2);
Csn2 = symbolicToNumerical(modelParameters, Cs2);
Cxn2 = symbolicToNumerical(modelParameters, Cx2);
Gn2 = symbolicToNumerical(modelParameters, G2);
Gdn2 = symbolicToNumerical(modelParameters, Gd2);

Mn3 = symbolicToNumerical(modelParameters, M3);
Cn3 = symbolicToNumerical(modelParameters, C3);
Csn3 = symbolicToNumerical(modelParameters, Cs3);
Cxn3 = symbolicToNumerical(modelParameters, Cx3);
Gn3 = symbolicToNumerical(modelParameters, G3);
Gdn3 = symbolicToNumerical(modelParameters, Gd3);

%%

poolSize = 4;
% pool = parpool(poolSize);

futures(1, 1:poolSize) = parallel.FevalFuture;
values = zeros(1, poolSize);

poolInput = [
    1 2
    3 4
    5 6
    7 8
];

for index = 1:poolSize
    futures(1, index) = parfeval(pool, @(x, y) x + y, 1, poolInput(index, 1), poolInput(index, 2));
end

for index = 1:poolSize
    values(1, index) = fetchOutputs(futures(1, index));
end

disp(values);

%%

modelParameters = rmfield(modelParameters, 'psihD');
modelParameters = rmfield(modelParameters, 'thet');
modelParameters = rmfield(modelParameters, 'alph1');
modelParameters = rmfield(modelParameters, 'alph2');

Mn1p = symbolicToNumerical(modelParameters, M1);
Cn1p = symbolicToNumerical(modelParameters, C1);
Csn1p = symbolicToNumerical(modelParameters, Cs1);
Cxn1p = symbolicToNumerical(modelParameters, Cx1);
Gn1p = symbolicToNumerical(modelParameters, G1);
Gdn1p = symbolicToNumerical(modelParameters, Gd1);
AMdn1p = symbolicToNumerical(modelParameters, AMd1);
AMTdn1p = symbolicToNumerical(modelParameters, AMTd1);

parameters;

alphaTableIndex = 1;
alphaCompareTable = [];
alphaCoefficientsTable = [];
alph1I = -170;
alph2I = 170;
nLinearizations = 100;
dAlpha = (abs(alph1I) + abs(alph2I)) / nLinearizations;
alphaRegion = dAlpha / 2;

tic

for index1 = alph1I:dAlpha:alph2I
    for index2 = alph1I:dAlpha:alph2I
        
        alph1 = index1 / 180 * pi;
        alph2 = index2 / 180 * pi;
        
        Mn1p0 = Mn1p(alph1, alph2);
        Csn1p0 = Csn1p(alph1, alph2);
        Cxn1p0 = Cxn1p(alph1, alph2);
        Gdn1p0 = Gdn1p();
%         AMdn1p0 = AMdn1p(alph1, alph2);
        AMTdn1p0 = AMTdn1p(alph1, alph2);
        
        [A1, B1] = stateSpace(Mn1p0, Gdn1p0, Csn1p0, Cxn1p0);

        Aw1 = A1(1:end - 2, 1:end - 2);
        Bw1 = A1(1:end - 2, [end - 1, end]);

        Aw1 = [Aw1 zeros(size(Aw1, 1), 1); zeros(1, size(Aw1, 2) + 1)]; Aw1(end, 4) = 1;
        Bw1 = [Bw1; zeros(1, size(Bw1, 2))];

        Aw1 = Aw1([1:2, 4:end], [1:2, 4:end]);
        Bw1 = Bw1([1:2, 4:end], :);

        MI = AMTdn1p0();
        MI = MI(1:end - 2);

        T = [
            1         0         0         0         0         0;
            0         1         0         0         0         0;
            0         0         1         0         0         0;
            0         0         0         1         0         0;
            0         0         0         0         1         0;
            MI;
        ];

        Aw1 = T * Aw1 * (T^-1);
        Bw1 = T * Bw1;

%         K1 = lqr(Aw1, Bw1, diag([20, 20, 5, 5, 5, 5]), diag([15, 15]));
        K1 = lqrd(Aw1, Bw1, diag([1, 1, 1, 10, 10, 1]), diag([50, 50]), 0.005);
        
        alphaCoefficientsTable = [alphaCoefficientsTable; K1(1, :), K1(2, :)];
        alphaCompareTable = [alphaCompareTable; index1 - alphaRegion, index1 + alphaRegion, index2 - alphaRegion, index2 + alphaRegion, alphaTableIndex]; % < >= < >= I
        alphaTableIndex = alphaTableIndex + 1;
        
        if rem(alphaTableIndex, 10) == 0
            fprintf('Iteration #%d.\n', alphaTableIndex);
        end
    end
end

toc

save('cachedAlphaCoefficientsTable.mat', 'alphaCoefficientsTable');
save('cachedAlphaCompareTable.mat', 'alphaCompareTable');

fprintf('Done!\n');

%%

modelParameters = rmfield(modelParameters, 'psihD');
modelParameters = rmfield(modelParameters, 'thet');
modelParameters = rmfield(modelParameters, 'alph1');
modelParameters = rmfield(modelParameters, 'alph2');

Mn1p = symbolicToNumerical(modelParameters, M1);
Cn1p = symbolicToNumerical(modelParameters, C1);
Csn1p = symbolicToNumerical(modelParameters, Cs1);
Cxn1p = symbolicToNumerical(modelParameters, Cx1);
Gn1p = symbolicToNumerical(modelParameters, G1);
Gdn1p = symbolicToNumerical(modelParameters, Gd1);
AMdn1p = symbolicToNumerical(modelParameters, AMd1);
AMTdn1p = symbolicToNumerical(modelParameters, AMTd1);

value1 = -0.4581;
% value2 = 0.0654;
value2 = -0.4581;

Mn1p0 = Mn1p(value1, value1, value1);
Csn1p0 = Csn1p(value1, value1, value2, value1);
Cxn1p0 = Cxn1p(value1, value1, value1);
Gdn1p0 = Gdn1p(value1);
AMTdn1p0 = AMTdn1p(value1, value1, value2, value1);

[A1, B1] = stateSpace(Mn1p0, Gdn1p0, Csn1p0, Cxn1p0);

Aw1 = A1(1:end - 2, 1:end - 2);
Bw1 = A1(1:end - 2, [end - 1, end]);

Aw1 = [Aw1 zeros(size(Aw1, 1), 1); zeros(1, size(Aw1, 2) + 1)]; Aw1(end, 4) = 1;
Bw1 = [Bw1; zeros(1, size(Bw1, 2))];

Aw1 = Aw1([1:2, 4:end], [1:2, 4:end]);
Bw1 = Bw1([1:2, 4:end], :);

MI = AMTdn1p0();
MI = MI(1:end - 2);

T = [
    1         0         0         0         0         0;
    0         1         0         0         0         0;
    0         0         1         0         0         0;
    0         0         0         1         0         0;
    0         0         0         0         1         0;
    MI;
];

Aw1 = T * Aw1 * (T^-1);
Bw1 = T * Bw1;

K1 = lqrd(Aw1, Bw1, diag([1, 1, 1, 10, 10, 1]), diag([50, 50]), 0.005);

%%

[A1, B1] = stateSpace(Mn1, Gdn1, Csn1, Cxn1);

Aw1 = A1(1:end - 2, 1:end - 2);
Bw1 = A1(1:end - 2, [end - 1, end]);

Aw1 = [Aw1 zeros(size(Aw1, 1), 1); zeros(1, size(Aw1, 2) + 1)]; Aw1(end, 4) = 1;
Bw1 = [Bw1; zeros(1, size(Bw1, 2))];

Aw1 = Aw1([1:2, 4:end], [1:2, 4:end]);
Bw1 = Bw1([1:2, 4:end], :);

MI = AMTdn1();
MI = MI(1:end - 2);

T = [
    1         0         0         0         0         0;
    0         1         0         0         0         0;
    0         0         1         0         0         0;
    0         0         0         1         0         0;
    0         0         0         0         1         0;
    MI;
];

Aw1 = T * Aw1 * (T^-1);
Bw1 = T * Bw1;

K1 = lqrd(Aw1, Bw1, diag([1, 1, 3, 1, 1, 1]), diag([6, 6]), 0.005);

%%

[A2, B2] = stateSpace(Mn2, Gdn2, Csn2, Cxn2);

Aw2 = A2(1:end - 1, 1:end - 1);
Bw2 = A2(1:end - 1, end);

Aw2 = [Aw2 zeros(size(Aw2, 1), 1); zeros(1, size(Aw2, 2) + 1)]; Aw2(end, 2) = 1;
Bw2 = [Bw2; zeros(1, size(Bw2, 2))];

%%

[A3, B3] = stateSpace(Mn3, Gdn3, Csn3, Cxn3);

Aw3 = A3(1:end - 1, 1:end - 1);
Bw3 = A3(1:end - 1, end);

Aw3 = [Aw3 zeros(size(Aw3, 1), 1); zeros(1, size(Aw3, 2) + 1)]; Aw3(end, 2) = 1;
Bw3 = [Bw3; zeros(1, size(Bw3, 2))];

%%

% psih thet alph2 psihD thetD alph2I | alph1D alph2D

% K1 = lqr(Aw1, Bw1, diag([1, 1, 1, 100, 100, 1]), diag([1, 1]));
% K1 = lqr(Aw1, Bw1, diag([10, 1, 1, 100, 1, 1]), diag([1, 1]));
% K1 = lqr(Aw1, Bw1, diag([1, 1, 2, 100, 1, 2]), diag([1, 1]));
K1 = lqr(Aw1, Bw1, diag([1, 1, 3, 1, 1, 1]), diag([6, 6]));
% K1 = lqr(Aw1, Bw1, diag([1, 100, 1, 1, 50, 1]), diag([1, 1]));
% K1 = lqr(Aw1, Bw1, diag([1, 1, 1, 100, 100, 1]), diag([1, 1]));
% K1 = lqr(Aw1, Bw1, diag([1, 1, 1, 1, 1, 1]), diag([1, 1]));

% K1(2, 3) = -5;
% K1(2, 6) = -1;

%%

K2 = lqr(Aw2, Bw2, diag([15, 1, 1, 5]), diag([15]));

%%

K3 = lqr(Aw3, Bw3, diag([1, 1, 1, 1]), diag([1]));

%%

clear MuJoCo;
if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine
end
% system('start mujoco_matlab gyroPendulum.xml mjkey.txt .')