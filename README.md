# XC8 Intensity correlator firmware

#### This repository contains code of the XC8 series correlators

![alt text](https://raw.githubusercontent.com/ahp-electronics/pictures/master/XC8_small.png "XC8")

This is the Verilog code to be built with Quartus II.

The generated SVF file can be downloaded to the device using urJTAG http://urjtag.org/

To use the correlator try the GUI: https://github.com/ahp-electronics/xc-gui

The project runs at 50MHz and uses 57600 baud/second UART communication with the host initially

There is a set of commands to start integrations:

+ 0x1d: Start integration by enabling UART transmission
+ 0x0d: Stop integration by disabling UART transmission
+ 0x01: select active line: bits [7:6] => indexer, bits [5:4] => value
+ 0x02: activate leds or power lines using bits [5:4], invert pulse reading with bit 6, single clock cycle pulse width with bit 7
+ 0x03: baudrate 57600 << bits [7:4]
+ 0x04: bits [1:0] => indexer, bits [6:4] => delay value. If bit 7 is 0, then delay for cross-correlations is set, if bit 4 is 1, then delay for autocorrelations is set.
+ 0x08: sampling rate = Clock_Frequency / bits [7:4]

The count of pulses and correlation comes with an ASCII packet string ended with a 0x0d character

Each packet starts with a header with payload length indication, it is possible to change some parameters from the code

+ bytes 0-1: hexadecimal sample size value
+ bytes 2-3: hexadecimal inputs quantity
+ bytes 4-6: hexadecimal delay channels quantity
+ bytes 7-10: hexadecimal live delay channels quantity
+ bytes 11: hexadecimal flags [bits: 0=live autocorrelator, 1=live crosscorrelator]
+ bytes 12-15: hexadecimal value of the clock tau in picoseconds
+ bytes +lines#: autocorrelations count of pulses of each line by the selected autocorrelation line
+ bytes +baselines#: crosscorrelations count of pulses of each line with others by the selected delay amount

###### The sampling rate is the same as the packet rate, the bandwidth is the same as the FPGA oscillator frequency
