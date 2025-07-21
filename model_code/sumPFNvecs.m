function [va vm] = sumPFNvecs(PFN_bumps,PFN_amps)
    % assumes PFN_bumps is already 45-deg shifted. because that's what i've
    % done in FBmodel7.m.
    adj = PFN_amps(:,1).*cos(PFN_bumps(:,1)) + PFN_amps(:,2).*cos(PFN_bumps(:,2));
    opp = PFN_amps(:,1).*sin(PFN_bumps(:,1)) + PFN_amps(:,2).*sin(PFN_bumps(:,2));
    va = (180/pi)*atan2(opp,adj);
    vm = sqrt(opp.^2+adj.^2);
end