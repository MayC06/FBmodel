function res = PFNd_integ(params,inputs)

% params = array where first row is AF, second row is OF
% inputs = array where:
% [ AF directions; 
%   AF speeds; 
%   OF directions; 
%   OF speeds; 
%   time ]

AF = D_response_de(params(1,:),inputs([1:2,5],:));
OF = D_response_de(params(2,:),inputs([3:5],:));

res = AF+OF;