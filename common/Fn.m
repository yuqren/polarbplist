% -----------------------------------------------------------------------------------------------------------
% FUNCTION INFORMATION (c) 2023 Telecommunications Circuits Laboratory, EPFL
% -----------------------------------------------------------------------------------------------------------
% name  : Fn
% descr : generate the Kronecker product

function A=Fn(N)
n=log2(N);
A=[1,0;1,1];
for i=1:n-1
    A=kron(A,[1,0;1,1]);
end