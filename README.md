# AHP XC Quantum correlators firmware

[![DOI](https://www.zenodo.org/badge/311073125.svg)](https://www.zenodo.org/badge/latestdoi/311073125)

#### This repository contains code of the XC series multichannel multi-order cross-correlators

![AHP XC8 cross-correlator](https://github.com/ahp-electronics/pictures/blob/master/XC32_small.png "XC32")


You'll find board and device specific files into the boards/ folder, device files contain some custom parameters that can characterize the device:

```
parameter PLL_FREQUENCY = 400000000;	//The pll frequency
parameter CLK_FREQUENCY = 10000000;	//The crystal frequency
parameter SIN_FREQUENCY = 50;		//The internal optional PSU frequency
parameter MUX_LINES = 1;		//Muxer lines
parameter NUM_LINES = 8;		//Lines per each Muxer line
parameter DELAY_SIZE = 2048;		//If 4 use quadrature sampling, if 0 use single sample quadrature sampling, else the delay FIFO size
parameter LAG_CROSS = 1;		//Lag lines size for live crosscorrelation
parameter LAG_AUTO = 1;			//Lag lines size for live autocorrelation
parameter RESOLUTION = 24;		//Resolution (count capacity) of each correlation/intensity counter
parameter HAS_LEDS = 1;			//Has this device output lines? (power switches or indicator or ramp generators sync?)
parameter HAS_CROSSCORRELATOR = 1;	//Has this device crosscorrelation capability?
parameter HAS_PSU = 0;			//Has this device a software PSU?
parameter HAS_CUMULATIVE_ONLY = 0;	//Has this device not on-edge counting?
parameter BAUD_RATE = 57600;		//Communication port baud rate
parameter WORD_WIDTH = 1;		//Word width (greater than 1 when using ADC - must be in sync with the ADC ramp gener
parameter BINARY = 0;		//use binary packet transmission instead of ASCII
parameter USE_UART = 1;			//Use UART or SPI communication?
parameter USE_SOFT_CLOCK = 1;			//Limit usage of gated clocks
parameter MAX_ORDER = 2;			//Maximum crosscorrelation order
```


The generated SVF file can be downloaded to the device using urJTAG http://urjtag.org/

The cross-platform driver library: https://github.com/ahp-electronics/libahp-xc

To use the correlator try the GUI: https://github.com/ahp-electronics/xc-gui

The project runs at 10MHz and uses 57600 baud/second UART communication with the host initially

Here below is defined the communication protocol:

    0x0d: Set integration parameters: bit 4 => enable capture, bit 5 => use external clock, bit 6 => reset timestamp when enabling capture, bit 7 => enable extra commands
    0x01: select active line: bits [7:6] => indexer, bits [5:4] => value (if extra commands bits [5:4] are routed to 4 extra lines)
    0x02: activate leds or power lines using bits [5:4], invert pulse reading with bit 6, single clock cycle pulse width with bit 7
    0x03: baudrate 57600 left-shifted by bits [7:4] (if extra commands bits [5:4] are routed to crosscorrelation order [7:4])
    0x04: bits [1:0] => indexer, bits [6:4] => delay value. If bit 7 is 0, then start delay for cross-correlations is set, if bit 4 is 1, then start delay for autocorrelations is set, if extra commands these values define the size of the correlation scan).
    0x08: sampling clock tau = bits [7:4] are the clock tau power of two exponent or the upper 4 bits of the delay. If bit 7 is 0, this applies to cross-correlations, if bit 4 is 1, this applies to autocorrelations, if extra commands these values apply to the size of the correlation scan. if tests[7] is set, these commands sets the step increment.
    0x09: power voltage = bits [7:4]
    0x0c: Set tests: bit 5 => enable pll oscillator signal on led 0, bit 5 => enable autocorrelation scan, bit 6 => enable crosscorrelation scan, bit 7 => BCM encoder on led 0 (pulse XOR by sampling clock) (if extra commands bits [5:4] are routed to tests flags [7:4])

The count of pulses and correlation comes with an ASCII packet string ended with a 0x0d character

Each packet starts with a header with payload length indication, it is possible to change some parameters from the code

header

    bytes 0-1: hexadecimal sample size value
    bytes 2-3: hexadecimal inputs quantity
    bytes 4-6: hexadecimal delay channels quantity
    bytes 7-10: hexadecimal live delay channels quantity
    bytes 11: hexadecimal flags [bits: 0=live autocorrelator, 1=live crosscorrelator, 2=leds available, 3=cross-correlator]
    bytes 12-15: hexadecimal value of the clock tau in picoseconds

payload

    bytes +lines#: pulses count of each line within the integration time
    bytes +lines#: autocorrelations real/imaginary count of each line within the packet time
    bytes +baselines#: crosscorrelations real/imaginary count of pulses of each line with others ones within the packet time
    bytes +16: 8-byte timestamp of current packet

checksum

    bytes +1: 1-byte CRC of packet payload

The packet time is determined by the baud rate and the packet size, the sampling rate is determined by the clock tau multiplied by the number of mux lines, raised by the clock tau power of two exponent.

