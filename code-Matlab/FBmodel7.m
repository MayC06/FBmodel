function res = FBmodel7(gust_res,p_PFNd,p_PFNv,p_PFNpc,p_PFNa,heatmaps,plt)
% This function will generate sinusoidal bumps for the compass/EB and in
% the PB and FB (for PFNs). It takes parameters previously determined
% from fitting for timecourses of PFN calcium intensity and bump position 
% in the PB.

% gust_res is a stimulus input structure with six fields: heading,
% Atheta (AF direction), Amag (airspeed), Otheta (OF direction), 
% Omag (OF speed), and time vector in frame-seconds (usually 
% matched to imaging data framerate).

% For parameters, load PFNa_params.mat, PFNd_params.mat, PFNpc_params.mat, 
% and PFNv_params.mat.

    p_bump = 2; % bump position tau for egocentric airflow (pulled from PFNd)

% Input stimulus vectors. Directions are egocent. with (+) = fly's right
    heading = gust_res.heading; % vector of allocentric heading directions (rad)
    thva = gust_res.Atheta; % vector of egocentric airflow directions (rad) over time
    spda = gust_res.Amag; % vector of airspeeds in cm/s over time
    thvo = gust_res.Otheta; % vector of egocentric optic flow directions (rad) over time
    spdo = gust_res.Omag; % vector of optic flow speeds in cm/s over time (assuming matching with AF)
    t = gust_res.t; %[len/frames:len/frames:len] where len is in seconds

% Convert egocent. inputs to ipsi/contra for each PB hemisphere
% just flip the direction signs for left-side PB
    Rinputs = [thva;spda;thvo;spdo;t];
    Linputs = [-thva;spda;-thvo;spdo;t];

% Amplitude models.
    PFNd_amp(1,:) = PFNd_integ(p_PFNd,Linputs); % left PB amp
    PFNd_amp(2,:) = PFNd_integ(p_PFNd,Rinputs); % right PB amp
    
    PFNv_amp(1,:) = PFNd_integ(p_PFNv,Linputs); % integration should be same for d&v?
    PFNv_amp(2,:) = PFNd_integ(p_PFNv,Rinputs); % integration should be same for d&v?

    % note about PFNpc intensity: if tau integrates AF+OF, use PFNpc_integ.m,
    % otherwise use PFNpc_integ2.m
    PFNpc_amp(1,:) = PFNpc_integ2(p_PFNpc,Linputs);
    PFNpc_amp(2,:) = PFNpc_integ2(p_PFNpc,Rinputs);
    
    PFNa_amp(1,:) = PFNa_integ(p_PFNa,Linputs);
    PFNa_amp(2,:) = PFNa_integ(p_PFNa,Rinputs);    

