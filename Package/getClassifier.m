function [out_classifier, out_Wn] = getClassifier(name,Trimming,classType,numEig)
Existed = false;
%% check if the specified classifer has already been built
Existed_Classifiers = what('../Classifiers');
Existed_Classifiers = Existed_Classifiers.mat;
for i = (1:length(Exited_Classifiers))
    if Existed_Classifiers{i} == name
        Existed = true;
        break;
    end
end

%% if it is built (load it and return it)
if Existed
    load(['../Classifiers/' name])
    out_classifier = classifier;
    out_out_Wn = Wn;
end

%% if the classifier does not exist(built, save and return it)
if ~Existed
    Existed_prepro = false;
    addpath('../Data')
    Existed_Data = what('../Data');
    Existed_Data = Existed_Data.mat;
    name_prepro = [name '_prepro.mat'];
    for i = (1:length(Existed_Data))
        if strcmp(Existed_Data{i}, name_prepro)
            Existed_prepro = true;
            break
        end
    end
    % need the preprocessed data to run the rest of the code
    if ~Existed_prepro
        error('Can not find the preprocessed data file.');
    end
    
    load(['../Data/' name_prepro])
    
    
end
