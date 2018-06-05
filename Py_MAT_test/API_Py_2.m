function API_Py_2(times)
    
    y = zeros(1,1000);
    x = (-999:0);
    
    for i = (1:times)
        for j = (1:300)
            y = wshift('1D',y,1);
            y(1000)= sin(2*pi*j/300);
        end
    end

    plot(x,y);
    drawnow
end