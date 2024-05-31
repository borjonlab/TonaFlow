classdef ECG_Class
    % ECG_CLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        X_Raw
        Y_Raw
        Fs
        
        X_Filtered
        Y_Filtered
        
        Beats
        HeartRate
        
        Resp_X
        Resp_Y

        Thresholds

        IsSpliced = 0% Has there been data removal performed? 
        X_Spliced
        Y_Spliced
        BeatsSpliced
        SpliceLocations
        
        % How many elements have been edited for size congruence?
        SizeEdits = 0;
    end
   methods(Static) 
        function CheckDataFormat(data)
            %check if it is column, if not, change it to columns for
            %consistency
            if ~iscolumn(data)
                data = data';
            end
            % Check if it is at least two columns. If not, raise an error
            if size(data,2) < 2
                error("ECG_Class:noTimeComponent","Error. \n data must include a time component.")
            end
        end
    end
    
    
    methods
        %% Class Construction
        function obj = ECG_Class(path2ecg)
                        
            % Read in the ECG
            data = readmatrix(path2ecg);
            % Cehck the data format
            obj.CheckDataFormat(data); 
            % Construct the class
            obj.X_Raw = data(:,1);
            obj.Y_Raw = (data(:,2) - mean(data(:,2))) / std(data(:,2));
            obj.Fs = round(1/mean(diff(obj.X_Raw)));

            % Set the filtered to the X_Raw, we do this because the
            % ECG_Filtered is what the user sees, while ECG_Raw is what we
            % act on when filtering or splicing data. 
            obj.X_Filtered = obj.X_Raw;
            obj.Y_Filtered = obj.Y_Raw;
        end


        
        %% Main Functions 
        function self = CalculateHeartRate(self,dum, dt ,Fs,BlurWinLen) %, SmoothingFactor)
            % if nargin < 5
                BlurWinLen = 10;
                SmoothingFactor = .7    ; % For CSAPS
            % end
            
            % Determine if we are operating on a spliced signal or not
            
            if self.IsSpliced
                % remove nans for the time being 
                dumOriginal = dum;
                dtOriginal = dt;
                dum = dum(~isnan(dum));
                dt = dt(~isnan(dum));
            end

            % Construct a blurring window 
            gaussFilter = gausswin(Fs*BlurWinLen);
            gaussFilter = gaussFilter / sum(gaussFilter); %Normalize.
        
            % Blur.
            rate = conv(dum, gaussFilter, 'same') * Fs * 60;
            % if size(dt,2) > size(rate,2)
            %     rate(end+1) = rate(end);
            % end
        
            % if length(rate) < length(dt)
            %     nd = length(dt) - length(rate);
            %     rate(end:end+nd) = rate(end);
            % end
            rate = csaps(dt, rate, SmoothingFactor, dt);
            
            % If it is spliced, reintroduce the noise
            if self.IsSpliced
                for i = 1:size(self.SpliceLocations,1)
                    % dimension check... ugh
                    if iscolumn(rate)
                        rate = rate';
                    end
                    nanpad = nan(1,self.SpliceLocations(i,2) - self.SpliceLocations(i,1));
                    rate = [rate(1:self.SpliceLocations(i,1)), nanpad, rate(self.SpliceLocations(i,1):end)];
                end
            end
            self.HeartRate = rate;
        end


        function self = CalculateBeats(self,hTim,hMon,Fs, Threshwin, PRCT)
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
                a=prctile(seg,PRCT);
                spks=[spks; [Time(g,find(seg>a))/Fs]'];
                clear seg
            end
        
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
                
            dum = zeros(1,ceil(sesLen*Fs)); 
            % dum(round(nspk*Fs)) = 1;
            dum(nspk2) = 1;
            if length(dum) < length(hTim)
                df = length(hTim) - length(dum);
                dum = [dum zeros(1,df)];
            end
            self.Beats = dum;
            %% Debug.
            % figure;
            % plot(hTim,hMon);
            % hold on;
            % plot(hTim(dum==1),hMon(dum==1),'ro')
        end
        

        function self = CalculateRespirationRate(self,rX,resp,Fs)
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

            self.Resp_X = rFTim;
            self.Resp_Y = respRate;
        end



        function self = SpliceECG(self,RemovalRects,app)
            % Indicate that the ECG is now spliced
            if self.IsSpliced == 0
                self.IsSpliced = 1;
            end
            self.X_Spliced = self.X_Filtered;
            self.Y_Spliced = self.Y_Filtered; 
            self.BeatsSpliced = self.Beats;
            
            try %Put these in a try-catch because some of them might have been deleted. If it loops over the deleted one it will throw an error. 
                SpliceLocations = zeros(length(RemovalRects),2); % We just need the X locations. Left is start, right is stop.
                % Grab all of the positions for each cell array
                for i = 1:length(RemovalRects)
                    SpliceLocations(i,:) = round([RemovalRects{i}.Vertices(1,1) RemovalRects{i}.Vertices(end,1)] * self.Fs);
                end
            catch ME 
            end

            beatlocations = zeros(size(SpliceLocations,1),2);
            % Start splicing the data 
            for i = 1:size(SpliceLocations,1)
                % For each location, find the first beat to the left of the first index, and
                % the first beat to the right of the last index. 
                
                % Find nearest leftward beat
                Lxx = find(self.Beats(1:SpliceLocations(i,1)) == 1);
                leftBeat = Lxx(end);

                Rxx = find([zeros(1,SpliceLocations(i,2)) self.Beats(SpliceLocations(i,2):end)] == 1);
                rightBeat = Rxx(1)-1;

                beatlocations(i,:) = [leftBeat rightBeat];
            end

            for k = 1:size(beatlocations,1)
                self.Y_Spliced(beatlocations(k,1):beatlocations(k,2)) = nan;
                self.BeatsSpliced(beatlocations(k,1):beatlocations(k,2)) = nan;
            end
            self.SpliceLocations = beatlocations;
            
        end

        %% Data Checks
        function SizeCheck(self)
            % Sometimes, when performing operations like calculating heart
            % rate, rounding errors will ocurr. These rounding errors are
            % for the most part, unavoidable. So, here we will add a check
            % to make sure all sizes are the same. If not, pad or remove
            % samples. 
            if length(self.Thresholds) < length(self.X_Filtered)
                df = length(self.X_Filtered) - length(self.Thresholds);
                nanpad = nan(1,df);
                self.Thresholds = [self.Thresholds nanpad];

                self.SizeEdits = self.SizeEdits + 1;
            end
        end
    end
end

