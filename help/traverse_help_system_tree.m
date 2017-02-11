% This script starts from all branches of "help MAPP", gets their
% help strings, then from the "See also" section of each one, traverses
% the help system tree in breadth-first manner.
%
% If a help topic is not found, it prints warnings.
%
% This script assumes that a help topic is connected with all other topics
% through its "See also" section, which always starts with
% 
%See also
%--------
% 


fileName = '/tmp/hanging.txt';
fID = fopen(fileName,'w');

help_topics = {};
help_topics = {help_topics{:}, 'MAPPquickstart'};
help_topics = {help_topics{:}, 'MAPPdeviceExamples'};
help_topics = {help_topics{:}, 'MAPPcktExamples'};
help_topics = {help_topics{:}, 'MAPPlicense'};
help_topics = {help_topics{:}, 'MAPPdevices'};
help_topics = {help_topics{:}, 'MAPPnetlists'};
help_topics = {help_topics{:}, 'MAPPanalyses'};
help_topics = {help_topics{:}, 'MAPPautodiff'};
help_topics = {help_topics{:}, 'MAPPtesting'};

visited = {};

while ~isempty(help_topics)
    help_topic = help_topics{1};
    help_string = evalc(sprintf('help %s;', help_topic));
    %break help_string to lines (cellarray of strings)
    [lines, matches] = strsplit(help_string, char(10));

    if ~isempty(visited) && ~isempty(find(ismember(visited, help_topic)))
        % visited help topic
        % redundant check!
    elseif 2 <= length(lines) && ~isempty(strfind(lines{2}, 'not found'))
        % no help string for this topic!
        fprintf(fID, 'Hanging help topic: %s\n', help_topic);
    else
        % unvisited help topic
        visited = {visited{:}, help_topic};

        % find_*** are cellarrays. In them, if an entry starts with 2, it means ***
        % is at the beginning of the line.
        find_See_also = strfind(lines, 'See also');
        find_dashes = strfind(lines, '--------');

        See_also = {};
        See_also_started = 0;

        for d = 1:length(lines) % inefficient double for loop
            line = lines{d};
            if See_also_started
                if 3 <= length(line) && '<' ~= line(3)
                    % not a hyper link generated by Matlab
                    See_also = {See_also{:}, line};
                end
            else
                if ~isempty(find_dashes{d}) && find_dashes{d}(1) == 2
                % The line starts with dashes
                    if d~=1 && ~isempty(find_See_also{d-1}) && find_See_also{d-1}(1)==2
                    % The line is 'See also' before dashes
                        See_also_started = 1;
                    end
                end
            end
        end

        if ~isempty(See_also)
            if 5 < length(See_also)
                celldisp(See_also);
                result = input('Input the number of the last line of See also section:\n');
                % result = 1;
                See_also = {See_also{1:result}};
            end
            if ~isempty(See_also)
                str = strjoin(See_also, ' ');
                [words, matches] = strsplit(str, {' ', ',', '.'},'CollapseDelimiters',true) ;
                emptyCells = cellfun(@isempty, words);
                words(emptyCells) = [];
                for d = 1:length(words)
                    word = words{d};
                    if ~isempty(visited) && ~isempty(find(ismember(visited, word)))
                    else
                        if isempty(strfind(word, 'TODO'))
                            help_topics = {help_topics{:}, word};
                        end
                    end
                end % for each word
            end % if See_also not empty
        end % if See_also not empty
    end % if unvisited
    help_topics(1) = [];
end % while