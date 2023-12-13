<<<<<<< Updated upstream
<div align="center">
    <img src="https://raw.githubusercontent.com/borjonlab/TonaFlow/main/Resources/TF%20Logo%20Darkmode.png" width="400">
=======
<!-- <html>
    <style>
        .subtitle   {color: #64C7E9;
                    margin-bottom:-10px},
        .center {
                    display: block;
                    margin-left: auto;
                    margin-right: auto;
                    width: 50%;
                }
    </style>
</html> -->

<h1 align='center'>TonaFlow - A Free Program for ECG Processing</h1>

<!-- // Tonaflow logo -->
<p align='center'>
    <img src='./Resources/devsys_logo.png' height=100> 
</p>
<p align='center'>
    <img src=https://i.imgur.com/SftJL0e.png height=190> 
</p>

<!-- Start -->

<h1 class = 'subtitle'> About </h1>

---

TonaFlow is a free and open-source program that aims to make standardized ECG processing free and easy for everyone.

TonaFlow is currently under heavy development, expect changes as time passes.

<h1 class = 'subtitle'> Authors and Collaborators </h1>

---

- Manash Sahoo - University of Houston, TIMES
- Jeremy I. Borjon - University of Houston, TIMES

<h1 class = 'subtitle'> Table of Contents </h1>

___

- [Installation](#install)
  - [Mac](#install_mac)
  - [Windows](#install_windows)
  - [Linux/Debian](#install_linux)
  - [Running with MATLAB](#install_matlab)
- [Usage](#usage)
  - [Data Formatting](#usage_dataformatting)
  - [Data Traversal](#usage_datatraversal)
  - [Filtering](#usage_filtering)
  - [Finding Heart Beats and Calculating Heart Rate](#usage_heartbeats)
  - [Adding and Removing Heart Beats](#usage_addremoval)
  - [Removing Sections of Data](#usage_dataremoval)
  - [Exporting Data](#usage_exportdata)
  - [Saving/Loading a Project](#usage_saveload)
  - [Calculating Respiration Rate using the CWT](#usage_resprate)
- [Under the Hood](#dev)
  - [Filtering with the CWT](#dev_filt)
  - [Finding Heartbeats using Dynamic Thresholding](#dev_threshholding)
  - [Calculating Heart Rate using Convolution](#dev_conv)
  - [Removing Data when using Convolution](#dev_removal)

<h1 name = 'install' class = "subtitle" > Installation </h1>

---
Before installing into <strong> any </strong> OS, the MATLAB Runtime environment is required. You can download this for your respective OS [here](https://www.mathworks.com/products/compiler/matlab-runtime.html).

<h3 name = 'install_mac'> Mac OSX </h3>

In `build/for_testing/`, Move `TonaFlow.app` into your applications folder. Double-click to run. 

<h3 name = 'install_windows'> Windows </h3>

<h3 name = 'install_linux'> Linux/Debian </h3>

<h3 name = 'install_mac'> Running with MATLAB</h3>
If you have a MATLAB license, TonaFlow can be run directly in the environment.

1. Download the zip or clone the repository using Git
2. Unzip the folder in an enclosing folder of your choice
3. Change your MATLAB working directory to `.../TonaFlow/`
4. Run `main` in the command window

<h1 name = 'usage' class='subtitle'> Usage </h1>

---

<h3 name = 'usage_dataformatting'> Data Formatting </h3>

To maximize access, TonaFlow only accepts data from a `.csv` or `.xlsx`. These are ubiquitous file types used by the majority of systems.

The contents of your file should follow the following format, with the first column being time in seconds, and the second column being measurement:

<div align=center>

| $t$ | $ECG$  |
| --- | ------ |
| 0.1 | $1100$ |
| 0.2 | $1200$ |
| 0.3 | $1300$ |
| 0.4 | $800$  |
| ... | $...$  |

>>>>>>> Stashed changes
</div>

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
