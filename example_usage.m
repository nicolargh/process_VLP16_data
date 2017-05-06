% Written by nicolargh@github
%
% This data file is in the form: 
%    frame number \t total time elapsed \t raw data
% it was obtained by running the command:
%     tshark -f "host 192.168.1.201" -Tfields -e frame.number -e frame.time_relative -e data -i1 -c1000 > example_data.txt
% where:
%       Network (Sensor) IP = 192.168.1.201
%       Return Type = Strongest 
%       Motor RPM = 500.
% Data can also be scraped from wireshark and shoved into a text file somehow

filename = 'example_data.txt';
file = fopen(filename);
C = textscan(file, '%d%f%s', 1000, 'delimiter','\t');
frame_numbers = C{1};
times = C{2};
data = C{3};

[scan, nframes] = process_VLP16_data(500, times, data);

graph.plot = scatter3(0, 0, 0, 10, 'filled');
graph.title = title(sprintf('Scan at t = %.4f\r', 0));
axis([-2, 2, -2, 2, -1, 1]);

for frame=1:nframes-1 % last frame is not complete so not shown
    set(graph.plot, 'xdata', scan(frame, :, 1), 'ydata', scan(frame, :, 2), 'zdata', scan(frame, :, 3),...
                    'CData', scan(frame, :, 4));
    set(graph.title, 'string', sprintf('Scan at t = %.4f\r', times(frame)));
    pause(0.12);
end