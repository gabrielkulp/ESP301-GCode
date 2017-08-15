function [ command ] = G1(str)
%G1 Moves to the specified position
% Moves the motors to the 3D point specified in str
%
% Usage:
% command = G1(str)
%
% str is the rest of the G-code after the command.
% command is the string to send to the ESP301.
% 
% Gabriel Kulp, 2017 Oregon State University

	global CURRENT_POS;
	global CURRENT_SPEED;

	% Parse
	pos = CURRENT_POS;
	args = strsplit(str);
	for i = 1:length(args)
		argChar = args{i};
		argNum = sscanf(args{i}, '%*c%f');
		if argChar(1) == 'F'
			CURRENT_SPEED = argNum / 60;
		elseif argChar(1) == 'X'
			pos(1) = argNum;
		elseif argChar(1) == 'Y'
			pos(2) = argNum;
		elseif argChar(1) == 'Z'
			pos(3) = -argNum;
		end % ignore E for extruder
	end
	
	
	% Do math
	% d = r * t
	relPos = pos - CURRENT_POS;
	dist = norm(relPos);
	time = dist ./ CURRENT_SPEED;
	vel = abs(relPos ./ time);
	
	CURRENT_POS = pos; % Update current position
	
	% Assemble command
	waitStop = '1WS;2WS;3WS;'; % wait for all to stop
	sendPing = '1TP?;'; % Send feedback so we know when to send the next
						% instruction. This command requests the position
						% of motor 1, but that's irrelevant since it's only
						% used for a ping.
	setVelocity = sprintf('1VA%0.5f;2VA%0.5f;3VA%0.5f;', vel);
	setTarget = sprintf('1PA%0.5f;2PA%0.5f;3PA%0.5f;', pos);
	
	command = strcat(waitStop, sendPing, setVelocity, setTarget);

end

