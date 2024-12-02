function res = PFNd_integ(params,inputs,initconds)

% params = array where first row is AF, second row is OF
% inputs = array where:
% [ AF directions; 
%   AF speeds; 
%   OF directions; 
%   OF speeds; 
%   time ]

AF = D_response_de(params(1,:),inputs([1:2,5],:),initconds(1));
OF = D_response_de(params(2,:),inputs([3:5],:),initconds(2));

% % If equal weights:
res = AF+OF;

% % If unequal weights determined by fitlm:
% cohInds = find(abs(inputs(1,:)-inputs(3,:))<=0.1 & inputs(2,:)>0 & inputs(4,:)>0); % find coherent
% disp(cohInds)
% res = 0.72*AF + 0.90*OF; % all timepts divergent weights...
% res(cohInds) = 0.89*AF(cohInds) + 0.67*OF(cohInds); % unless same direction