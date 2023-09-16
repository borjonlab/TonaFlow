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
    rate = csaps(dt, rate, SmoothingFactor, dt);
end