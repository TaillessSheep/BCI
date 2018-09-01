clear;clc;
name = 'Will_Aug_27_18_prepro';
load(name);

count = 1;
for i = (1:length(Labels))
    if Labels(i) <= 2
        new_data(:,:,count) = data(:,:,i);
        new_Labels(count) = Labels(i);
        count = count + 1;
    end
end

data = new_data;
Labels = new_Labels;
name = [name '12'];
save (name, 'data','Labels');