function res = bumpmdl_de(params,thetavec,t,h)

% parameters as of 20231017 (from fitting or no?)
% [ 2 ] % tau only
% x = [ 10/26:10/26:10 ]

% parameters
tau = params(1);

res(1) = 0;

for i = 1:length(t)-1
    coeff = -wrapTo180((180/pi)*thetavec(i))*h(i);
    res(i+1) = res(i) + (coeff - res(i))*((t(i+1)-t(i))/tau);
end

% figure;
% plot(t,res,'linewidth',2)
