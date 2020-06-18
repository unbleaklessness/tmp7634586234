function R = Rz(qz, div)
    if nargin < 2
            R = sym([ ...
                cos(qz)   -sin(qz)     0;
                sin(qz)    cos(qz)     0;
                0          0           1;
            ]);
        else
            R = sym(round([ ...
                cos(qz)   -sin(qz)     0;
                sin(qz)    cos(qz)     0;
                0          0           1;
            ], div));
    end
end