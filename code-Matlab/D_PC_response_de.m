function res = D_PC_response_de(params,inputs)
% This function generates a vector of intensity values over time for one
% half of the PB to a sequence of single-modality experience (either AF or
% OF).


% inputs are sensory info
thetavec = inputs(1,:); % radians, (+) is ipsi to the PB half
speedvec = inputs(2,:); % cm/s
t = inputs(3,:); % seconds

a = params(1); % like Amp
c = params(2); % speed coefficient for max, =1 for non-speed-tuned PFNs
prefdir = params(3); % in rads; parameter formerly known as theta0
b = params(4); % like offset
ratio = abs(params(5)); % ratio of steady-state to max amp; =0 for steady-state=0;
% ratio=1 for PFNd OF
tau = params(6); % time constant (offset)
tauslope = params(7); % speed coefficient for tau
flip = params(8); % for rising OF response =0 vs. falling AF response !=0

if flip ~=0 % if AF response curve
    ratio = 1-ratio;
end

C = a*(1-exp(c*-speedvec)).*(cos(thetavec-prefdir)+b);
T = tau+tauslope.*exp(speedvec./100);

% res(1) = 0;
res(1) = C(1);

for i = 1:length(t)-1
    dt = (t(i+1)-t(i));
    res(i+1) = (res(i) + ((ratio)*C(i) - res(i))*(dt/(T(i))));
end

if flip~=0 % if AF response curve
    res = max(0,C-res);
%     res = abs(C-res);
end


% figure; 
% subplot(4,1,1); plot(thetavec); ylim([-pi pi])
% subplot(4,1,2); plot(speedvec); ylim([0 100])
% subplot(4,1,3); plot(T);
% subplot(4,1,4); plot(C);
% hold on; plot(res);
