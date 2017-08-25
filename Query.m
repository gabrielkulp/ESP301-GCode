function response = Query(message, isString, timeout)
%QUERY Sends a message to the connected ESP device and awaits a response.
% This function lets you specify if you expect a string or numeric
% response, and automatically collects multiple responses.
%
% Usage:
% response = Query(message, [isString], [timeout]);
%
% message is a character vector or string of the ASCII to send the ESP.
% isString is an optional flag. When true, the response is not parsed for
%	numbers and multiple responses are returned in a cell array. When
%	false, responses are parsed for numbers and stored in an array.
%	Defaults to false.
% timeout is an optional argument for how long to wait ( in seconds) for a
%	response before returning an empty array or cell array. Defaults to 1
%	second.
%
% Gabriel Kulp, 2017 Oregon State University

	global ESP
	if isempty(ESP)
		response = '';
		return;
	end

	if (nargin < 3)
		timeout = 1;
	end
	if (nargin < 2)
		isString = false;
	end

	if (isString)
		response = '';
	else
		response = [];
	end

	oldTO = ESP.Timeout;
	ESP.Timeout = timeout;

	% There shouldn't be anything in BytesAvailable right now, so clear it.
	flushinput(ESP);

	success = Send(message);

	if ~success
		response = '';
		ESP.Timeout = oldTO;
		return;
	end

	firstRead = true; % Or else it'll skip past the whole while loop

	warning('off','MATLAB:serial:fscanf:unsuccessfulRead');

	while (firstRead || ESP.BytesAvailable > 1)
		responseRaw = fscanf(ESP);

		if (~isempty(responseRaw))
			if (isString)
				response{length(response)+1} = responseRaw(1:length(responseRaw)-1);
				% Trims off odd ends.
			else
			response = [response; str2num(responseRaw)];
			% Output isn't always a double, so use str2num
			end
		end
		firstRead = false;

	end
	warning('on','MATLAB:serial:fscanf:unsuccessfulRead');
	ESP.Timeout = oldTO;
	% response already set.
end