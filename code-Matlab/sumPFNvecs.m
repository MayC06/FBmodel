function [va vm] = sumPFNvecs(PFN_bumps,PFN_amps)
    adj = PFN_amps(1,:).*cos(PFN_bumps(1,:)+pi/4) + PFN_amps(2,:).*cos(PFN_bumps(2,:)-pi/4);
    opp = PFN_amps(1,:).*sin(PFN_bumps(1,:)+pi/4) + PFN_amps(2,:).*sin(PFN_bumps(2,:)-pi/4);
    va = atan2(opp,adj);
    vm = sqrt(opp.^2+adj.^2);
end