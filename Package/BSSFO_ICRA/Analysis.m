function [ output ] = Analysis( res, ExCode )
 c=zeros(1,4);
for i=1:length(res)
    for j=1:4
        s = ExCode{j};
        s = s(i);
        if res(i) == s
            c(j) = c(j)+1;
        end
    end
end
L =1:4;
output = L(c == max(c));
output = output(1);
            


end

