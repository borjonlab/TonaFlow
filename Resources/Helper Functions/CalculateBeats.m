function dum = CalculateBeats(app,hTim,hMon,Fs,MergeTol, Threshwin)
    Fs = round(Fs);
    if nargin < 4
        MergeTol = 1/Fs;
    end
    
    %% Initialize a UI Progress bar
    dlg = uiprogressdlg(app.TonaFlowUIFigure,'message','Calculating beats...');
    
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
    %%
    dlg.Value = .25;
    %%


    % mSpks = uniquetol(spks,1/MergeTol);
    mSpks = spks;
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
    nspk2 = [];
    for x = 1:size(mSpks,1)
        this = reftab(reftab(:,2) == mSpks(x),:);
        % this = reftab(isequaltol2(reftab(:,2),mSpks(x),1/Fs),:);
        % winix = this(end,1) - (win/2) : this(end,1) + (win/2);
        winix = this(1) - (win/2) : this(1) + (win/2);

        window = reftab(winix(winix>0),:);
        [m,i] = max(window(:,3));
        nspk = [nspk; window(i,2)];
        nspk2 = [nspk2; window(i,1)];
    end
    %%
    dlg.Value = 1;
    %%
    dum = zeros(1,ceil(sesLen*Fs)); 
    % dum(round(nspk*Fs)) = 1;
    dum(nspk2) = 1;
    
    close(dlg);
    %% Debug.
    % figure;
    % plot(hTim,hMon);
    % hold on;
    % plot(hTim(dum==1),hMon(dum==1),'ro')
end

