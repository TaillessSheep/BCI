function [ Features ] = tangent_mapping ( Pi, Pm)

[~, ~, Nt] = size(Pi);
for i = 1:Nt
    p = squeeze(Pi(:,:,i));
    [U, Sig] = eig(Pm^-0.5*p*Pm^-0.5);
    Sig = diag(log(diag(Sig)));
    Pnew = U * Sig * U';
    temp = Pnew;
%     Logp = Pm^0.5 * Pnew * Pm^0.5;
%     temp = triu(Pm^-0.5 * Logp * Pm^-0.5);
%     temp = triu(Pm^-0.5 * Pnew * Pm^-0.5);
    
    mask = triu(true(size(temp)),1);
    temp = temp(mask);
    Features(i, 1:length(temp)) = temp;
    
    

end