% File Name: checkValidity.m
% Author: Heung-Il Suk
% Cite: H.-I. Suk and S.-W. Lee, "A Novel Bayesian Framework for Discriminative 
% Feature Extraction in Brain-Computer Interfaces," IEEE Trans. on PAMI,
% 2012. (Accepted)

function sample = checkValidityBSSFO( sample )
% We enforce the samples to be within min_freq and max_freq

min_freq = 4;
max_freq = 40;
% sample = sort(sample);
% if sample(1) <= min_freq
%     sample(1) = min_freq;
% end
% 
% if sample(3) > max_freq
%     sample(3) = max_freq;
% end
% 
% if (sample(2) - sample(1)) < 1
%     sample(1) = sample(1) - 0.5;
%     sample(2) = sample(2) + 0.5;
% end
% 
% if (sample(3) - sample(2)) < 1
%     sample(2) = sample(2) - 0.5;
%     sample(3) = sample(3) + 0.5;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if sample(1) <= min_freq
%     sample(1) = min_freq;
% end
% 
% if sample(3) <= min_freq
%     sample(3) = min_freq;
% end
% 
% if sample(1) > max_freq
%     sample(1) = max_freq;
% end
% 
% if sample(3) > max_freq
%     sample(3) = max_freq;
% end
% 
% if sample(1) > sample(2)
%     temp = sample(2);
%     sample(2) = sample(1);
%     sample(1) = temp;
% end
% 
% if sample(2) > sample(3)
%     temp = sample(3);
%     sample(3) = sample(2);
%     sample(2) = temp;
% end
% 
% if sample(1) > sample(2)
%     temp = sample(2);
%     sample(2) = sample(1);
%     sample(1) = temp;
% end
% 
% if (sample(1) - sample(2)) < 1
%     sample(1) = sample(1) - 0.5;
%     sample(2) = sample(2) + 0.5;
% end
% 
% if (sample(2) - sample(3)) < 1
%     sample(2) = sample(2) - 0.5;
%     sample(3) = sample(3) + 0.5;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sample = sort(sample, 'ascend');
% if sample(1) < min_freq
%     sample(1) = min_freq;
% end
% if sample(3) > max_freq
%     sample(3) = max_freq;
% end
% if sample(3) - sample(2) < 1
%     sample(2) = sample(2) - 1;
% end
% if sample(2) - sample(1) < 1
%     sample(2) = sample(2) + 1;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if sample(1) <= min_freq
    sample(1) = min_freq;
end

if sample(2) <= min_freq
    sample(2) = min_freq;
end

if sample(1) > max_freq
    sample(1) = max_freq;
end

if sample(2) > max_freq
    sample(2) = max_freq;
end

if sample(1) > sample(2)
    temp = sample(2);
    sample(2) = sample(1);
    sample(1) = temp;
end

if (sample(1) - sample(2)) < 1
    sample(1) = sample(1) - 0.5;
    sample(2) = sample(2) + 0.5;
end