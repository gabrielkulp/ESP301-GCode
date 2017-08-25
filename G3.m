function [ command, time ] = G3(x, y, a, vel)
%G2 Moves in an arc around the specified coordinates.
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

	% Parse
	if nargin == 4 && ~isempty(vel) && vel ~= CURRENT_SPEED
		groupVelocity = sprintf('1HV%0.5f;', vel);
	else
		vel = CURRENT_SPEED;
		groupVelocity = '';
	end
	
	center = [x, y];
	
	% Do math
	% d = arc_fraction * 2pir
	% d = r * t  -->  t = d / r
	radius = CURRENT_POS(1:2) - center;
	dist = (a/360) * 2 * pi * norm(radius);
	time = dist / vel;

	groupMove = sprintf('1HC%0.5f,%0.5f,%0.5f;', center, a);
	ping = ''; %	'1HQ?;';
	
	command = strcat(groupVelocity, groupMove, ping);
	
	% Calculate final position
	CURRENT_POS = ([cosd(a), -sind(a); sind(a), cosd(a)] * radius') + center;
	
end

