function respRate = CalculateRespirationRate(rX,resp,Fs)
    sesLen=rX(end);
    rFs=Fs;
    rFTim=1/rFs:1/rFs:sesLen;
    
    lseg=1;
    lSes=size(rX,1);
    Time=zeros(floor(sesLen),Fs);
    for g = 1:floor(sesLen)
        Time(g,:) = 1+lseg*(g-1)*Fs:lseg*g*Fs;
    end
    
    rTime=zeros(floor(sesLen),rFs);
    for g = 1:floor(sesLen)
        rTime(g,:) = 1+lseg*(g-1)*rFs:lseg*g*rFs;
    end
    
    rResp=resample(resp,rX,Fs);
    sResp=csaps(rFTim,rResp(1:numel(rFTim)),0.3,rFTim);
    % Hd = highPass1_50Fs;
    % fResp=filtfilt(Hd.numerator,1,sResp);
    % 
    fResp = sResp;
    
    
    
    % nResp=prctileDat(fResp);
    nResp = fResp;
    
    
    hResp=angle(hilbert(detrend(nResp)));
    
    [x0,y0,iout,jout]=intersections(rFTim,hResp(1:numel(rFTim)),rFTim,zeros(size(rFTim)));
    respPeaks=round(x0*rFs);
    
    peakCheck=([hResp(respPeaks-1')' hResp(respPeaks+1)']);
    respPeaks=respPeaks(find(abs(diff(peakCheck'))<1));
    respPeaksLoc=respPeaks/rFs;
    
    % % respPeaksLoc=respPeaks/rFs;
    % useThese=builtin('_mergesimpts',respPeaksLoc,1/2,'average')';
    useThese = uniquetol(respPeaksLoc,1/Fs);
    dum=zeros(1,floor(sesLen*rFs));
    
    % useThese(152:153) = [367.5 369.1];
    
    dum(round(useThese*rFs))=1;
    gaussFilter = gausswin(rFs*15);
    gaussFilter = gaussFilter / sum(gaussFilter); % Normalize.
    
    % Do the blur.
    respRate = conv(dum, gaussFilter,'same')*rFs*60;
    respRate=csaps(rFTim,respRate,0.9,rFTim);
end

