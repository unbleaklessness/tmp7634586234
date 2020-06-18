function w = skewToAngular(s)
    w = simplify(-0.5 * [ ...
        s(2, 3) - s(3, 2), ...
        s(3, 1) - s(1, 3), ...
        s(1, 2) - s(2, 1) ...
    ]);
end