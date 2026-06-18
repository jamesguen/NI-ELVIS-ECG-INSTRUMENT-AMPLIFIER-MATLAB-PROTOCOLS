# NI-ELVIS-ECG-INSTRUMENT-AMPLIFIER-MATLAB-PROTOCOLS
Hardware design for an ECG instrumentation amplifier using NI ELVIS, paired with MATLAB protocols for signal processing, filtering, and analysis.

Waveforms Directory
The waveforms folder serves as the central data depository for the raw data inputs required by the processing script. It must contain the raw csv files generated during data acquisition, specifically Lead_I_Relaxed_02.csv and Lead_II_Relaxed.csv. These files provide the high-resolution voltage values and timeline markers used in the software scripts.

Instrument Amp Calibration
The script Instrument_Amp_Calibration.m handles the calibration and performance assessment of the physical instrumentation amplifier circuit. It uses ordinary least squares linear regression via the polyfit function to map common-mode input voltages against measured outputs to estimate the common-mode gain factor. It also performs differential gain fitting across a range of input values to determine the overall differential gain. By combining these measurements, the script calculates the common-mode rejection ratio, which describes the ability of the circuit to reject ambient noise. Finally, it evaluates the experimental frequency response against a theoretical bandpass filter model to map the amplification behavior across a frequency band from 0.1 Hz to 10 kHz.

Extract Lead Data Function
The script extractLeadData.m is a modular pre-processing function that cleans raw electrocardiogram voltage sequences. It begins by removing low frequency baseline drift caused by respiration or movement using a second-order polynomial detrending algorithm. The signal is then passed through a two-stage digital filter cascade consisting of a fourth-order lowpass infinite impulse response filter with a half-power frequency of 200 Hz and a sixteenth-order bandstop infinite impulse response filter to eliminate powerline interference. Because filtering can attenuate physiological features, the function automatically detects individual QRS complex peaks and scales the attenuated waveforms back to their true physiological amplitudes. The clean data array, timeline vector, and peak locations are dynamically saved into an output MAT file for downstream analysis.

Lead III Reconstruction
The script Lead_III_Reconstruction.m reconstructs the unmeasured Lead III cardiac vector, computes ensemble averages, and calculates the absolute electrical axis of the heart. Using Einthoven's Law, the script subtracts Lead I from Lead II to generate the Lead III waveform. It avoids slow iterative loops by utilizing a vectorized indexing matrix to isolate, align, and overlay individual heartbeats based on detected R-wave peaks. It then calculates the mean cardiac axis by resolving baseline-corrected R-wave peaks into orthogonal X and Y components and evaluating the complex angle using the four-quadrant inverse tangent function to determine the net direction of ventricular depolarization in degrees.

Lead Denoise Analysis
The script Lead_Denoise_Analysis.m provides comprehensive graphical confirmation of the digital signal processing pipeline effectiveness in both the time and frequency domains. It tracks the composite transfer magnitude response of the lowpass and bandstop filters working in unison to prove the algorithmic integrity. Additionally, the script computes and plots the power spectral density using a periodogram to visually demonstrate noise mitigation, explicitly comparing the raw out-of-band energy profiles against the cleaned data stream.

Authorship
All software protocols and processing algorithms included in this repository were originally conceptualized and coded by James Guentert.
