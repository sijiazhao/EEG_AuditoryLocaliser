# EEG_AuditoryLocaliser
This repository contains the EEG experimental code to present brief pure tones (>=180 tones, f=500Hz, duration=150ms). Tones are presented with an inter-sound interval randomised between 1 and 1.5 seconds. Participants are instructed to count the number of pure tones with their eyes naturally opened. 
It also contains a simple ERP analysis script for preprocessing and plotting ERP and topography.

## Special notes
1. The EEG used here is 64 channel Biosemi system (Biosemi Active Two AD-box ADC-17, Biosemi, Netherlands).
2. You need Psychtoolbox to run this experimental script (http://psychtoolbox.org/).
3. There is one line in this script you must update based on your setup: soundcard channels. Search '#CHANGETHIS#'.
4. For analysis script, you need to download fieldtrip (https://www.fieldtriptoolbox.org/).

Copyright (c) 2021, Sijia Zhao.  All rights reserved.
Contact: sijia.zhao@psy.ox.ac.uk
