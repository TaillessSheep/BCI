TrainSet = ones(1,1,210); 
Labels = ones(1,210);
TrTrial = 210;

for i = (1:210)
    TrainSet(1,1,i) = i;
end

valsets_num = 10;

for i = (1:21:TrTrial)
    diap(i)
    val = TrainSet(:,:,i:i+TrTrial/valsets_num-1);
    val_label = Labels(1,i:i+TrTrial/valsets_num-1);
    will = TrainSet(:,:,[1:i-1 i+TrTrial/valsets_num:end]);
    will_label = Labels(1,[1:i-1 i+TrTrial/valsets_num:end]);
    
end
