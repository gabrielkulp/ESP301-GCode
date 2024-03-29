function [ command, time ] = G1(x, y, z, vel, relative)
%G1 Moves to the specified position
% Moves the motors to the 3D point specified in str
%
% Usage:
% [command, time] = G1(x, y, z, [vel], [relative])
%
% x, y, and z are the coordinates of the target position. Sending an empty
%	array for any of these means that axis won't receive commands.
% vel is the optional scalar end-effector velocity in mm/s. Defaults to the
%	value of CURRENT_SPEED.
% relative is an optional flag. When true, the motion is conducted in local
%	space. When false, global. Defaults to false.
% command is the string or character vector to send to the ESP301.
% time is the calculated time it will take to complete the motion.
% 
% Gabriel Kulp, 2017 Oregon State University

	global CURRENT_POS;
	global CURRENT_SPEED;
	commands = {};
	
	% If relative isn't specified, set it to false
	if nargin < 5
		relative = false;
	end
	
	% If vel isn't specified, set it to the current global speed
	if nargin < 4
		vel = CURRENT_SPEED;
	end
	
	% Must add commands to cell array in order of sending
	commands{1} = '1HQ9'; % Wait for queue to have 9 open slots

	% Use defaults for empty parameters.
	% This is important to the way G-Code works.
	pos = CURRENT_POS;
	if ~isempty(x)
		pos(1) = x;
	end
	if ~isempty(y)
		pos(2) = y;
	end
	if ~isempty(z)
		pos(3) = z;
	end
	
	% A bit more logic around vel since it might not send a command
	if ~isempty(vel) && vel ~= CURRENT_SPEED
		commands{2} = sprintf('1HV%0.5f', vel); % Group velocity
		commands{3} = sprintf('1HL%0.5f,%0.5f', -pos(1:2)); % Group move
		commands{4} = sprintf('3VA%0.5f', vel); % Axis velocity
		CURRENT_SPEED = vel;
	else
		vel = CURRENT_SPEED;
		commands{2} = sprintf('1HL%0.5f,%0.5f', -pos(1:2)); % Group move
	end
	
	% Manage relative coordinates
	if relative
		relPos = pos;
		pos = pos + CURRENT_POS;
	else
		relPos = pos - CURRENT_POS;
	end
	
	% Do math
	% d = r * t  -->  t = d / r
	dist = norm(relPos);
	time = dist / vel;
	
	if (CURRENT_POS(3) ~= pos(3))
		commands{length(commands) + 1} = sprintf('3PA%0.5f', -pos(3)); % Axis move
	end
	
	command = strjoin(commands(2:length(commands)), ';');
%	command = strcat(wait, groupVelocity, groupMove, axisVelocity, axisMove);
	
	% Assemble command without trajectory mode and groups. Deprecated.
	
% 	setVelocity = sprintf('1VA%0.5f;2VA%0.5f;3VA%0.5f;', vel);
% 	
% 	sendPing = '1TP?;'; % Send feedback so we know when to send the next
% 						% instruction. This command requests the position
% 						% of motor 1, but that's irrelevant since it's only
% 						% used for a ping.
% 	if relative
% 		targetFormatStr = '1PR%0.5f;2PR%0.5f;3PR%0.5f;';
% 	else
% 		targetFormatStr = '1PA%0.5f;2PA%0.5f;3PA%0.5f;';
% 	end
% 						
% 	if waitStop
% 		setTarget = sprintf(targetFormatStr, corrPos);
% 		wait = '1WS;2WS;3WS;'; % wait for all to stop
% 	else
% 		setTarget = sprintf(targetFormatStr, corrPos*1.1); % Overshoots target
% 		wait = sprintf('1WP%0.5f;2WP%0.5f;3WP%0.5f;', corrPos); % wait for all to pass target
% 		% This approach is riskier and probably shouldn't be used as the
% 		% first motion command. It's prone to waiting forever. Sending AB
% 		% (or clicking E-STOP) will break the wait if needed.
% 	end
% 	
% 	command = strcat(setVelocity, setTarget, sendPing, wait);
	
	CURRENT_POS = pos; % Update current position
	
end

