function API_Py_1(x)

%     x_min = x(1);
%     x_max = x(size(x,2));
%     if ~exist('y_min','var'), y_min = -2; end
%     if ~exist('y_max','var'), y_max = 2; end
    global time y;
    y = wshift('1D',y,1);
    y(length(y)) = x;
    plot(time,y);
%     axis([x_min x_max y_min y_max]);
    drawnow
end