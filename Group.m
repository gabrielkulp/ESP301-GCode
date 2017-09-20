function [] = Group(newState)
%GROUP Groups axes 1 and 2 into an X-Y system or ungroups.
% Sends commands to define or delete Group 1. Silently fails if
% disconnected
%
% Usage:
% Group([newState]);
%
% newState is an optional flag. When true, a group is created. When false,
%	an existing group is deleted. Defaults to true.
%
% Gabriel Kulp, 2017 Oregon State University

	if nargin < 1 % If newState isn't specified, default to true
		newState = true;
	end

	% Delete group
	%Send(sprintf('%0.0fHS;', ones(1,10))); % Clears motion buffer
	Send('1HX'); % Deletes group 1

	if newState == true % Re-add if wanted.
		
		global CURRENT_SPEED;
		global CURRENT_ACCEL;
		global CURRENT_DECEL;
		
		Send('1HN1,2'); % Define group 1 as axes 1 and 2
		Send(sprintf('1HV%0.5f', CURRENT_SPEED)); % Set group velocity
		Send(sprintf('1HA%0.5f', CURRENT_ACCEL)); % Set group accel
		Send(sprintf('1HD%0.5f', CURRENT_DECEL)); % Set group decel
		Send(sprintf('3VA%0.5f', CURRENT_SPEED)); % Set axis 3 velocity
		Send(sprintf('3AC%0.5f', CURRENT_ACCEL)); % Set axis 3 accel
		Send(sprintf('3AG%0.5f', CURRENT_DECEL)); % Set axis 3 decel
		
		Send('1HO'); % Turn group on
		Send('3MO'); % Turn axis 3 on
	end
end
