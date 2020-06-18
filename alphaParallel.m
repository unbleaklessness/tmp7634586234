testValue = -22.5;
% testValue = 7.6;

% testResult = floor((testValue + 30) / 7.5000) + 1;
testResult = floor(((testValue + 30) - (-30 + 30)) / 7.5000) + 1;

disp(testResult);

%%

exception = [];

try 
    nWorkers = 4;

    if isempty(gcp('nocreate'))
        pool = parpool(nWorkers);
    end

    futures(1, 1:nWorkers) = parallel.FevalFuture;
    
    % PSIHD x THET x ALPH1 x ALPH2 x COEFFICIENT x ICOEFFICIENT

%     splittedVariable = [ 
%         -270 270 % PSIHD.
%     ];

    splittedVariable = [ 
        -30 30 % PSIHD.
    ];

    unsplittedVariable = splittedVariable;

%     wholeVariables = [
%         -90 90 % THET.
%         -90 90 % ALPH1.
%         -90 90 % ALPH2.
%     ];

    wholeVariables = [
        -30 30 % THET.
        -30 30 % ALPH1.
        -30 30 % ALPH2.
    ];

    index = 1;
    splitStep = (abs(splittedVariable(1, 1)) +  abs(splittedVariable(1, 2))) / nWorkers;

    for splitPart = splittedVariable(1, 1) : splitStep : splittedVariable(1, 2) - splitStep
        
        splittedVariable(index, 1) = splitPart;
        splittedVariable(index, 2) = splitPart + splitStep;
        
        index = index + 1;
    end

%     variablesShift = unsplittedVariable + abs(min(unsplittedVariable));
%     variablesShift = [variablesShift; wholeVariables + abs(min(wholeVariables, [], 2))];
    
    variablesShift = abs(min(unsplittedVariable));
    variablesShift = [variablesShift; abs(min(wholeVariables, [], 2))];
    
    shiftedVariables = unsplittedVariable(:, 1) + abs(min(unsplittedVariable(:, 1)));
    shiftedVariables = [shiftedVariables; wholeVariables(:, 1) + abs(min(wholeVariables(:, 1), [], 2))];

    for index = 1 : nWorkers
        futures(1, index) = parfeval(@alphaParallelF, 1, ...
            [splittedVariable(index, :); wholeVariables], nWorkers, ...
            modelParameters, M1, Cs1, Cx1, Gd1, AMTd1 ...
        );
    end

    results = cell(1, nWorkers);

    for index = 1 : nWorkers
        [futureIndex, result] = fetchNext(futures);
        results{futureIndex} = result;
    end
    
    linearizationPoints = [];
    coefficientsTensor = [];
    variablesDeltas = [];
    
    nLinearizations = 0;
    
    for index = 1 : nWorkers
        coefficientsTensor = cat(1, coefficientsTensor, results{index}.coefficientsTensor);
        linearizationPoints = cat(1, linearizationPoints, results{index}.linearizationPoints);
        variablesDeltas = cat(1, variablesDeltas, results{index}.variablesDeltas');
        nLinearizations = results{index}.nLinearizations;
    end
    
    variablesDeltas = variablesDeltas(1, :);

    save('coefficientsTensor.mat', 'coefficientsTensor');
    
catch exception
end

delete(pool);
clear pool;
clear futures;

if ~isempty(exception)
    rethrow(exception);
end

%%

function result = alphaParallelF(variablesRanges, nWorkers, modelParameters, M1, Cs1, Cx1, Gd1, AMTd1)

    nLinearizations = 8;

    assert(size(variablesRanges, 1) == 4);
    assert(rem(nLinearizations, nWorkers) == 0);

    modelParameters = rmfield(modelParameters, 'psihD');
    modelParameters = rmfield(modelParameters, 'thet');
    modelParameters = rmfield(modelParameters, 'alph1');
    modelParameters = rmfield(modelParameters, 'alph2');

    Mn1p = symbolicToNumerical(modelParameters, M1);
    Csn1p = symbolicToNumerical(modelParameters, Cs1);
    Cxn1p = symbolicToNumerical(modelParameters, Cx1);
    Gdn1p = symbolicToNumerical(modelParameters, Gd1);
    AMTdn1p = symbolicToNumerical(modelParameters, AMTd1);

    linearizationPoints = zeros((nLinearizations / nWorkers) * nLinearizations * nLinearizations * nLinearizations, 4);
    coefficientsTensor = zeros(nLinearizations / nWorkers, nLinearizations, nLinearizations, nLinearizations, 12);
    variablesDeltas = abs(variablesRanges(1, 1) - variablesRanges(1, 2)) / (nLinearizations / nWorkers);
    variablesDeltas = [variablesDeltas; abs(variablesRanges(2:end, 1) - variablesRanges(2:end, 2)) / nLinearizations];
    variablesRegions = variablesDeltas / 2;

    linearizationIndex = 1;
    
    index2 = 1;
    for value2 = variablesRanges(2, 1) + variablesRegions(2, 1) : variablesDeltas(2, 1) : variablesRanges(2, 2) -  variablesRegions(2, 1)
        index3 = 1;
        for value3 = variablesRanges(3, 1) + variablesRegions(3, 1) : variablesDeltas(3, 1) : variablesRanges(3, 2) -  variablesRegions(3, 1)
            index4 = 1;
            for value4 = variablesRanges(4, 1) + variablesRegions(4, 1) : variablesDeltas(4, 1) : variablesRanges(4, 2) -  variablesRegions(4, 1)
                index1 = 1;
                for value1 = variablesRanges(1, 1) + variablesRegions(1, 1) : variablesDeltas(1, 1) : variablesRanges(1, 2) -  variablesRegions(1, 1)

                    psihD = deg2rad(value1);
                    thet = deg2rad(value2);
                    alph1 = deg2rad(value3);
                    alph2 = deg2rad(value4);
                    
                    linearizationPoints(linearizationIndex, 1) = psihD;
                    linearizationPoints(linearizationIndex, 2) = thet;
                    linearizationPoints(linearizationIndex, 3) = alph1;
                    linearizationPoints(linearizationIndex, 4) = alph2;

                    Mn1p0 = Mn1p(alph1, alph2, thet);
                    Csn1p0 = Csn1p(alph1, alph2, psihD, thet);
                    Cxn1p0 = Cxn1p(alph1, alph2, thet);
                    Gdn1p0 = Gdn1p(thet);
                    AMTdn1p0 = AMTdn1p(alph1, alph2, psihD, thet);

                    [A1, ~] = stateSpace(Mn1p0, Gdn1p0, Csn1p0, Cxn1p0);

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

                    K1 = lqrd(Aw1, Bw1, diag([1, 1, 1, 20, 20, 1]), diag([50, 50]), 0.005);
%                     K1 = lqrd(Aw1, Bw1, diag([1, 1, 1, 10, 10, 1]), diag([20, 20]), 0.005);
                    K1 = [K1(1, :) K1(2, :)];

                    for index5 = 1 : size(K1, 2)
                        coefficientsTensor(index1, index2, index3, index4, index5) = K1(1, index5);
                    end
                    
                    linearizationIndex = linearizationIndex + 1;
                    
                    index1 = index1 + 1;
                end
                index4 = index4 + 1;
            end
            index3 = index3 + 1;
        end
        index2 = index2 + 1;
    end
    
    result.coefficientsTensor = coefficientsTensor;
    result.linearizationPoints = linearizationPoints;
    result.variablesDeltas = variablesDeltas;
    result.nLinearizations = nLinearizations;
end

