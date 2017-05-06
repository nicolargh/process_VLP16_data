Process Velodyne VLP-16 Data
======

Written by nicolargh@github.com

For complaints and bugs email nicola.seulin.gibson@gmail.com

This is a matlab script designed to take the raw data from a Velodyne VLP-16 
LiDAR and return something usable by humans - x,y,z coordinates grouped into 
frames, making one revolution of the LiDAR.

The function requires the RPM of the LiDAR, a vector of the elapsed times and 
a vector of the raw data as a string. 

Data for the function can be obtained by running a command such as:

```tshark -f "host 192.168.1.201" -Tfields -e frame.number -e frame.time_relative -e data -i1 -c1000 > example_data.txt```
      
192.168.1.201 is the default IP address of the LiDAR. For more information on 
tshark, check out their website.

The data can also be scraped from wireshark.

This function does not deal with dual return types or GPS data.

This script and method of obtaining data has only been tested on Ubuntu 15.10 
64-bit. I make no guarantees it works on other platforms.
