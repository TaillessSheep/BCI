function [ sel, Ws ] = BSML( data, indexing, labels )
% indexing is used to determine the supersets by zeros and 1s
% indexing is a vector of 0, 1, 2s
if length(indexing) ~= length(labels)
    error('indeing and labels do not have equal length')
end
ind = ~logical(sum(data.labels(data.idxTraining) == labels(indexing == 2),2));
COVtrain = data.data(:,:,data.idxTraining(ind));
Ytrain  = data.labels(data.idxTraining(ind));
%------------------------------------------------------
temp = Ytrain == labels(indexing == 0);
ind_s1 = sum(temp,2);
% temp = Ytrain == labels(indexing == 1);
% ind_s2 = sum(temp,2);
%------------------------------------------------------
P1 = riemann_mean(COVtrain(:,:,logical(ind_s1)));
P2 = riemann_mean(COVtrain(:,:,~logical(ind_s1)));
%------------------------------------------------------
%---------------Schur Complement-----------------------
% W=sdpvar(22,22,'full');
% cons=[-eye(22)  W; W'  -inv(P1+P2)]<0;
% info=solvesdp(cons,-trace(W),sdpsettings('solver','sdpt3','sdpt3.steptol',...
%     1e-10,'sdpt3.inftol',1e-10,'sdpt3.gaptol',1e-10));
% W=double(W);

%------------------------------------------------------
% [U, Sig] = eig(P1+P2);
% Ubar = Sig^-0.5*U';
% [U1, Sig1] = eig(Ubar*P1*Ubar');
% W = U1'*Ubar;
% landa1 = diag(Sig1);
%------------------------------------------------------
[W, D] = eig(P1, P2+P1);
W = W';
landa1 = diag(D);
%------------------------------------------------------
% [W, D] = eig(inv(P1+P2)*P1);
% % D = diag(W'*P1*W);
% W = W';
% landa1 = diag(W*P1*W');
% landa1 = diag(D);
[landa1, ind] = sort(abs(landa1-0.5), 'descend');
%----------------------------------------------------------
%---------Based on Optimal Eigenvalue ---------------------
% for m = 1:length(ind)
%     landa_opt(m) = abs( sqrt(sum(log10(landa1./(1-landa1)).^2)) - ...
%         sqrt(sum(log10(landa1(ind(1:m))./(1 - landa1(ind(1:m)))).^2))  );
% end
% plot(landa_opt)
% plot(landa_opt,'b*')
% [sel ~] = ginput(1);
% sel = floor(sel)
% % sel = 1:length(landa1);
% % sel = sel(diff(landa_opt) == min(diff(landa_opt)))+1;
% hold on
% plot(sel, landa_opt(sel), 'r*')
% hold off
%--------------------------------------------------------------------
%--------------Based on Er formula in the paper----------------------
for i = 1:length(landa1)
    Ws = W(ind(1:i), :);
    Er(i) = 1 - (distance_riemann(Ws*P1*Ws',Ws*P2*Ws')/distance_riemann(P1,P2));
end
figure
plot(Er,'b*')
%------------------------------- Graphical Selection ----------------------
% [sel ~] = ginput(1);
% sel = floor(sel)
%------------------------------- Attempt to Detect Elbow ------------------
% sel = 1:length(landa1);
% new = abs(diff(Er));
% sel = sel(new == max(new));
% if new(sel) > 1.1*max(new([1:length(new)] ~= sel))
%     sel = sel + 1;
% else
%     sel = 22;
% end
%--------------------------- Attempt to Detect Elbow ----------------------
% new = diff(Er);
% for i = 1: length(new)-1
%     if new(i+1) < new(i)






%---------------- Attempt to Detect Elbow based on Cumsum of Error --------
C_Er = cumsum(Er);
for i = length(C_Er):-1:1
    if C_Er(i) < 0.99*C_Er(end)
        sel = i;
        break;
    end
end
%--------------------------------------------------------------------------
% C_Er = cumsum(landa1);
% for i = length(Er):-1:1
%     if Er(i) < 0.9*Er(end)
%         sel = i;
%         break;
%     end
% end
%----------------------- Based on Adjusted R-squared ----------------------
% for i = 1:length(Er)
%     A_R2(i) = 1 - ((1 - Er(i))*(22+1)/(22-i+1));
% end
% hold on
% plot(A_R2, 'k*')
% sel = 1:(length(Er)-1);
% sel = sel(A_R2 == max(A_R2));
% [sel ~] = ginput(1);
% sel = floor(sel)
%-----------------------------------------
% sel = 22;
% hold on
% plot(sel, Er(sel), 'r*')
% hold off
%----------------------------------------------------
Ws = W(ind(1:sel), :);
end


