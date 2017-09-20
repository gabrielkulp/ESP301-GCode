function [ parsedVars ] = GParse( command, str )
%GPARSE Reads a G0 or G1 command and parses the specified position
% Reads everything after 'G1 ' and outputs a position vector of the
% specified target and a scalar for the velocity if specified.
%
% Usage:
% [parsedVars] = GParse(command, str);
%
% command is the string for the G-command in the form 'G1'.
% str is everything after 'G1 ', 'G3 ', etc. in G-Code.
% parsedVars is an array of numbers depending on the command. For G0 or G1,
%	it contains x, y, z, vel. For G2 or G3, it contains x, y, a, vel as
%	absolute coordinates of the center and degrees of CCW rotation,
%	regardless of the G-Code method used to define the arc.
%
% Gabriel Kulp, 2017 Oregon State University
	
	switch (command)
		case {'G0', 'G1'} % Linear motion
			X = [];
			Y = [];
			Z = [];
			vel = [];

			args = strsplit(str);
			for n = 1:length(args)
				argChar = args{n};
				argNum = sscanf(args{n}, '%*c%f');
				switch argChar(1)
					case 'F'
						vel = argNum / 60;
					case 'X'
						X = argNum;
					case 'Y'
						Y = argNum;
					case 'Z'
						Z = argNum;
				end % ignore E for extruder
			end
			parsedVars = {X, Y, Z, vel};
		case {'G2', 'G3'} % Arc motion
			global CURRENT_POS; % Not "inefficient" since it's called once.
			X = [];
			Y = [];
			I = 0;
			J = 0;
			R = [];
			vel = [];
			IJKMode = true;
			
			args = strsplit(str);
			for n = 1:length(args)
				argChar = args{n};
				argNum = sscanf(args{n}, '%*c%f');
				if IJKMode
					switch argChar(1)
						case 'F'
							vel = argNum / 60;
						case 'X'
							X = argNum;
						case 'Y'
							Y = argNum;
						case 'I'
							I = argNum;
						case 'J'
							J = argNum;
						case 'R'
							IJKMode = false;
					end
				end
				if ~IJKMode % Could have changed. Must use another if.
					switch argChar(1)
						case 'F'
							vel = argNum / 60;
						case 'X'
							X = argNum;
						case 'Y'
							Y = argNum;
						case 'R'
							R = argNum;
					end
				end
			end
			
			if IJKMode
				center = CURRENT_POS(1:2) + [I, J];
				startVec = CURRENT_POS(1:2) - center;
				endVec = [X, Y] - center;
				
				determinant = det([startVec' endVec']);
				dotProd = dot(startVec, endVec);
				
				ang = atan2(determinant, dotProd);
				A = mod(-180/pi * ang, 360);
				
				if strcmp(command, 'G2')
					A = -A; % G3 is CCW, but math is CW
				end
				
				parsedVars = {center(1), center(2), A, vel};
			else
				% This is solving a SSS triangle. Law of Cosines
				% cos(A) = (b^2 + c^2 - a^2) / 2*b*c
				% cos(A) = c / 2*r
				% Side c is the chord from start to finish
				% Angle C is the angle of the arc
				% Angle A is the angle from start to center
				
				startPos = CURRENT_POS(1:2);
				endPos = [X, Y];
				chord = endPos - startPos;
				% Sides a and b are both r.
				sideC = norm(chord);
				angA = acosd(sideC / (2 * R));
				if strcmp(command, 'G2') % ESP assumes CCW
					angA = -angA;
				end
				
				% Now use that info to find the center point.
				rotMat = [cosd(angA), -sind(angA); sind(angA), cosd(angA)];
				center = startPos + ((rotMat * chord') * (R / sideC))';
				
				% Next, we find the angle C. Sum of angles is 180.
				angC = 180 - (abs(angA) * 2);
				if strcmp(command, 'G2')
					angC = -angC;
				end
				
				parsedVars = {center(1), center(2), angC, vel};
			end
%		end case
	end % switch

end % function

