function [Wn, f_tr, ClassLearn] = TrainCSP01( Epoc_data, Label_data, CSPdim )

[Nch, Nsa, Ntr] = size(Epoc_data);
Ntr_1 = 0;
Ntr_2 = 0;
for i = 1:Ntr
    if Label_data(i) == 1
        Ntr_1 = Ntr_1 +1;
    elseif Label_data(i) == 2
        Ntr_2 = Ntr_2 +1;
    end
end
X1 = zeros(Nch, Nsa, Ntr_1);
X2 = zeros(Nch, Nsa, Ntr_2);
iX1 = 1;
iX2 = 1;
for i = 1:Ntr
    if Label_data(i) == 1
        X1(:,:,iX1) = Epoc_data(:,:,i);
        iX1 = iX1 + 1;
    elseif Label_data(i) == 2
        X2(:,:,iX2) = Epoc_data(:,:,i);
        iX2 = iX2 + 1;
    end
end


[nc1, ns1, nt1] = size( X1 );
[nc2, ns2, nt2] = size( X2 );

XX1 = reshape( permute(X1, [2 3 1]), [ns1*nt1, nc1]);
S1 = cov(XX1(:,:));
S1(isnan(S1)) = 0;
S1(isinf(S1)) = 0;

XX2 = reshape( permute(X2, [2 3 1]), [ns2*nt2, nc2]);
S2 = cov(XX2(:,:));
S2(isnan(S2)) = 0;
S2(isinf(S2)) = 0;

[W,~] = eig(S1, S1+S2);

Wn = [W(:,1:CSPdim) W(:,end-CSPdim +1:end)];

arg_tr = zeros(2*CSPdim,2*CSPdim,Ntr);
f_tr = zeros(2*CSPdim,Ntr);
for i = 1:Ntr
    arg_tr(:,:,i)  = Wn'* Epoc_data(:,:,i) * Epoc_data(:,:,i)'* Wn;
    f_tr(:,i) = log ((diag(arg_tr(:,:,i)))/trace(arg_tr(:,:,i)));
end
ClassLearn = [f_tr' Label_data'];
f_tr = f_tr';