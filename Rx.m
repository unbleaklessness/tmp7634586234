function R = Rx(qx)
    R = sym([ ...
        1            0            0;
        0       cos(qx)    -sin(qx);
        0       sin(qx)     cos(qx);
    ]);
end