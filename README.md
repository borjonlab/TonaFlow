
<img src="https://raw.githubusercontent.com/borjonlab/TonaFlow/main/Resources/TF%20Logo%20Darkmode.png" width="480">


TonaFlow is an application that allows users to analyze electrocardiogram (ECG). 
This application is young and under heavy development. Please feel free to suggest any changes or features via email at manash.sahoo@times.uh.edu.

## Source Requirements
Development for this application will require the following MATLAB toolboxes: 
1. Image Processing Toolbox
2. Signal Processing Toolbox
3. Curve Fitting Toolbox

## Getting Started
____
### ECG Format
ECG files should be stored in a CSV format with the first column being **time**, and the second column being the **ecg measurement.**
There should be **no other data in the file.** TonaFlow will automatically detect your ECG's sampling rate. 

Click **File > Import ECG** to load your file. 

### Running Beat Detection
Once you have loaded in an ECG, you can run the beat detection algorithm via **ECG > Run Beat Detection.** There are several options in the configuration dialog. 

&nbsp; _1. Merge Tolerance_ - When the algorithm detects values above a certain threshold (ie your heart beat), this will result in a multitude of points. This needs to be converted to a single value that represents the heartbeat. 
These values are merged together within a specific tolerance, via the matlab function `uniquetol()`. From the [documentation](https://www.mathworks.com/help/matlab/ref/uniquetol.html), 
two values (u and v) are within tolerance if `abs(u-v) <= tol*max(abs(A(:)))`. By default, the value is set to `1/Fs`, where Fs is the sampling rate.

&nbsp; _2. Convolving Window_ - Converting beats to a rate works by sliding a gaussian window across the binary representation of heart beats (ie, convolving). This size of this window can be adjusted, but is by default a **10 second window.**


### Removing sections of data
In certain events, you may want to remove a section of data due to irrelevance or low quality. In these situations, you can click on the **"select data for removal"** button on the right side. Once this has been selected, you can
use the mouse to drag a rectangle over the data you want to remove. Be careful, there is no undo button! An ability to undo actions will be added in the future. 

### Manually Adding and Removing Heart Beats
Our beat detection algorithm is really awesome. But, sometimes it doesn't capture everything. If there is a heartbeat that is obviously a beat but wasn't detected as such, you can click on any of the points in the ECG and select the
**Add Heartbeat(s)** button. Likewise, you can also select points and remove them using the **Remove Heartbeat(s)** button. 
