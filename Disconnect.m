 function Disconnect(reset)
 %DISCONNECT Disconnects from the connected ESP device.
 % Clears the group motion buffer and removes the group. If the reset flag
 % is true, also stops motion and power cycles the ESP. Closes and clears
 % all instrfind output, so this command could disrupt any other
 % instruments. This function does nothing when already disconnected.
 %
 % Usage:
 % Disconnect([reset]);
 %
 % reset is an optional flag. When true, the function attempts to reset
 %	MATLAB and the ESP. When false it does not. Defaults to false.
 %
 % Gabriel Kulp, 2017 Oregon State University
 
	global ESP;

	if (nargin < 1)
		reset = false;
	end

	Group(false); % Delete group

	if (reset)
		try
			ESP.Timeout = 1;
		end % Don't care if fails.
		Send('AB;'); % Abort motion. Does nothing if fails.
		Send('RS;'); % Reset
	end

	flushinput(ESP);
	ESP = [];

	allInstruments = instrfind;

	try
		fclose(allInstruments);
	end
	% Don't care if these fail.
	try
		delete(allInstruments);
	end
end
