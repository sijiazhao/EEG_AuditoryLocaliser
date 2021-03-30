%% EEG auditory localiser
% Measurement of auditory ERP to pure tones
% This is the EEG experimental code to present brief pure tones (>=180 tones, f=500Hz, duration=150ms). 
% Tones are presented with an inter-sound interval randomised between 1 and 1.5 seconds. 
% Participants are instructed to count the number of pure tones with their eyes naturally opened. 
% EEG: 64 channel Biosemi system (Biosemi Active Two AD-box ADC-17, Biosemi, Netherlands)
% Note01: You need Psychtoolbox to run this experimental script (http://psychtoolbox.org/).
% Note02: There is one line in this script you must update based on your setup: soundcard channels. Search '#CHANGETHIS#'. 
% Copyright (c) 2019, Sijia Zhao.  All rights reserved.
% Contact: sijia.zhao.10@ucl.ac.uk

clear;
close;
format shortg;

Screen('Preference', 'SkipSyncTests', 1);

triggerlength = 220; % the length of trigger: send this to EEG recorder at each tone onset
a = 180:1:200; % number of pure tones. Randomised for each subjects.
b = randperm(length(a));
ntones = a(b(1));

durtone = 0.15;      % sound duration in second
ISI = 1:0.1:1.5; % inter-stimulus interval in ms

ShowHideWinTaskbarMex(0) % hide windows taskbar during presentation

%% Prepare puretone
freq = 500; % tone frequency
cf = 1000; % carrier frequency (Hz)
sf = 44100; % sample frequency (Hz)
ns = sf * durtone; % number of samples

signal = (1:ns)/sf; % sound data preparation
signal = sin(2*pi*freq*signal);   % sinusoidal modulation
signal = signal.*r;   % make ramped sound
signal = signal*0.9;

%% Prepare trigger (used for EEG analysis)
trigger = zeros(size(signal));
trigger(1:triggerlength) = 0.9;

%% Add trigger to the sounds + make them stereo
signal = [trigger; signal; signal];
nchans = 3; % 1st channel for trigger, the last two for headphone

%% Initialise soundcard and acoustic setup
InitializePsychSound(1); % start psychtoolbox sound module
pahandle = PsychPortAudio('Open', [], [], 3, sf, nchans, [], [], [4 6 7]); %  #CHANGETHIS# [4 6 7] NEEDED TO BE CHANGED BASED ON YOUR SOUNDCARD!
PsychPortAudio('RunMode', pahandle, 1); % the audio hardware and processing don't shut down at the end of audio playback. Instead, everything remains active in a ''hot standby'' state. This allows to very quickly (with low latency) restart sound playback via the 'RescheduleStart' function.
handle_ptone = PsychPortAudio('CreateBuffer', pahandle, signal); % create a buffer for puretone
PsychPortAudio('UseSchedule', pahandle, 1, 1);

%% Prepare background screen and fixation cross
HideCursor;
AssertOpenGL; % error message if psychtoolbox not installed
screenchosen = Screen('Screens'); % gets list of screens
screenNumber = max(screenchosen); % chooses highest screen number.
white = WhiteIndex(screenNumber); % find colour value for white
black = BlackIndex(screenNumber); % find colour value for black
gray = round((white+black)/2); % round gray to avoid any probs w graphic card
if gray == white % check to get defined gray
    gray = white/2;
end

gray2 = gray*0.8; % creates a slighly darker gray for the fixation crossinc=white-gray; % Contrast 'inc'rement range for given white and gray values:
inc = white-gray; % Contrast 'inc'rement range for given white and gray values:

[w, screenRect] = Screen('OpenWindow',screenNumber, gray); %% OPEN PTB SCREEN  % Open double buffered window
[X,Y] = RectCenter(screenRect);%get central coordinates
FixCross = [X-1,Y-6,X+1,Y+6;X-6,Y-1,X+6,Y+1];%create fixation cross
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % Enable alpha blending for proper combination of the gaussian aperture

%% prepare instruction text
expload = 'EEG localiser';
expend = 'End.';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   start presentation   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DrawFormattedText(w, expload, 'center', 'center', 0); % present text on screen
Screen('Flip',w);
KbWait; % wait for keyboard input
Screen('FillRect',w,[0 0 0], FixCross');  % present fixation cross
Screen('Flip',w);
WaitSecs(2);

for t = 1:ntones % pure tone trials loop
    % use the following 2 lines to actually play a sound:
    [success, freeslots] = PsychPortAudio('AddToSchedule', pahandle, handle_ptone);
    PsychPortAudio('Start', pahandle);
    WaitSecs((ISI(randi(numel(ISI)))));
end
Screen('FillRect',w,[0 0 0], FixCross');
vbl = Screen('Flip', w);
DrawFormattedText(w, expend, 'center', 'center', 0); % present 'end' text
Screen('Flip',w);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   end presentation   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

KbWait;
Priority(0); %restore normal priorities
Screen('CloseAll');
Priority(0);
psychrethrow(psychlasterror);
PsychPortAudio('Close');
ShowHideWinTaskbarMex(1); % display windows taskbar again

disp(['***']);
disp(['...number of tones = ' num2str(ntones)]);
