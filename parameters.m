modelParameters.g = 9.81; % Gravitational acceleration.

% modelParameters.r1 = 0.5; % Rod length.
% modelParameters.r2 = 0.1; % Disc radius.
% modelParameters.r3 = 0.008; % Disc height.
% modelParameters.r4 = 0.24; % Gyro box XY size.
% modelParameters.r5 = modelParameters.r3; % Gyro box height.
modelParameters.r6 = 0.25; % Half distance between gyros along Y direction.
modelParameters.r7 = modelParameters.r6; % Half distance between gyros along X direction.
modelParameters.r8 = 0.5215 + 0.5; % Upper gyro pair Z position.
modelParameters.r9 = 0.3065 + 0.5; % Lower gyro pair Z position.
% modelParameters.r10 = 0.0881; % Distance between legs.
% modelParameters.r11 = 0.25; % Thight length.

modelParameters.m2 = 2.458; % Gyro box mass.
modelParameters.m3 = 2.011; % Disc mass.
% modelParameters.m4 = 1.59; % Thigh mass.
% modelParameters.m5 = 0.75; % Shin mass.
% modelParameters.m6 = 14.9451; % Rod mass.
% modelParameters.m1 = modelParameters.m6 + (modelParameters.m4 + modelParameters.m5) * 2; % Total pendulum mass.
modelParameters.m1 = 19.6251;

% modelParameters.c2 = [0 modelParameters.r6 (modelParameters.r8 + modelParameters.r3 / 2)]; % Gyro box 1 center of mass.
% modelParameters.c2x = modelParameters.c2(1);
% modelParameters.c2y = modelParameters.c2(2);
% modelParameters.c2z = modelParameters.c2(3);

% modelParameters.c3 = [0 modelParameters.r6 (modelParameters.r8 + modelParameters.r5 / 2)]; % Disc 1 center of mass.
% modelParameters.c3x = modelParameters.c3(1);
% modelParameters.c3y = modelParameters.c3(2);
% modelParameters.c3z = modelParameters.c3(3);

% modelParameters.c4 = [0 -modelParameters.r6 (modelParameters.r8 + modelParameters.r3 / 2)]; % Gyro box 2 center of mass.
% modelParameters.c4x = modelParameters.c4(1);
% modelParameters.c4y = modelParameters.c4(2);
% modelParameters.c4z = modelParameters.c4(3);

% modelParameters.c5 = [0 -modelParameters.r6 (modelParameters.r8 + modelParameters.r5 / 2)]; % Disc 2 center of mass.
% modelParameters.c5x = modelParameters.c5(1);
% modelParameters.c5y = modelParameters.c5(2);
% modelParameters.c5z = modelParameters.c5(3);

% modelParameters.c6 = [-modelParameters.r7 0 (modelParameters.r9 + modelParameters.r3 / 2)]; % Gyro box 3 center of mass.
% modelParameters.c6x = modelParameters.c6(1);
% modelParameters.c6y = modelParameters.c6(2);
% modelParameters.c6z = modelParameters.c6(3);

% modelParameters.c7 = [-modelParameters.r7 0 (modelParameters.r9 + modelParameters.r5 / 2)]; % Disc 3 center of mass.
% modelParameters.c7x = modelParameters.c7(1);
% modelParameters.c7y = modelParameters.c7(2);
% modelParameters.c7z = modelParameters.c7(3);

% modelParameters.c8 = [modelParameters.r7 0 (modelParameters.r9 + modelParameters.r3 / 2)]; % Gyro box 4 center of mass.
% modelParameters.c8x = modelParameters.c8(1);
% modelParameters.c8y = modelParameters.c8(2);
% modelParameters.c8z = modelParameters.c8(3);

% modelParameters.c9 = [modelParameters.r7 0 (modelParameters.r9 + modelParameters.r5 / 2)]; % Disc 4 center of mass.
% modelParameters.c9x = modelParameters.c9(1);
% modelParameters.c9y = modelParameters.c9(2);
% modelParameters.c9z = modelParameters.c9(3);

modelParameters.c2 = [0 modelParameters.r6 modelParameters.r8]; % Gyro box 1 center of mass.
modelParameters.c2x = modelParameters.c2(1);
modelParameters.c2y = modelParameters.c2(2);
modelParameters.c2z = modelParameters.c2(3);

modelParameters.c3 = [0 modelParameters.r6 modelParameters.r8]; % Disc 1 center of mass.
modelParameters.c3x = modelParameters.c3(1);
modelParameters.c3y = modelParameters.c3(2);
modelParameters.c3z = modelParameters.c3(3);

modelParameters.c4 = [0 -modelParameters.r6 modelParameters.r8]; % Gyro box 2 center of mass.
modelParameters.c4x = modelParameters.c4(1);
modelParameters.c4y = modelParameters.c4(2);
modelParameters.c4z = modelParameters.c4(3);

modelParameters.c5 = [0 -modelParameters.r6 modelParameters.r8]; % Disc 2 center of mass.
modelParameters.c5x = modelParameters.c5(1);
modelParameters.c5y = modelParameters.c5(2);
modelParameters.c5z = modelParameters.c5(3);

modelParameters.c6 = [-modelParameters.r7 0 modelParameters.r9]; % Gyro box 3 center of mass.
modelParameters.c6x = modelParameters.c6(1);
modelParameters.c6y = modelParameters.c6(2);
modelParameters.c6z = modelParameters.c6(3);

