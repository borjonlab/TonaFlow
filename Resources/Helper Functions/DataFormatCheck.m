function [flag,errormsg] = DataFormatCheck(data)
    % Check that the data is of two columns
    if size(data,1) < 2 | size(data,1) > 2
        flag = 0;
        errormsg = 'Data has either less or more than 2 columns.';
        return;
    end

    % Check if time column has any duplicate values
    if unique(data(:,1)) ~= size(data,1)
        flag = 0;
        errormsg = 'Duplicates found in time axis';
        return;
    end
end

