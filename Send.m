function success = Send(message, noLog)
%SEND sends a message to the connected ESP motor controller.
% Sends a string or character vector through the (already open) serial port
% in ASCII format. Returns true when sent and false if the port is closed.
%
% Usage:
% success = Send(message, [noLog]);
%
% message is the string or character vector to send.
% noLog is an optional bool. Set to true, the command will not be logged
%	locally. Set to false, it will be logged. Defaults to false.
% success is a boolean specifying if the message was sent.
%
% Gabriel Kulp, 2017 Oregon State University

	global ESP;

	if nargin < 2
		noLog = false;
	end
	
	success = true;
	
	if isempty(ESP)
		success = false;
		return;
	else
		try
			if ~noLog
				fprintf('%s\n', message);
			end
			fprintf(ESP, message);
		catch
			success = false;
			return;
		end
	end
end