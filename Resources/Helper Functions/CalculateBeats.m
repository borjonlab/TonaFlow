function dum = CalculateBeats(hTim,hMon,Fs,MergeTol, Threshwin)
    Fs = round(Fs);
    if nargin < 4
        MergeTol = 1/Fs;
    end
    
    
    sesLen=hTim(end)-hTim(1);
    %%segment into 1 second windows
    % lseg=1;
    lseg = Threshwin;
    lSes=size(hTim,1);
    Time=zeros(floor(sesLen/lseg),Fs * lseg); 
    for g = 1:floor(sesLen/lseg)
        Time(g,:) = 1+lseg*(g-1)*Fs:lseg*g*Fs;
    end
    % Step through time segments and find peaks > 95 percentile
    spks=[];
    for g=1:size(Time,1)
        seg=hMon(Time(g,:));
        a=prctile(seg,97.5);
        spks=[spks; [Time(g,find(seg>a))/Fs]'];
        clear seg
    end

    mSpks = uniquetol(spks,1/MergeTol);
    mSpks = sort(mSpks);
    
    % Something weird is happening so just check to make sure everything is
    % a column
    if ~iscolumn(hMon)
        hMon = hMon';
    end
    if ~iscolumn(hTim)
        hTim = hTim';
    end

    % Look at every single peak, then find the max within a window. This
    % way the heartbeats occurr at the peak of the heartbeat. Fix courtesy
    % of Mr. Borjon.
    ix = 1:size(hTim,1);
    ix = ix';
    reftab = [ix hTim hMon]; % Reference table
    % reftab(:,2) = round(reftab(:,2), 5);
    win =  20; % Number of element window
    nspk = [];
    for x = 1:size(mSpks,1)
        % this = reftab(reftab(:,2) == mSpks(x),:);
        this = reftab(isequaltol2(reftab(:,2),mSpks(x),1/Fs),:);
        window = reftab(this(1) - (win/2) : this(1) + (win/2),:);
        [m,i] = max(window(:,3));
        nspk = [nspk; window(i,2)];
    end

    dum = zeros(1,ceil(sesLen*Fs)); 
    dum(round(nspk*Fs)) = 1;
    
    %% Debug.
    % figure;
    % plot(hTim,hMon);
    % hold on;
    % plot(hTim(dum==1),hMon(dum==1),'ro')
end

