function [ GParams, linesRead ] = GetGLine( fid )
%GETGLINE Returns the next valid line of G-Code.
% Returns the next valid line in a G-Code file represented by the file
% handle fid. fopen should already have been called. Returns an empty array
% if it's the end of the file.
%
% Usage:
% GParams = GetGLine(fid)
%
% fid is the file handle output of fopen. Something like this line must
%	happen before calling this function: fid = fopen(GCodeFile);
% GParams is the string of everything that comes after 'G1 ' or 'G0 '. If
%	the line is blank, a comment, or not G1 or G0, the next line will be
%	evaluated. GParams is either empty at the end of the file, or contains
%	the G-Code parameters for G1 and G0.
%
% Gabriel Kulp, 2017 Oregon State University
	
	linesRead = 0;

	while true
		g = fgetl(fid);
		linesRead = linesRead + 1;
		
		if (g == -1) % End of file. Stop reading.
			GParams = '';
			return;
		elseif isempty(g) % Line is blank. Skip to next.
			continue;
		elseif (g(1) == ';') % Line is comment. Skip to next.
			continue;
		end % Line is command. Parse.
		
		spaces = strfind(g, ' ');
	
		if isempty(spaces)
			% Command has no arguments. Ignore (for our purposes)
			continue;
		end
		
		gCommand = g(1:spaces(1)-1); % Extract first characters up to space
	
		if (strcmp(gCommand, 'G0') || strcmp(gCommand, 'G1'))
			GParams = g(spaces(1)+1:length(g));
			return;
		else % Command isn't relevant. Skip to next.
			continue;
		end
	end
end

