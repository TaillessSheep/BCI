function update(x)

    global max time y f titles;
    
    for i = (1:14)
        y.(char(titles(i))) = wshift('1D',y.(char(titles(i))),1); % whift data by 1
        y.(char(titles(i)))(max) = x(i);
        
%         figure(f);
        if i==1
%             subplot(7, 2, i);
            plot(time,y.(char(titles(i))));
            title(titles(i));
%         axis([x_min x_max y_min y_max]);
            drawnow
        end
    end
end