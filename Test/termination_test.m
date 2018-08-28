function termination_test ()
changeup = onCleanup(@CleanupScript);
global i;
i = 0;
while true
    disp(i)
    i = i + 1;
end
end