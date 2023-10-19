function [thr, Time] = PreviewThreshold(ECGx,ECGy, prc, Fs, Threshwin)
    % Function to preview the thresholding from the beat detection dialog
    % window.
    sesLen=ECGx(end)-ECGx(1);
    %%segment into 1 second windows
    % lseg=1;
    lseg = Threshwin;
    lSes=size(ECGx,1);
    % Time=zeros(floor(sesLen/lseg),floor(Fs * lseg));  % Added ceil
    Time = zeros(floor(sesLen/lseg),ceil(Fs*lseg));
    for g = 1:floor(sesLen/lseg)
        Time(g,:) = 1+lseg*(g-1)*Fs:ceil(lseg*g*Fs); % Added ceil
    end
    % Step through time segments and find peaks > 95 percentile
    spks=[];
    thr = zeros(1,size(ECGx,2));
    for g=1:size(Time,1)
        seg=ECGy(Time(g,:));
        a=prctile(seg,97.5);
        thr(Time(g,:)) = repelem(a,1,size(Time,2));
        spks=[spks; [Time(g,find(seg>a))/Fs]'];
        clear seg
    end
    

    if length(thr) < length(ECGx)
        % Add padding to the thr
        df = length(ECGx) - length(thr);
        thr = [thr nan(1,df)];
    end
    % thr = reshape(thr,1,size(thr,1)*size(thr,2));
    % if size(thr,2) < size(ECGx,2)
    %     df = size(ECGx,2) - size(thr,2);
    %     thr = [thr repelem(thr(end),1,df)];
    %     % thr(end:df) = thr(end-1);
    % end
end