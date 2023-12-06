function status = buildApp
    % This function is used to build the app into a standalone OSX app.
    try
        mcc -o TonaFlow -W 'main:TonaFlow,version=1.0' -T link:exe -d ./main/for_testing -v ./main.mlapp 
        movefile('./main','./build');
    catch ME
        status = 0;
        disp(ME);
    end
end