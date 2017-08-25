function success = Send(message)
%SEND sends a message to the connected ESP motor controller.
% Sends a string or character vector through the (already open) serial port
% in ASCII format. Returns true when sent and false if the port is closed.
%
% Usage:
% success = Send(message);
%
% message is the string or character vector to send.
% success is a boolean specifying if the message was sent.
%
% Gabriel Kulp, 2017 Oregon State University

	global ESP;

	success = true;
	
	if isempty(ESP)
		success = false;
		return;
	else
		try
			fprintf(ESP, message);
		catch
			success = false;
			return;
		end
	end
end