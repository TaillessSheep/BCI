h = animatedline;
axis([0 4*pi -1 1])
x = linspace(0,4*pi,2000);

k = 1;
while(true)
    
    y = sin(x(k));
    addpoints(h,k,y);
    drawnow

end