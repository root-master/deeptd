function [o,h,id]  = kwta_NN_forward_radical(s, Wih,biasih, Who,biasho) 
    
shunt = 1;
nCellHidden = length(Wih);

k = round(0.1 * nCellHidden); % number of winners

% net = zeros(nCellHidden,1);

% forward pass
% propagate input to hidden
s = s .* (s > 0.2);
net = s * Wih + biasih;

[netSorted,idsort] = sort(net,'descend');
q = 0.25; % constant 0 < q < 1 determines where exactly
          % to place the inhibition between the k and k + 1th units

biaskwta = netSorted(k+1) + q * ( netSorted(k) - netSorted(k+1) );
id = idsort(1:k);

eta = net - biaskwta - shunt; % shunt is a positive number which is the shift to left in activation-eta

% hidden activation
h = zeros(1,nCellHidden);
h(id) = 1./(1 + exp(-eta(id)) );

o = h * Who + biasho; % Output




