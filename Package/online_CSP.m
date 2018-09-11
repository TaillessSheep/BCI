function [command, prob]= online_CSP (data, Wn, Classifier)
Arg_Ft_Ts = Wn'*data * data'*Wn;
Ft_Ts= log ((diag(Arg_Ft_Ts))/trace(Arg_Ft_Ts));
[command, prob] = Classifier.predictFcn(Ft_Ts');
prob = prob(command);
end