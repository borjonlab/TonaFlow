function rate = CalculateHeartRate(dum, dt ,Fs,BlurWinLen, SmoothingFactor)
    if nargin < 5
        BlurWinLen = 10;
        SmoothingFactor = .9; % For CSAPS
    end
    % Construct a blurring window 
    gaussFilter = gausswin(Fs*BlurWinLen);
    gaussFilter = gaussFilter / sum(gaussFilter); %Normalize.

    % Blur.
    rate = conv(dum, gaussFilter, 'same') * Fs * 60;
    % if size(dt,2) > size(rate,2)
    %     rate(end+1) = rate(end);
    % end

    if size(rate,2) < size(dt,2)
        nd = size(dt,2) - size(rate,2);
        rate(end:end+nd) = rate(end);
    end
    rate = csaps(dt, rate, SmoothingFactor, dt);
end