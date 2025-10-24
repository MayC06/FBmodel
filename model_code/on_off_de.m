function res = on_off_de(params,inputs,initcond)

% This function generates a vector of intensity values over time for one
% half of the PB to a sequence of single-modality experience (either AF or
% OF). It can handle PFNpc offset responses if given the correct
% parameters (see 'script_20240404.m')

% 'params' is a 4x8 matrix where first two rows are for onset/stimulus responses 
% and second two rows are for offset responses.

% inputs are sensory info
thetavec = inputs(1,:); % radians, (+) is ipsi to the PB half
speedvec = inputs(2,:); % cm/s
t = inputs(3,:); % seconds

% % Get stimulus-off (aka offset) periods:

% % good/corr model: get when speed == 0 and say that has the different parameters
offs = zeros(1,length(speedvec));
for i = 1:length(speedvec)
    if speedvec(i) == 0
        offs(i) = 1;
    end
end

% % This block is always needed, but toggle `0.5` gain mult. on dspd
% % With `0.5*` = good/corr model
% % Without `0.5*` = old/less good model
dspd = diff(speedvec);
for i = 1:length(speedvec)-1
    if speedvec(i+1)==0
        if dspd(i) ~=0
            speedvec(i+1) = speedvec(i)+0.5*abs(dspd(i));
%             speedvec(i+1) = speedvec(i)+abs(dspd(i));
        else
            speedvec(i+1) = speedvec(i);
        end
    end
end

% % This block is used if using the old/less good model.
% offs(1) = 0;
% for i = 1:length(speedvec)-1
%     if dspd(i)<0
%         offs(i+1) = 1;
%     elseif dspd(i)==0
%         offs(i+1) = offs(i);
%     else
%         offs(i+1) = 0;
%     end
% end


% figure; subplot(1,2,1); plot(offs); title('offs'); ylim([-0.2 1.2])
% subplot(1,2,2); plot(speedvec); title('speedvec');

% a is like Amp
a = ones(1,length(t))*params(1,1); 
a(offs~=0)=params(2,1);
% c is speed coefficient for max, =1 for non-speed-tuned PFNs
c = ones(1,length(t))*params(1,2); c(offs~=0)=params(2,2);
% prefdir is in rads; parameter formerly known as theta0
prefdir = ones(1,length(t))*params(1,3); prefdir(offs~=0)=params(2,3);
% b is the tuning curve offset/shift term
b = ones(1,length(t))*params(1,4); b(offs~=0)=params(2,4);
% ratio is of steady-state to max amp; =0 for steady-state=0; ratio=1 for PFNd OF
ratio = ones(1,length(t))*abs(params(1,5)); ratio(offs~=0)=params(2,5);
% tau is time constant with no dependency
tau = ones(1,length(t))*params(1,6); tau(offs~=0)=params(2,6);
% tauslope is speed coefficient for tau
tauslope = ones(1,length(t))*params(1,7); tauslope(offs~=0)=params(2,7);
% flip is to indicate whether activity is rising OF response =0 vs. falling AF response !=0
flip = ones(1,length(t))*params(1,8); flip(offs~=0)=params(2,8);

C = a.*(1-exp(c.*-speedvec)).*(cos(thetavec-prefdir)+b);
T = tau+tauslope.*exp(-speedvec);
% T = tau+tauslope.*exp(speedvec./100);  % from PC_response_de.m
% figure; plot(T)

res(1) = initcond;

% how much rise or fall to ss?
for i = 1:length(t)
    if flip(i) ~=0 % if AF response curve
        ratio(i) = 1-ratio(i);
    end
end

for i = 1:length(t)-1
    dt = (t(i+1)-t(i));
    res(i+1) = (res(i) + ((ratio(i))*C(i) - res(i))*(dt/(T(i))));
end

% handle the direction of movement (transient falling to ss, or rise from
% zero to ss)
for i = 1:length(res)
    if flip(i)~=0 % if AF response curve
        res(i) = abs(C(i)-res(i));       % good/corr model
%         res(i) = C(i) - res(i);          % old/less good model
    end
end


% figure; set(gcf,'Position',[405 64 560 746])
% subplot(4,1,1); plot(thetavec); ylim([-pi pi])
% subplot(4,1,2); plot(speedvec); %ylim([0 100])
% subplot(4,1,3); plot(a); ylim([-(max(a)+0.5) max(a)+0.5])
% subplot(4,1,4); plot(C); %ylim([-0.5 2.5]); %ylim([-(max(C)+0.5) max(C)+0.5])
% hold on; plot(res);
