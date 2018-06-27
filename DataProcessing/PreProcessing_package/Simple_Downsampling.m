function [ Train, Test ] = Simple_Downsampling( Train_set,Test_set )

for i = 1:size(Test_set,3)
    for j = 1:size(Test_set,1)
        for m = 1:350
%         if (isnan(Test_set(j,m*10,i))==1)
%             Test(j,m,i) = 0;
%         else
             Avgts = (Test_set(j,(m*10),i));
             Test(j,m,i) = Avgts;
             
        %end
        
        end
    end
end

for i = 1:size(Train_set,3)
    for j = 1:size(Train_set,1)
        for m = 1:350
%         if (isnan(Train_set(j,m*10,i))==1)
%             Train(j,m,i) = 0;
%         else
             Avgtr = (Train_set(j,(m*10),i));
             Train(j,m,i) = Avgtr;
             
%         end
            
        end
    end
end
end

