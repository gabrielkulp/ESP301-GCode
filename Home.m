function Home()
%HOME Moves all axes to where the origin should be and resets 0 to there.
% Removes the group (if there is one), homes all axes independently, waits
% a second, sets that position as home, then re-groups the axes.
%
% Usage:
% Home();
%
% Gabriel Kulp, 2017 Oregon State University

	global ESP;
	global CURRENT_POS;
	if isempty(ESP)
		return;
	end

	Group(false); % Remove group

	% Query is set velocities, set target positions, wait stop, ask position.
	%Query('1VA20;2VA20;3VA20;1MT-;2MT-;3MT+;1WS;2WS;3WS;1TP?', false, 30);
	Query('1OR;2OR;3OR;3WS;1TP?', false, 30);
	pause(1); % Let it settle
	Query('3PA60;3WS;3TP', false, 10);
	pause(1);
	Send('1DH;2DH;3DH'); % Set as origin
	CURRENT_POS = [0,0,0];

	Group(true); % Re-add group
end