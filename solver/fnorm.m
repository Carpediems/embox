function [ fe, fm ] = fnorm(a, b, maxm, maxn)
% function [ fe, fm ] = fnorm(a, b, maxm, maxn)
%
% Retruns the value of the integral of the waveguide mode eigenfunction
% (solution of the transverse Helmholtz equation) squared over the guide
% crossection. Notice that the eigenfuction here includes the normalization
% coefficient as returned by wnorm.
%  Params:
%    a, b       - dimensions of the waveguide
%    maxm, maxn - upper limits of the mode indices
%  Outputs:
%    fe, fm     - integrals of the eigenfunctions for the te and tm modes
%                 correspondingly
%

% Normalization coefficients for the eigenfunctions
[ ne, nm ] = wnorm(a, b, maxm, maxn);
ne2 = ne.^2;
nm2 = nm.^2;

% TE modes
fe = a*b/4*ne2;
fe(2:end,1) = a*b/2*ne2(2:end,1);
fe(1,2:end) = a*b/2*ne2(1,2:end);
fe(1,1) = a*b*ne2(1,1);

% TM modes
fm = a*b/4*nm2;
fm(2:end,1) = 0;
fm(1,2:end) = 0;
fm(1,1) = 0;
