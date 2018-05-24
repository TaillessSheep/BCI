function [Wn, f_tr, Class_comb, Ncomb, S_class] = TrainRCSP01( Epoc_data, Label_data, CSPdim, varargin) 
% [Wn, f_tr, Class_comb, Ncomb, S_class] = TrainRCSP01(Epoc_data, Label_data, CSPdim, Reg_G, Reg_y, Reg_b, Reg_s, Reg_K, Reg_a)
% set defaults for optional inputs
optargs = {[] 0 0 1 [] 0};

% overwrite defaults with the ones specified in varargin.
optargs(1:length(varargin)) = varargin;

% Place optional args in variable names
[Reg_G, Reg_y, Reg_b, Reg_s, Reg_K, Reg_a] = optargs{:};



[Nch, Nsa, Ntr] = size(Epoc_data);
Ntr_class = histcounts(Label_data);
% Ntr_class = Ntr_class(1,2:end);
Ncl = length(Ntr_class);
X_class = zeros(Nch, Nsa, max(Ntr_class),Ncl);
i_class = zeros(1,Ncl);
for tr = 1:Ntr
    for cl = 1:Ncl
        if Label_data(1,tr) == cl
            i_class(1,cl) = i_class(1,cl)+1;
            X_class(:,:,i_class(cl),cl) = Epoc_data(:,:,tr);
        end
    end
end

NsaNtr_class = Nsa*Ntr_class;

XX_class = zeros (max(NsaNtr_class),Nch,Ncl);
S_class = zeros (Nch,Nch,Ncl);

Reg_cov = 0;
if ~isempty(Reg_G)
    Reg_cov = 1;
    S_classR = zeros (Nch,Nch,Ncl);
end

for cl = 1:Ncl
    XX_class(1:NsaNtr_class(cl),:,cl) = reshape( permute(X_class(:,:,1:Ntr_class(cl),cl), [2 3 1]), [NsaNtr_class(cl), Nch]);
    S_class(:,:,cl) = cov(XX_class(1:NsaNtr_class(cl),:,cl));
    S_class(isnan(S_class)) = 0;
    S_class(isinf(S_class)) = 0;
    
    %regularize cov matricies
    if Reg_cov
        S_classR(:,:,cl) = (1-Reg_y)*((1-Reg_b)*Reg_s*S_class(:,:,cl)+Reg_b*Reg_G(:,:,cl))+Reg_y*eye(Nch);
    end
end

if Reg_cov
        S_class = S_classR;
end

Class_comb = combnk(1:Ncl,2);
[Ncomb,~] = size(Class_comb);
W = zeros(Nch,Nch,Ncomb);
Nf = 2*CSPdim;
Wn = zeros(Nch,Nf,Ncomb);
f_tr = zeros(Nf,Ntr,Ncomb);

Reg_obj = 0;
if ~isempty(Reg_K)
    Reg_obj = 1;
end

for comb = 1:Ncomb
    if ~Reg_obj 
        [W,~] = eig(S_class(:,:,Class_comb(comb,1)), S_class(:,:,Class_comb(comb,1))+S_class(:,:,Class_comb(comb,2)));
    elseif Reg_obj 
        [W,~] = eig(S_class(:,:,Class_comb(comb,1)), S_class(:,:,Class_comb(comb,1))+S_class(:,:,Class_comb(comb,2))+Reg_a*Reg_K);
    end
    Wn(:,:,comb) = [W(:,1:CSPdim) W(:,end-CSPdim +1:end)];
    for tr = 1:Ntr
        arg_tr = Wn(:,:,comb)'* Epoc_data(:,:,tr) * Epoc_data(:,:,tr)'* Wn(:,:,comb);
        f_tr(:,tr,comb) = log ((diag(arg_tr))/trace(arg_tr));
    end
end
f_tr = permute(f_tr,[2 1 3]);    
