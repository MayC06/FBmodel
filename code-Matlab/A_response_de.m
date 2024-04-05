function res = A_response_de(params,inputs)
% This function generates a vector of intensity values over time for one
% half of the PB to a sequence of single-modality experience (either AF or
% OF).

% inputs are sensory info
thetavec = inputs(1,:); % radians, (+) is ipsi to the PB half
speedvec = inputs(2,:); % cm/s
t = inputs(3,:); % seconds

a = params(1); % like Amp
c = params(2); % coeff for second cosine term
prefdir = params(3); % in rads; parameter formerly known as theta0
b = params(4); % like offset
r = params(5); % offset to arrive at steady-state
d = params(6); % amplitude of steady-state driven by direction tuning
tau = params(7); % time constant
flip = params(8); % for rising OF response =0 vs. falling AF response !=0

C = a*(1-exp(-speedvec)).*(cos(thetavec-prefdir).^2 + c*cos(thetavec-prefdir+pi) + b);
T = tau;
ratio = r + d*cos(thetavec-prefdir);

% res(1) = 0;
res(1) = C(1);

if flip ~=0 % if AF response curve
    ratio = 1-ratio;
end

for i = 1:length(t)-1
    dt = (t(i+1)-t(i));
    res(i+1) = (res(i) + ((ratio(i))*C(i) - res(i))*(dt/(T)));
end

if flip~=0 % if AF response curve
    res = max(0,C - res);
end


% figure; 
% subplot(4,1,1); plot(thetavec); ylim([-pi pi])
% subplot(4,1,2); plot(speedvec); ylim([0 100])
% subplot(4,1,3); plot(ratio);
% subplot(4,1,4); plot(C);
% hold on; plot(res);
