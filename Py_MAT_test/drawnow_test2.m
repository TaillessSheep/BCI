h = animatedline('MaximumNumPoints',1000);
axis([0,4*pi,-1,1])

x = linspace(0,8*pi,2000);
y = sin(x);
for k = 1:length(x)
    addpoints(h,x(k),y(k));
    drawnow
end