function ii = calc_iivd(tl,iobs,a,b,c,jsrc)
% ii = calc_iivd(tl,iobs,a,b,c,jsrc)
%
% Part of the tlines calculator (see calc_tlines), given the unit
% distributed voltage source (voltage unit per length unit) which
% spans a particular tline, calculate the integral of current over
% the length of the same or another tline multiplied by the linear
% function a*(z-zi)+b.
%
%   tl   - structure with transmission lines parameters and auxiliary
%          data as returned by calc_tlines.
%   iobs - observation tline index.
%   a, b - coefficients of the linear function to multiply the current
%          by under the inegral sign
%   c    - This is a bit complicated.
%          In the case of constant distributed voltage source, the
%          transmission line equations are
%            d2I/dz2 - YZI = -YS
%            d2V/dz2 - YZV = 0
%          Where
%            Z is the series impedance per len
%            Y is the shunt admittance per len
%            S is the voltage source per len
%          And the solutions are
%            V(z)=Vp*exp(-gamma*z) + Vm*exp(gamma*z)
%            I(z)=Ip*exp(-gamma*z) + Im*exp(gamma*z) + S/Z
%          where
%            gamma = sqrt(YZ) is a propagation constant
%            Vp/Ip = -Vm/Im = sqrt(Z/Y) = Z0 is a characteristic impedance
%          Notice that the solution for I has the constant term S/Z. This
%          term is multiplied by c when integrating the current, because
%          in certain cases (when calculating the via reactions) we need
%          to drop it. Pass 1 if this term is to be included, or zero if
%          it is to be dropped.
%   jsrc - source tline index.

if iobs<jsrc,
    % Find voltage at the left terminal of the source tline
    vt = calc_vterm_vd(tl,jsrc);
    % Next, find voltage at the right terminal of the observation tline
    vt = vt.*prod(tl.Tls(:,iobs+1:jsrc-1),2);
    % Finally, find current at the observation point
    ii = vt.*calc_ii_vterm(tl,iobs,a,b);
elseif iobs>jsrc,
    % Find voltage at the right terminal of the source tline
    vt = calc_vvd(tl,tl.z(:,jsrc+1),jsrc,jsrc);
    % Next, find voltage at the left terminal of the observation tline
    vt = vt.*prod(tl.Tgr(:,jsrc+1:iobs-1),2);
    % Finally, find voltage at the observation point
    ii = vt.*calc_ii_vleft(tl,iobs,a,b);
else

    % Voltages at the left and right terminals
    V1 = calc_vvd(tl, tl.z(:,iobs), iobs, jsrc);
    V2 = calc_vvd(tl, tl.z(:,iobs+1), iobs, jsrc);

    t1 = tl.t1(:,iobs);
    k = tl.k(:,iobs);
    d = tl.d(:,iobs);
    Y0 = tl.Y0(:,iobs);
    Z = tl.k(:,iobs).*tl.Z0(:,iobs); % per-length impedance

    % Backward voltage wave at z = zi (left terminal)
    Vm = (-V2 + V1.*t1)./(t1 - 1./t1);

    % Forward and backward current waves
    Ip = Y0.*(V1 - Vm);
    Im = -Y0.*Vm;

    % Integrate the current
    ex1 = Ip.*(-exp(-k.*d).*(a.*d.*k + a + b.*k) + a + b.*k);
    ex2 = Im.*( exp( k.*d).*(a.*d.*k - a + b.*k) + a - b.*k);
    ii = (ex1 + ex2)./(k.*k) + c./(2*Z).*d.*(a.*d + 2*b);

end
