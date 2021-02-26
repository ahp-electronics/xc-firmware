# XC Intensity correlator firmware

#### This repository contains code of the XC series correlators

![AHP XC8 cross-correlator](https://raw.githubusercontent.com/ahp-electronics/pictures/master/XC8_small.png "XC8")


You'll find board and device specific files into the boards/ folder, device files contain some custom parameters that can characterize the device:

```
parameter CLK_FREQUENCY = 10000000;	//The crystal frequency
parameter PLL_MULTIPLIER = 40;		//The PLL Multiplier value
parameter PLL_DIVIDER = 1;		//The PLL Divider value
parameter MUX_LINES = 8;		//Muxer lines
parameter NUM_LINES = 4;		//Lines per each Muxer line
parameter DELAY_SIZE = 160;		//The delay FIFO size
parameter RESOLUTION = 24;		//Resolution (count capacity) of each correlation/intensity counter
parameter HAS_LED_FLAGS = 1;		//Has this device output lines? (power switches or indicator or ramp generators sync?)
parameter HAS_CROSSCORRELATOR = 1;	//Has this device crosscorrelation capability?
parameter HAS_PSU = 0;			//Has this device a software PSU?
parameter LAG_AUTO = 1;			//Lag lines size for live autocorrelation
parameter LAG_CROSS = 1;		//Lag lines size for live crosscorrelation
parameter BAUD_RATE = 57600;		//Communication port baud rate
parameter WORD_WIDTH = 1;		//Word width (greater than 1 when using ADC - must be in sync with the ADC ramp generator)
```

The generated SVF file can be downloaded to the device using urJTAG http://urjtag.org/

To use the correlator try the GUI: https://github.com/ahp-electronics/xc-gui

The project runs at 10MHz and uses 57600 baud/second UART communication with the host initially

There is a set of commands to start integrations:

+ 0x1d: Start integration by enabling UART transmission
+ 0x0d: Stop integration by disabling UART transmission
+ 0x01: select active line: bits [7:6] => indexer, bits [5:4] => value
+ 0x02: activate leds or power lines using bits [5:4], invert pulse reading with bit 6, single clock cycle pulse width with bit 7
+ 0x03: baudrate 57600 << bits [7:4]
+ 0x04: bits [1:0] => indexer, bits [6:4] => delay value. If bit 7 is 0, then delay for cross-correlations is set, if bit 4 is 1, then delay for autocorrelations is set.
+ 0x08: sampling clock tau = clock tau << bits [7:4]
+ 0x09: power voltage = bits [7:4]

The count of pulses and correlation comes with an ASCII packet string ended with a 0x0d character

Each packet starts with a header with payload length indication, it is possible to change some parameters from the code

+ bytes 0-1: hexadecimal sample size value
+ bytes 2-3: hexadecimal inputs quantity
+ bytes 4-6: hexadecimal delay channels quantity
+ bytes 7-10: hexadecimal live delay channels quantity
+ bytes 11: hexadecimal flags [bits: 0=live autocorrelator, 1=live crosscorrelator, 2=leds available, 3=cross-correlator]
+ bytes 12-15: hexadecimal value of the clock tau in picoseconds
+ bytes +lines#: pulses count of each line delayed by crosscorrelation lag zero
+ bytes +lines#: autocorrelations count of each line by the selected autocorrelation line delayed by crosscorrelation lag zero
+ bytes +baselines#: crosscorrelations count of pulses of each line with others by the selected delay amount

###### The sampling rate is the same as the packet rate, the bandwidth is determined by the clock tau and the the clock tau multiplier by two
