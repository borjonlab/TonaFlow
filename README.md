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

<h3 name = 'install_mac'> Mac OSX </h3>

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

</div>

There should be no duplicate values in column $t$, and both columns should be of the same length.

There is no need to include a sampling rate with your file. Sampling rate can be estimated from column $t$, by using the equation

$$ Fs = \frac{1}{mean(\frac{d}{dt}(t))}$$

<h3 name = 'usage_datatraversal'> Data Traversal </h3>

---

Because TonaFlow is built using the MATLAB GUI Designer, it utilizes the standard MATLAB plots. In short, there are 3 main buttons on the top right of the axes that you will use while using TonaFlow.

1. Zoom In
2. Zoom Out
3. Home

<h3 name = 'usage_dataformatting'> Using the arrow keys </h3> 
Sessions can be very long, and take a while to parse through. While you can click and drag along the plot to move along the X axis, this can be tiresome. If you make sure that the axes is "focused" by first clicking on it, you can use the left and right arrow keys to move along the Y_Axis.

Change the `Keypress Factor` edit field, to edit the amount of step for each keypress.

<h3 name = 'usage_filtering'>Filtering</h3>

---

Sometimes, electrocardiograms include artifacts or oscillatory noise due to movement or breathing. While TonaFlow can handle some amounts of oscillation, it is best practice to filter these signals.

While many tools use traditional butterworth filters to filter frequencies, TonaFlow uses the Continuous Wavelet Transform (CWT). You can read more about wavelets [here]() or the MATLAB `cwt` function [here]().

