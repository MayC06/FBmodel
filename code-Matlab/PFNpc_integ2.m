function res = PFNpc_integ2(params,inputs,inits)
% This one doesn't have any effect of MS on tau. Compare to PFNpc_integ.m

% params = array where first row is AF, second row is OF
% inputs = array where:
% [ AF directions; 
%   AF speeds; 
%   OF directions; 
%   OF speeds; 
%   time ]


% Calculate single-half PB AF response 
% AF = PC_response_de(params(1,:),inputs([1,2,5],:),inits(1));
AF = on_off_de(params(1:2,:),inputs([1,2,5],:),inits(1));

% Calculate single-half PB OF response
% OF = PC_response_de(params(2,:),inputs([3:5],:),inits(2));
OF = on_off_de(params(3:4,:),inputs([3:5],:),inits(2));

% Instantiate result
res = zeros(1,length(inputs(1,:)));

% Where OF response exists, insert into result
OFinds = find(OF);
res(OFinds) = OF(OFinds);
% Where AF or AFOF response exists, insert into result (overwriting OF
% except where OF is alone).
AFinds = find(AF);
res(AFinds) = AF(AFinds);