% Bump position models.
    ha = spda; % airspeeds
    ha(ha~=0)=1; % binarize airspeed on/off
    bumppos = bumpmdl_de(p_bump,thva,t,ha); % bump movement due to airflow
    bumppos = bumppos - (180/pi)*heading;
    
    if ~heatmaps % output the amplitude and bump position vectors for each neuron type
        PFNd_bump(1,:) = wrapTo180(bumppos+45);
        PFNd_bump(2,:) = wrapTo180(bumppos-45);
        PFNv_bump(1,:) = wrapTo180(bumppos+45);
        PFNv_bump(2,:) = wrapTo180(bumppos-45);
        PFNpc_bump(1,:) = wrapTo180(bumppos+45);
        PFNpc_bump(2,:) = wrapTo180(bumppos-45);
        for i = 1:length(t)
            if thva(i) > 0.1 && spda(i) > 0
                PFNa_bump(1,i) = wrapTo180(bumppos(i)+45+180);
                PFNa_bump(2,i) = wrapTo180(bumppos(i)-45);
            elseif thva(i) < -0.1 && spda(i) > 0
                PFNa_bump(1,i) = wrapTo180(bumppos(i)+45);
                PFNa_bump(2,i) = wrapTo180(bumppos(i)-45+180);
            else
                PFNa_bump(1,i) = wrapTo180(bumppos(i)+45);
                PFNa_bump(2,i) = wrapTo180(bumppos(i)-45);
            end
        end
        
        % return results
        % These are the representations in the PB (protocerebral bridge).
        res.bump = bumppos;
        res.PFNd_amp = PFNd_amp;
        res.PFNv_amp = PFNv_amp;
        res.PFNpc_amp = PFNpc_amp;
        res.PFNa_amp = PFNa_amp;
        
        res.PFNd_bump = PFNd_bump;
        res.PFNv_bump = PFNv_bump;
        res.PFNpc_bump = PFNpc_bump;
        res.PFNa_bump = PFNa_bump;
        
        % This section sums the PFN representations from the bridge as they
        % would be in the FB, within-type (includes 45-deg shift). 
        % Requires function sumPFNvecs.m. If matlab has a builtin phasor
        % summation function, I couldn't find it so I built my own.
        [res.PFNd_bumpFB res.PFNd_ampFB] = ...
            sumPFNvecs((pi/180)*res.PFNd_bump,res.PFNd_amp);
        [res.PFNv_bumpFB res.PFNv_ampFB] = ...
            sumPFNvecs((pi/180)*res.PFNv_bump,res.PFNv_amp);
        [res.PFNpc_bumpFB res.PFNpc_ampFB] = ...
            sumPFNvecs((pi/180)*res.PFNpc_bump,res.PFNpc_amp);
        [res.PFNa_bumpFB res.PFNa_ampFB] = ...
            sumPFNvecs((pi/180)*res.PFNa_bump,res.PFNa_amp);
        
    elseif heatmaps
    % Sinusoids over time. These augment the amplitudes so that we don't go
    % negative and also so the bump structure doesn't hit a minimum. Need
    % to fix this later - FB sum amplitudes therefore differ in ~heatmaps
    % vs. heatmaps sections.
        for i=1:length(t)

            % compass neurons report heading and airflow direction
            EPG(:,i) = 0.5 + 0.5*cosd([-135:45:180]-bumppos(i));

            % PB sinusoids for PFNd
            PFNdL_pb(:,i) = (PFNd_amp(1,i)+0.5) * (0.5 + 0.5*cosd([-135:45:180]-bumppos(i)));
            PFNdR_pb(:,i) = (PFNd_amp(2,i)+0.5) * (0.5 + 0.5*cosd([-135:45:180]-bumppos(i)));

            % PB sinusoids for PFNv
            % IMPORTANT NOTE FOR PFNV:
            % I have not recorded from PFNv, so we do not know if they are
            % sensitive to airflow direction. This model assumes inverted
            % vectors from PFNd, as shown for OF representations in Lyu et al.
            % (Maimon lab) 2022 and Lu et al. (Wilson lab) 2022
            PFNvL_pb(:,i) = (PFNv_amp(1,i)+0.5) * (0.5 + 0.5*cosd([-135:45:180]-bumppos(i)));
            PFNvR_pb(:,i) = (PFNv_amp(2,i)+0.5) * (0.5 + 0.5*cosd([-135:45:180]-bumppos(i)));

            % PB sinusoids for PFNpc
            % include bump movement?
            PFNpcL_pb(:,i) = (PFNpc_amp(1,i)+0.5) * (0.5 + 0.5*cosd([-135:45:180]-bumppos(i)));
            PFNpcR_pb(:,i) = (PFNpc_amp(2,i)+0.5) * (0.5 + 0.5*cosd([-135:45:180]-bumppos(i)));
    %         PFNpcL_pb(:,i) = (PFNpc_amp(1,i)+0.5) * (0.6 + 0.2*cosd([-135:45:180]));
    %         PFNpcR_pb(:,i) = (PFNpc_amp(2,i)+0.5) * (0.6 + 0.2*cosd([-135:45:180]));

            % PB sinusoids for PFNa - bump needs to shift 180deg when AF contralateral
            if thva(i) > 0.1 && spda(i) > 0
                PFNaL_pb(:,i) = (PFNa_amp(1,i)+0.5) * (0.5 + 0.5*cosd([-135:45:180]-bumppos(i)+180));
                PFNaR_pb(:,i) = (PFNa_amp(2,i)+0.5) * (0.5 + 0.5*cosd([-135:45:180]-bumppos(i)));
            elseif thva(i) < -0.1 && spda(i) > 0
                PFNaL_pb(:,i) = (PFNa_amp(1,i)+0.5) * (0.5 + 0.5*cosd([-135:45:180]-bumppos(i)));
                PFNaR_pb(:,i) = (PFNa_amp(2,i)+0.5) * (0.5 + 0.5*cosd([-135:45:180]-bumppos(i)+180));
            else
                PFNaL_pb(:,i) = (PFNa_amp(1,i)+0.5) * (0.5 + 0.5*cosd([-135:45:180]-bumppos(i)));
                PFNaR_pb(:,i) = (PFNa_amp(2,i)+0.5) * (0.5 + 0.5*cosd([-135:45:180]-bumppos(i)));
            end

            % FB sinusoids for PFNd
            PFNdL(:,i) = circshift(PFNdL_pb(:,i),1);
            PFNdR(:,i) = circshift(PFNdR_pb(:,i),-1);

            % FB sinusoids for PFNv
            PFNvL(:,i) = circshift(PFNvL_pb(:,i),1);
            PFNvR(:,i) = circshift(PFNvR_pb(:,i),-1);

            % FB sinusoids for PFNpc
            PFNpcL(:,i) = circshift(PFNpcL_pb(:,i),1);
            PFNpcR(:,i) = circshift(PFNpcR_pb(:,i),-1);

            % FB sinusoids for PFNa
            PFNaL(:,i) = circshift(PFNaL_pb(:,i),1);
            PFNaR(:,i) = circshift(PFNaR_pb(:,i),-1);

        end

    % return results
        res.EPG = [EPG(8,:)',EPG'];

        % PB representations
        res.PFNdL_pb = [PFNdL_pb(8,:)',PFNdL_pb'];
        res.PFNdR_pb = [PFNdR_pb(8,:)',PFNdR_pb'];
        res.PFNvL_pb = [PFNvL_pb(8,:)',PFNvL_pb'];
        res.PFNvR_pb = [PFNvR_pb(8,:)',PFNvR_pb'];
        res.PFNpcL_pb = [PFNpcL_pb(8,:)',PFNpcL_pb'];
        res.PFNpcR_pb = [PFNpcR_pb(8,:)',PFNpcR_pb'];
        res.PFNaL_pb = [PFNaL_pb(8,:)',PFNaL_pb'];
        res.PFNaR_pb = [PFNaR_pb(8,:)',PFNaR_pb'];

        % FB representations, shifted 45deg from PB
        res.PFNdL = [PFNdL(8,:)',PFNdL'];
        res.PFNdR = [PFNdR(8,:)',PFNdR'];
        res.PFNvL = [PFNvL(8,:)',PFNvL'];
        res.PFNvR = [PFNvR(8,:)',PFNvR'];
        res.PFNpcL = [PFNpcL(8,:)',PFNpcL'];
        res.PFNpcR = [PFNpcR(8,:)',PFNpcR'];
        res.PFNaL = [PFNaL(8,:)',PFNaL'];
        res.PFNaR = [PFNaR(8,:)',PFNaR'];

        % sum of 45deg-shifted sinusoids in FB
        FBd = PFNdL'+PFNdR';
        res.FBd = [FBd(:,8),FBd];
        FBv = PFNvL'+PFNvR';
        res.FBv = [FBv(:,8),FBv];
        FBpc = PFNpcL'+PFNpcR';
        res.FBpc = [FBpc(:,8),FBpc];
        FBa = PFNaL'+PFNaR';
        res.FBa = [FBa(:,8),FBa];

        % Downstream summation in hdJ-like neuron type, from PFN-hdJ anatomy in connectome
    %     hdJ = FBd + circshift(FBv,4,2); % hdB readout
    %     hdJ = circshift(FBa,4,2);
        hdJ = FBd + circshift(FBv,4,2) + circshift(FBpc,4,2) + circshift(FBa,4,2); % sum all PFNs
        res.hdJ = [hdJ(:,8),hdJ];

        % plotting
        if plt

            figure; set(gcf,'Position',[245 310 900 550])
            subplot(1,5,1); plot((180/pi)*heading,t); ylim([min(t) max(t)]); xlim([-180 180]); xticks([-180:90:180]); title('heading')
            set(gca,'YDir','reverse')
            subplot(1,5,2); plot(thva*180/pi,t); ylim([min(t) max(t)]); xlim([-180 180]); xticks([-180:90:180]); title('airflow dir')
            set(gca,'YDir','reverse')
            subplot(1,5,3); plot(spda,t); ylim([min(t) max(t)]); xlim([-10 100]); title('airspeed')
            set(gca,'YDir','reverse')
            subplot(1,5,4); plot(thvo*180/pi,t); ylim([min(t) max(t)]); xlim([-180 180]); xticks([-180:90:180]); title('optic flow dir')
            set(gca,'YDir','reverse')
            subplot(1,5,5); plot(spdo,t); ylim([min(t) max(t)]); xlim([-10 100]); title('optic flow speed')
            set(gca,'YDir','reverse')
            sgtitle('Stimulus Conditions')

            figure; set(gcf,'Position',[490 310 900 550])
            subplot(1,5,1); imagesc(res.EPG); caxis([-0.5 2]);
            title(sprintf('bump\nposition'))
            subplot(1,5,2); imagesc([res.PFNdL_pb res.PFNdR_pb]); caxis([-0.5 3]);
            xline(9.5,'k'); xticks([]); title('PFNd PB')
            subplot(1,5,3); imagesc([res.PFNvL_pb res.PFNvR_pb]); caxis([-0.5 3]);
            xline(9.5,'k'); xticks([]); title('PFNv PB')
            subplot(1,5,4); imagesc([res.PFNpcL_pb res.PFNpcR_pb]); caxis([-0.5 3]);
            xline(9.5,'k'); xticks([]); title('PFNpc PB')
            subplot(1,5,5); imagesc([res.PFNaL_pb res.PFNaR_pb]); caxis([-0.5 3]);
            xline(9.5,'k'); xticks([]); title('PFNa PB')
            sgtitle('PB activity')

            figure; set(gcf,'Position',[490 110 900 550])
            subplot(1,5,1); imagesc(res.FBd); caxis([-0.5 3]); 
            title('PFNd sum')
            subplot(1,5,2); imagesc(res.FBv); caxis([-0.5 3]); 
            title('PFNv sum')
            subplot(1,5,3); imagesc(res.FBpc); caxis([-0.5 3]); 
            title('PFNpc sum')
            subplot(1,5,4); imagesc(res.FBa); caxis([-0.5 3]); 
            title('PFNa sum')
            subplot(1,5,5); imagesc(res.hdJ); colorbar; % caxis([-0.5 2]); 
            title('hdJ sum')
            sgtitle('FB activity')
        end
    end
end