function [DATA, Label] = data_prepare_BCICIVIIb (subject, status, start_time, end_time, fs)
epoc_leng = fs*(end_time - start_time);
DATA = zeros(epoc_leng, 3); Label =[];
if strcmp(status, 'train')
    for i=1:3
        filename = ['B0' num2str(subject) '0' num2str(i) 'T.mat'];
        load(filename);
        ind = (typ == 769) | (typ == 770);
        typ = typ(ind);
        typ (typ == 769) = 0; typ (typ == 770) = 1;
        pos = pos(ind);
        for j = 1:length(typ)
%             DATA = [DATA s(pos(i)+(fs*start_time) : pos(i)+(fs*start_time)+epoc_leng-1,1:3)];
            DATA = cat(3, DATA, s(pos(j)+(fs*start_time) : pos(j)+(fs*start_time)+epoc_leng-1,1:3));
            Label = [Label; typ(j)];
        end
    end
    
elseif strcmp(status, 'test')
    for i=4:5
        filename = ['B0' num2str(subject) '0' num2str(i) 'E.mat'];
        load(filename);
        ind = (typ == 783);
        typ = typ(ind);
        pos = pos(ind);
        for j = 1:length(typ)
%             DATA = [DATA s(pos(i)+(fs*start_time) : pos(i)+(fs*start_time)+epoc_leng-1,1:3)];
            DATA = cat(3, DATA, s(pos(j)+(fs*start_time) : pos(j)+(fs*start_time)+epoc_leng-1,1:3));
        end
        oldpath = cd;
        cd true_labels
        load(filename);
        Label = [Label; classlabel];
        cd(oldpath)
    end
    
end
DATA(:,:,1)=[];
DATA = permute(DATA, [2 1 3]);

