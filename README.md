# Intensity correlator for Cyclone2 FPGAs

#### This repository contains code of an intensity correlator for the Cyclone II
###### The board we suggest is the cheap Cyclone 2 dev board:

![alt text](https://github.com/iliaplatone/correlator/raw/master/pictures/devboard.jpg "Devboard")

###### This is the Verilog code to be built with Quartus II.
###### The generated SVF file can be downloaded to the device using urJTAG http://urjtag.org/
###### To use the correlator use INDI/KStars: https://indilib.org

###### This interferometer needs external hardware:
+ External PCB as amplifier boards of radio antennas
+ External PCB for APD or PMT connectors and power supply
+ External PCB for delay lines

###### The project runs at 50MHz and uses 57600 baud/second UART communication with the host initially
###### There is a set of commands to start integrations:
+ 0x1d: Start integration by enabling UART transmission
+ 0x0d: Stop integration by disabling UART transmission
+ 0x01: select active line in bits [7:4]
+ 0x02: activate leds or power lines using bits [5:4]
+ 0x03: baudrate 57600 << bits [7:4]
+ 0x04: bits [1:0] => indexer, bits [6:4] => delay value. If bit 7 is 0, then delay for cross-correlations is set, if bit 4 is 1, then delay for autocorrelations is set.
+ 0x08: sampling rate = Clock_Frequency / bits [7:4]

###### The count of pulses and correlation comes with an ASCII packet string ended with a 0x0d character
###### Each packet starts with a header with payload length indication, it is possible to change some parameters from the code
+ bytes 0-1: hexadecimal sample size value
+ byte 2-3: hexadecimal inputs quantity
+ bytes 4: flags
+ bytes 5-7: hexadecimal delay lines quantity
+ bytes 8-15: hexadecimal value of the clock speed
+ bytes +lines#: pulses count within the packet time of every input in descending order in big-endian hexadecimal ASCII text
+ bytes +lines#: autocorrelations count of pulses of each line by the selected autocorrelation line
+ bytes +baselines#: cross-correlations count of pulses of each line with others by the selected delay amount

###### The sampling rate is the same as the packet rate, the bandwidth is the same as the FPGA oscillator frequency
