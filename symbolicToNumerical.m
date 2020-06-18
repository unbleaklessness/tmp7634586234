function numericalExpression = symbolicToNumerical(parameters, symbolicExpression)

    fields = fieldnames(parameters)';

    symbols = sym(zeros(1, size(fields, 2)));
    for index = 1:size(fields, 2)
        symbols(1, index) = sym(fields{1, index});
    end

    parametersAsCells = struct2cell(parameters)';
    parametersAsArray = zeros(1, size(parametersAsCells, 2));
    for index = 1:size(parametersAsCells, 2)
        element = parametersAsCells{1, index};
        parametersAsArray(1, index) = element(1, 1);
    end

    digits(8);
    symbolicExpression = subs(symbolicExpression, symbols, sym(parametersAsArray, 'd'));

    numericalExpression = matlabFunction(symbolicExpression);
end