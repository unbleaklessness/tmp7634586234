% ???????????? ?????????? ????????? 
%???????????? ??? ???????????? ??????? ???????? ???????????? z
function [C]=linearof(EqLag,qdq)
C = sym(7);
qdq0=zeros(size(qdq));
       for j=1:1:length(qdq)
           C(j)=diff(EqLag,qdq(j));
           C(j)=subs(C(j),qdq,qdq0);
           C(j)=simplify(expand(C(j)));
       end
end