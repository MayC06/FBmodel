function res = PFNa_integ(params,inputs,inits)

% params = array where first row is AF, second row is OF
% inputs = array where:
% [ AF directions; 
%   AF speeds; 
%   OF directions; 
%   OF speeds; 
%   time ]

% Calculate single-half PB OF response
OF = A_response_de(params(2,:),inputs([3:5],:),inits(2));

% Calculate single-half PB AF response 
AF = A_response_de(params(1,:),inputs([1,2,5],:),inits(1));

% Instantiate result
res = zeros(1,length(inputs(1,:)));

% Where OF response exists, insert into result
OFinds = find(OF);
res(OFinds) = OF(OFinds);
% Where AF or AFOF response exists, insert into result (overwriting OF
% except where OF is alone).
AFinds = find(AF);
res(AFinds) = AF(AFinds);
