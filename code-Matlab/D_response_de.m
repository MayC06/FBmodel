function res = D_response_de(params,inputs)
% This function generates a vector of intensity values over time for one
% half of the PB innervated by PFNd, to a sequence of single-modality 
% experience (either AF or OF).


% Setup with arguments.
% inputs are sensory info
thetavec = inputs(1,:); % radians, (+) is ipsi to the PB half
speedvec = inputs(2,:); % cm/s
t = inputs(3,:); % seconds

% parameters
a = params(1); % like Amp
c = params(2); % speed coefficient for max, =1 for non-speed-tuned PFNs
prefdir = params(3); % in rads; parameter formerly known as theta0
b = params(4); % like offset
ratio = abs(params(5)); % ratio of steady-state to max amp; =0 for steady-state=0;
tau = params(6); % time constant (offset)
tauslope = params(7); % speed coefficient for tau
flip = params(8); % for rising OF response =0 vs. falling AF response !=0


% Set anchoring values for numerical solution: C is like max value, T is
% full tau expression, res(1) is the initial result (assumed to be the
% steady state if the first timestep inputs were held constant).
C = a*(1-exp(c*-speedvec)).*(cos(thetavec-prefdir)+b);
T = tau+tauslope.*exp(speedvec./100);
% res(1) = ratio*C(1);
res(1) = C(1);


% Handle direction of response (rise/decay).
if flip ~=0 % if AF response curve
    ratio = 1-ratio;
end


% Calculate numerical solution using the given inputs and parameters.
for i = 1:length(t)-1
    dt = (t(i+1)-t(i));
    res(i+1) = (res(i) + ((ratio)*C(i) - res(i))*(dt/(T(i))));
end


% Handle negative values for AF response curves.
if flip~=0
    res = max(0,C-res);
%     res = C-res;
end


% Plot, if you want to; comment out otherwise.
% figure; 
% subplot(4,1,1); plot(thetavec); ylim([-pi pi])
% subplot(4,1,2); plot(speedvec(1:100)); ylim([0 100])
% subplot(4,1,3); plot(ones(1,129)*ratio);
% subplot(4,1,4); plot(C(1:100));
% hold on; plot(res(1:100));
