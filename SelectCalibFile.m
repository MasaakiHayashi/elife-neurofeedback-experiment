
[CalibFileName,PathCalibFile] = uigetfile('*.mat','Select a calib. file');
% addpath('PathCalibFile');

uiopen(CalibFileName,'True')

set(UIDispCalib,'string',CalibFileName);