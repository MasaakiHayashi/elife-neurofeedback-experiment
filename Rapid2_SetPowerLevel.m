function success = Rapid2_SetPowerLevel(serialPortObj, powerLevel, mode)
% Rapid2_SetPowerLevel
%
% Sets the output power level of the stimulator. Can be used when the
% stimulator is online (armed) or offline (disarmed). 
% 
% - Input arguments
%   serialPortObj - MATLAB object used for communicating with a serial port. See 'help serial'
%   powerLevel - percentage of stimulator's output. Ranges from 0 to 100%
%   mode - 0 means normal mode when stimulator's response will be read.
%          1 means fast mode when stimulator's response will be ignored.
%
% - Output arguments
%   success - 1 if all ok, 0 if there is a problem
%
% - Example:
%   success = Rapid2_SetPowerLevel(serialPortObj, 45, 1)
%
% - Development
%   02.10.2008, Implemented by Arman
%
% - Download page
%   http://www.armanaresearch.org/rapid2matlablibrary.htm

% Let's start
% if there is any leftover in the communication buffer, clear it up
if serialPortObj.BytesAvailable
    out = fread(serialPortObj, serialPortObj.BytesAvailable);
    %char(out)
end

% Ensure that stimulator power is no more than 100%

if powerLevel <= 100

    % Power level converted to string to get digits
    powerLevelString = num2str(powerLevel);
    % Identify number of digits in powerLevel
    numberOfDigits = numel(powerLevelString );
    % is power equal 100% ?
    if numberOfDigits == 3
        powerHundreds = 49; % 1 in ASCII
    else
        powerHundreds = 48; % 0 in ASCII
    end

    % is power level within 10 - 99?
    if numberOfDigits > 1
        powerTens = 48 + str2num(powerLevelString(numberOfDigits - 1)); % ASCII code for tens of power
    else
        powerTens = 48; % 0 in ASCII
    end

    % set the last digit of the power level
    powerUnits = 48 + str2num(powerLevelString(numberOfDigits)); % ASCII code for units of power

    % Calculate checksum for the command (CRC)
    checksum = 64 + powerHundreds + powerTens + powerUnits; % 64 refers to 'set power' command
    % We only need the first 8 bits
    binaryChecksum = dec2bin(checksum);
    numberOfBits = size(binaryChecksum, 2);
    % trim to 8 bits if more than that
    if numberOfBits > 8
        binaryChecksum = binaryChecksum(numberOfBits-7 : numberOfBits);
        % we will need this value later
        numberOfBits = 8;
    end

    % Bit invert the checksum
    binaryInvertedCheckum = binaryChecksum;
    for index = 1:numberOfBits
        if binaryInvertedCheckum(index) == '0'
            binaryInvertedCheckum(index) = '1';
        else
            binaryInvertedCheckum(index) = '0';
        end
    end
    invertedChecksum = bin2dec(binaryInvertedCheckum);

    % Prepare command string to set the stimulator power level
    commandInDecimal = [64, powerHundreds, powerTens, powerUnits, invertedChecksum];
    commandInASCII = char(commandInDecimal);

    % Set the power level
    fprintf(serialPortObj, commandInASCII);

    if ~ mode
        % Wait for the response from the stimulator.
        % If it takes more than a second for the stimulator to respond, ignore it
        tic; elapsed = 0.0;
        while ~serialPortObj.BytesAvailable && elapsed < 1
            elapsed = toc;
        end

        % Read the response from the stimulator if any
        if serialPortObj.BytesAvailable
            out = fread(serialPortObj, serialPortObj.BytesAvailable);
            % char(out)
        end

    end 

end % if powerLeve < 100

success = 1;