modelParameters.c7 = [-modelParameters.r7 0 modelParameters.r9]; % Disc 3 center of mass.
modelParameters.c7x = modelParameters.c7(1);
modelParameters.c7y = modelParameters.c7(2);
modelParameters.c7z = modelParameters.c7(3);

modelParameters.c8 = [modelParameters.r7 0 modelParameters.r9]; % Gyro box 4 center of mass.
modelParameters.c8x = modelParameters.c8(1);
modelParameters.c8y = modelParameters.c8(2);
modelParameters.c8z = modelParameters.c8(3);

modelParameters.c9 = [modelParameters.r7 0 modelParameters.r9]; % Disc 4 center of mass.
modelParameters.c9x = modelParameters.c9(1);
modelParameters.c9y = modelParameters.c9(2);
modelParameters.c9z = modelParameters.c9(3);

% modelParameters.leftThighC = [0 0 -0.2214] + [0 (modelParameters.r10 / 2) 0];
% modelParameters.leftShinC = [0 0 -0.19469] + [0 (modelParameters.r10 / 2) 0] + [0 0 -modelParameters.r11];
% modelParameters.rightThighC = [0 0 -0.2214] + [0 (-modelParameters.r10 / 2) 0];
% modelParameters.rightShinC = [0 0 -0.19469] + [0 (-modelParameters.r10 / 2) 0] + [0 0 -modelParameters.r11];

% modelParameters.leftThighJ = [0.008704007 0.007703296 0.002209976];
% modelParameters.leftShinJ = [0.006216238 0.006185340 0.000584330];
% modelParameters.rightThighJ = modelParameters.leftThighJ;
% modelParameters.rightShinJ = modelParameters.leftShinJ;

% modelParameters.rodeC = [0 0 (modelParameters.r1 / 1.2)];
% modelParameters.rodeJ = [0.679450 0.7101237 0.475422];

modelParameters.c1 = [0 0 0.6];
% modelParameters.c1 = ( ...
%     modelParameters.rodeC * modelParameters.m6 + ...
%     modelParameters.leftThighC * modelParameters.m4 + ...
%     modelParameters.leftShinC * modelParameters.m5 + ...
%     modelParameters.rightThighC * modelParameters.m4 + ...
%     modelParameters.rightShinC * modelParameters.m5) / modelParameters.m1;
modelParameters.c1x = modelParameters.c1(1);
modelParameters.c1y = modelParameters.c1(2);
modelParameters.c1z = modelParameters.c1(3);


modelParameters.J2 = [0.0085 0.0106 0.0121];
% modelParameters.J2 = [0.0134496 0.008588196 0.01483955]; % Gyro box moment of inertia.
modelParameters.J2xx = modelParameters.J2(1);
modelParameters.J2yy = modelParameters.J2(2);
modelParameters.J2zz = modelParameters.J2(3);

modelParameters.J3 = [0.0049 0.0049 0.0098];
% modelParameters.J3 = [0.004934016 0.004934016 0.009771652]; % Disc moment of inertia.
modelParameters.J3xx = modelParameters.J3(1);
modelParameters.J3yy = modelParameters.J3(2);
modelParameters.J3zz = modelParameters.J3(3);

modelParameters.J1 = [1.7231 1.7247 0.5014];
% modelParameters.J1 = ...
%     modelParameters.rodeJ + modelParameters.m6 * norm(modelParameters.c1 - modelParameters.rodeC)^2 + ...
%     modelParameters.leftThighJ + modelParameters.m4 * norm(modelParameters.c1 - modelParameters.leftThighC)^2 + ...
%     modelParameters.leftShinJ + modelParameters.m5 * norm(modelParameters.c1 - modelParameters.leftShinC)^2 + ...
%     modelParameters.rightThighJ + modelParameters.m4 * norm(modelParameters.c1 - modelParameters.rightThighC)^2 + ...
%     modelParameters.rightShinJ + modelParameters.m5 * norm(modelParameters.c1 - modelParameters.rightShinC)^2; % Moment of inertia of the pendulum.
modelParameters.J1xx = modelParameters.J1(1);
modelParameters.J1yy = modelParameters.J1(2);
modelParameters.J1zz = modelParameters.J1(3);

modelParameters.alphaLimit = 3; % Actuator limit.

%% Linearization point:

modelParameters.nu1 = 35 / 180 * pi;
modelParameters.nu2 = 15 / 180 * pi;

modelParameters.psih = 0 / 180 * pi;
modelParameters.psihD = 0;

modelParameters.thet = 0 / 180 * pi;
modelParameters.thetD = 0;

modelParameters.sigm = 0 / 180 * pi;
modelParameters.sigmD = 0;

modelParameters.alph1 = 0 / 180 * pi;
modelParameters.alph1D = 0;

modelParameters.alph2 = 0 / 180 * pi;
modelParameters.alph2D = 0;

modelParameters.alph3 = 0 / 180 * pi;
modelParameters.alph3D = 0;

modelParameters.gam = 0;
modelParameters.gamD = 10000 * 2 * pi / 60; % Disc speed.

% modelParameters.lean = 0.0881^2 * (1.59 + 0.75);
% modelParameters.lean = 0.0881 / 2;
modelParameters.lean = 0;