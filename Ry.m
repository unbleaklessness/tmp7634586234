function R = Ry(qy)
    R = sym([ ...
        cos(qy)      0      sin(qy);
        0            1            0;
        -sin(qy)     0      cos(qy);
    ]);
end

