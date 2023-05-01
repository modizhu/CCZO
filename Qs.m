function qs = Qs(Ts, RH)
% Ts is temperature in C, RH is relative humidity 0.XXXXXX not in %
% this file must assume that the altitude is not too high
% if RH is not provided in the input file, we need to assume RH to be 1 in
% the call file
Rv = 461;
Lambda_s1 = 2.83E6;
Lambda_s2 = 2.5E6;
T0 = 273;
Ts = T0 + Ts;
e0 = 0.61129E3;
P = 101.325E3;      % assumed to be this value
qs = zeros(length(Ts), 1);
for i = 1 : length(Ts)
    if Ts(i) < T0
        qs(i) = 0.62 * RH(i)* e0/P * exp(Lambda_s1/Rv * (1/T0 - 1/Ts(i)));
    else
        qs(i) = 0.62 * RH(i)* e0/P * exp(Lambda_s2/Rv * (1/T0 - 1/Ts(i)));
    end
end