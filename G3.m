function [ command, time ] = G3(x, y, a, vel)
%G3 Moves in an arc around the specified coordinates.
% Moves the motors to follow an arc with center (x, y) and ccw angle a.
%
% Usage:
% [command, time] = G3(x, y, a, vel)
%
% x and y are the coordinates of the center of the circle. Both must be
%	specified.
% a is the counterclockwise angle in degrees that the arc will follow.
% vel is the scalar tangential velocity in mm/s. Ignored if empty.
% command is the string to send to the ESP301.
% time is the calculated time it will take to complete the motion.
% 
% Gabriel Kulp, 2017 Oregon State University

	global CURRENT_POS;
	global CURRENT_SPEED;
	z = CURRENT_POS(3); % Save for later
	commands = {};
	
	if a == 0
		command = '';
		time = 0;
		return
	end
	
	commands{1} = '1HQ9'; % Wait for queue to have 9 open slots

	% Parse
	if nargin == 4 && ~isempty(vel) && vel ~= CURRENT_SPEED
		commands{2} = sprintf('1HV%0.5f', vel); % Group velocity
		CURRENT_SPEED = vel;
	else
		vel = CURRENT_SPEED;
	end
	
	center = [x, y];
	
	% Do math
	% d = arc_fraction * 2pir
	% d = r * t  -->  t = d / r
	radius = CURRENT_POS(1:2) - center;
	dist = (a/360) * 2 * pi * norm(radius);
	time = dist / vel;

	commands{length(commands) + 1} =...
		sprintf('1HC%0.5f,%0.5f,%0.5f', -center(1:2), a); % Group move
	
	
	command = strjoin(commands(2:length(commands)), ';');
	
	% Calculate final position
	CURRENT_POS = ([cosd(a), -sind(a); sind(a), cosd(a)] * radius')' + center;
	CURRENT_POS(3) = z;
	
end

