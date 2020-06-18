function [A, B] = stateSpace(massMatrix, gravityDerivative, canonicalMassMatrix, nonConservativeMatrix)
    s = size(massMatrix(), 1);
    A = [zeros(s), eye(s); -massMatrix() \ gravityDerivative(), -massMatrix() \ (canonicalMassMatrix() + nonConservativeMatrix())];
    B = [zeros(s, s / 2); massMatrix() \ [zeros(s / 2); eye(s / 2)]];
end