After loading a signal, click `ECG` on the top toolbar, and then `Filter with CWT`.
![Imgur](https://i.imgur.com/b1H5qcl.png)

This will bring up the CWT Bandpass window.
![Imgur](https://i.imgur.com/PawfrvY.png)
Adjust the upper and lower frequency values to effectively remove low and high oscillatory noise. In many ECG recordings, low oscillatory noise corresponds to variation in respiration, while high oscillatory noise corresponds to movement. In any case, these are unwanted portions of the signal.

The frequency bounds in the CWT Bandpass window automatically populate to the possible frequency bounds of the signal. Adjust these frequencies until the ECG is as free of noise as possible. In this case, passing frequencies under 1Hz significantly cleans the signal.

![Imgur](https://i.imgur.com/0LslqKx.png)

Now, our signal is sufficiently proecessed to make beat detection easier and more efficient.

<h3 name = 'usage_heartbeats'>Finding Heart Beats and Calculating Heart Rate</h3>

---

In order to calculate heart rate, we need to detect where these beats are happening. To begin calculating heart rate and finding heart beats, go to `ECG` and click `Calculate Heart Rate`.
![Imgur](https://i.imgur.com/GtMtMyH.png)

This will bring up the beat detection window.
![Imgur](https://imgur.com/QnYcnMY.png)
This window is designed to allow users to preview their threshold as they adjust parameters. Adjust the `Preview Size` edit field to view a smaller or larger window of data, and use the bottom slider to traverse across the X-axis.

### Specifying a Threshold Window

TonaFlow calculates heartbeats through use of a <strong> dynamic threshold</strong>.
This threshold is calculated every 1 second by default. If you find that your threshold is varying too much, then adjust this value.

### Absolute Value

Sometimes, R peaks can manifest in different ways. Sometimes, they pertrude upwards while other times, they pertrude only downwards. You can select the `Use Absolute Value` checkbox to perform the detection on the ABS of the signal, that way downwards R peaks are not missed.

### Convolution Window Size

To calculate heart rate, TonaFlow convolves an $N$ second long gaussian kernel across the heartbeats. To change this, change the value of the `Convolution Window Size` edit field. For more information about convolution, visit the [Under the Hood](#dev) section.

By default, TonaFlow constructs a 10-second gaussian kernel of the form (For more information visit [the MATLAB documentation for `gausswin`](https://www.mathworks.com/help/signal/ref/gausswin.html)):

$$ w(n) = e^{-\frac{1}{2}(\sigma \frac{n}{(L-1)/2})^2} $$



<h3 name = 'usage_addremoval'>Adding and Removing Heartbeats</h3>

---
While dynamic thresholding can be a simple and powerful method for finding heartbeats, sometimes some heartbeats can be missed. If these R peaks can be identified by eye, then it is useful to add them back in. 

![](https://i.imgur.com/lA0vEgr.png)

Click anywhere on the signal to add a point. A small datatip will appear. Then, click the `Add Heartbeat(s)` button.

Likewise, to remove heartbeats, you can also click on any heartbeat to select it, and click the `Remove Heartbeat(s)` button.


<h3 name = 'usage_dataremoval'>Removing Sections of Data</h3>

---
In some situations, sections of data may be completely unusable, or they may be completely irrelevant and thus should be excluded. In TonaFlow, we have made this an easy process. 


For more information about how TonaFlow removes sections of data, visit the [Under the Hood Section](#dev).

After calculating heart rate from your ECG signal, click the `Enter Removal Mode` button.

![Imgur](https://i.imgur.com/AKwOGvU.png)


This will enable "removal mode". This mode allows you highlight sections of data for removal. To highlight data while in "removal mode", click the `Select Data for Removal` button. Click and drag over the section of data you wish to remove. 

![Imgur](https://i.imgur.com/yiEJJfe.png)

Once you are satisfied with your selection, click the `Enter Removal Mode` button again to exit removal mode. Heart rate will automatically be re-calculated. 

![Imgur](https://i.imgur.com/um0COo6.png)

If you decide that you want to move or delete this selection, simply toggle `Enter Removal Mode` again to enter removal mode. Then, you can either move your selection or right-click the selection and click `Delete Rectangle`.
![](https://imgur.com/wK0iog1.png)



<h3 name = 'usage_exportdata'>Exporting Data</h3>

---
To export *all* data, click `File >> Save... >> All Contents`. 

![](https://imgur.com/Q2xLmVB.png)

This will save the heart rate, heart beat locations, and respiratory rate (if calculated) as a `.csv`. For example, an exported session may look something like this:

<div align = center>

| $t$ | $Heart Rate$ | $Heart Beats$ | $Respiratory Rate$ |
| --- | ------ | ------ | ------ |
| 0.1 | $100$ | $0$ | $30$
| 0.2 | $120$ | $0$ | $30$
| 0.3 | $130$ | $1$ | $31$
| 0.4 | $100$  | $0$ | $34$
| ... | $...$  | $...$ | $...$

</div>


You can use `File >> Save... ` and the other options to save data piece-wise. 



<h3 name = 'usage_saveload'> Saving a Project </h3>

___

ECG signals can be long, and consequently may take a bit of time to review. You may also want to save the processing as a reference for future use. 

TonaFlow allows you to save pre-processing sessions as a `.Flow` file. 

To save a project, click `File >> Save Project File`. Conversely, to load a project, click `File >> Load Project File`. 

For more information about the structure of `.Flow` files, take a look at the [Flow File Structure](#dev_flowfile) portion of [Under the Hood](#dev).




<h3 name = 'usage_resprate'> Calculating Respiration Rate </h3>

___
In some ECG signals, variation due to respiration manifests as low-frequency oscillations. Take for example the following signal:
![](https://imgur.com/LpJjAJY.png)

This signal has a clear low-frequency oscillation that could very well be the respiration signal. While TonaFlow also uses the Continuous Wavelet Transform to filter signals, TonaFlow also uses it to extract specific frequencies (i.e. the respiratory signal) from the ECG. For more information on this topic, visit the [Under the Hood](#dev) section.

To start, navigate to the `ECG` submenu and select `Extract Respiratory Signal`.
![](https://imgur.com/mTMUMXj.png)

This will bring up the Respiratory Extraction window. 
![](https://imgur.com/t9qIZbi.png)

Adjust your upper and lower frequencies accordingly, until the signal resembles the low frequency oscillations in your data. In some ECG signals, these frequencies can manifest in the R-peaks, or the "baseline" of the ECG. Thus, you can use the Y adjust slider to move the signal up or down to determine goodness of fit.







<h1 name = 'dev' class = 'subtitle' > Under the Hood </h1>

---



<h3 name = 'dev_filt'> CWT Filtering </h3>

___