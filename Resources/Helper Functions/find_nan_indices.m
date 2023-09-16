function nan_indices = find_nan_indices(data)
    nan_indices = {};
    current_nan_start = NaN;
    
    for i = 1:length(data)
        if isnan(data(i))
            if isnan(current_nan_start)
                current_nan_start = i;
            end
        elseif ~isnan(current_nan_start)
            nan_indices{end+1} = [current_nan_start, i-1];
            current_nan_start = NaN;
        end
    end
    
    % Check for NaNs at the end of the sequence
    if ~isnan(current_nan_start)
        nan_indices{end+1} = [current_nan_start, length(data)];
    end
end