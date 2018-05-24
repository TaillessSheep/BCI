%%%-------PCA Eigen Vector #41----------

function[REEG_EigVec, ExpVar]= PCA_EigVec41(OEEG)

[coeff,~,~,~,ExpVar] = pca(OEEG);
Coe_PCA = coeff(:,1:2);
REEG_EigVec = OEEG *Coe_PCA;

end


