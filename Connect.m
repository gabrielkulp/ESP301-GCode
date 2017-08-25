function success = Connect()
%CONNECT Connects to an ESP301 device if present.
% Opens a serial connection to an ESP device and initializes it to default
% acceleration, deceleration, velocity, etc.
%
% Usage:
% success = Connect();
%
% success is a boolean that is true when the connection is successfully
%	created and false when not.
%
% Gabriel Kulp, 2017 Oregon State University

	global ESP;
	success = true;

	Disconnect(); % Does nothing if there's already no connection

	comPort = 3; % No reason to change this on Windows. You'd need another way to do it on Mac.

	ESP = serial(sprintf('COM%0.0f', comPort));
	set(ESP, 'baudrate', 921600);
	set(ESP, 'terminator', 13); % \n
	set(ESP, 'Timeout', 1); % It replies rather quickly.

	try
		fopen(ESP);
	catch
		success = false;
		ESP = [];
		return;
	end

	
	if ~Send('1AU5000;2AU5000;3AU5000;') % Set max accel/decel
		success = false;
		return;
	end
		
	Send('1AC50;2AC50;3AC50;'); % Set accel
	Send('1AG50;2AG50;3AG50;'); % Set decel
	Send('1AE1000;2AE1000;3AE1000;'); % Set e-stop decel}
	Send(sprintf('1VA%0.0f;2VA%0.0f;3VA%0.0f;', [50, 50, 50])); % Set velocity
	Send('1MO;2MO;3MO;'); % Turn on motors

	global CURRENT_POS;
	CURRENT_POS = [0,0,0];
	response = Query('1TP?;2TP?;3TP?;', false);
	if ~isempty(response)
		CURRENT_POS = response;
	end

	global CURRENT_SPEED;
	CURRENT_SPEED = 50;

	global CURRENT_ACCEL;
	CURRENT_ACCEL = 50;

	global CURRENT_DECEL;
	CURRENT_DECEL = 50;
	
end
