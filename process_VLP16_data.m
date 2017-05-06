function [scan, rev] = process_VLP16_data(rpm, times, data)
    
    % each datablock is 100 bytes long, each byte is represented by 2 characters
    block_offsets = [0:200:2400];

    % channel 0 has omega -15 degrees, etc, as specified in the data sheet
    % Each channel appears twice per data block so I doubled the array
    omega = [-15, 1, -13, -3, -11, 5, -9, 7, -7, 9, -5, 11, -3, 13, -1, 15,...
             -15, 1, -13, -3, -11, 5, -9, 7, -7, 9, -5, 11, -3, 13, -1, 15];

    % calculate how much time it takes to do one revolution
    rps = (1/rpm)*60;
    periods = [rps:rps:times(end)+rps];

    % scan contains x, y, z and reflectivity information for each frame
    scan = zeros(length(periods), 50000, 4);

    point_counter = 1;
    rev = 1;
    for timestamp=1:length(times)
        frame = data{timestamp};

        % check frame header is good
        if length(frame) ~= 2412 || ~strcmp(frame(1:4), 'ffee')
            fprintf('Bad frame %d\n', timestamp);
            continue;
        end

        fprintf('Processing frame %d\n', timestamp);

        for block=1:12
            b_off = block_offsets(block);

            % check block header is good
            if ~strcmp(frame(b_off+1:b_off+4), 'ffee')
                disp('Bad block')
                continue;
            end

            % first chunk of datablock - angle is specified
            alpha1 = hex2dec(strcat(frame(b_off+7:b_off+8), frame(b_off+5:b_off+6)))/100;
            
            % second chunk of datablock - angle is interpolated
            b_off2 = mod(block_offsets(block+1), 2400);
            alpha3 = hex2dec(strcat(frame(b_off2+7:b_off2+8), frame(b_off2+5:b_off2+6)))/100;
            alpha2 = mean([alpha1 alpha3]);
            
            for channel=1:32
                if channel < 17, alpha = alpha1; else alpha = alpha2; end;
                c_off = 8+(channel-1)*6 + b_off;
                dist = hex2dec(strcat(frame(c_off+3:c_off+4), frame(c_off+1:c_off+2)))*2;
                scan(rev, point_counter, 1) = dist*cosd(omega(channel))*sind(alpha)/1000;
                scan(rev, point_counter, 2) = dist*cosd(omega(channel))*cosd(alpha)/1000;
                scan(rev, point_counter, 3) = dist*sind(omega(channel))/1000;
                scan(rev, point_counter, 4) = hex2dec(frame(c_off+5:c_off+6));
                point_counter = point_counter + 1;
            end
        end

        % if we've finished a revolution
        if times(timestamp) > periods(rev)
            fprintf('Scan %d finished\n', rev);
            point_counter = 1;
            rev = rev + 1;
        end
    end
end