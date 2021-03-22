EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Driver_Motor:L293D U3
U 1 1 602E75FD
P 3050 1650
F 0 "U3" H 3050 2831 50  0000 C CNN
F 1 "L293D" H 3050 2740 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm" H 3300 900 50  0001 L CNN
F 3 "http://www.ti.com/lit/ds/symlink/l293.pdf" H 2750 2350 50  0001 C CNN
	1    3050 1650
	1    0    0    -1  
$EndComp
$Comp
L pinhead:PINHD-2X13 JP5
U 1 1 602F61D8
P 1600 1400
F 0 "JP5" H 1650 546 45  0000 C CNN
F 1 "PINHD-2X13" H 1650 630 45  0000 C CNN
F 2 "pinhead:pinhead-2X13" H 1630 1550 20  0001 C CNN
F 3 "" H 1600 1400 50  0001 C CNN
	1    1600 1400
	-1   0    0    1   
$EndComp
$Comp
L pinhead:PINHD-1X2 PSU3
U 1 1 602F9E57
P 2750 5650
F 0 "PSU3" H 2858 5742 45  0000 L CNN
F 1 "PINHD-1X2" H 2858 5658 45  0000 L CNN
F 2 "pinhead:pinhead-1X02" H 2780 5800 20  0001 C CNN
F 3 "" H 2750 5650 50  0001 C CNN
	1    2750 5650
	1    0    0    -1  
$EndComp
$Comp
L pinhead:PINHD-1X2 PSU2
U 1 1 602FA9DA
P 2250 5650
F 0 "PSU2" H 2358 5742 45  0000 L CNN
F 1 "PINHD-1X2" H 2358 5658 45  0000 L CNN
F 2 "pinhead:pinhead-1X02" H 2280 5800 20  0001 C CNN
F 3 "" H 2250 5650 50  0001 C CNN
	1    2250 5650
	1    0    0    -1  
$EndComp
Wire Wire Line
	2150 5550 2650 5550
$Comp
L power:+5V #PWR0169
U 1 1 6030786D
P 2150 5550
F 0 "#PWR0169" H 2150 5400 50  0001 C CNN
F 1 "+5V" H 2165 5723 50  0000 C CNN
F 2 "" H 2150 5550 50  0001 C CNN
F 3 "" H 2150 5550 50  0001 C CNN
	1    2150 5550
	1    0    0    -1  
$EndComp
Connection ~ 2150 5550
$Comp
L power:+5V #PWR0176
U 1 1 603085B4
P 2950 650
F 0 "#PWR0176" H 2950 500 50  0001 C CNN
F 1 "+5V" H 2965 823 50  0000 C CNN
F 2 "" H 2950 650 50  0001 C CNN
F 3 "" H 2950 650 50  0001 C CNN
	1    2950 650 
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0183
U 1 1 6030B036
P 3150 650
F 0 "#PWR0183" H 3150 500 50  0001 C CNN
F 1 "+5V" H 3165 823 50  0000 C CNN
F 2 "" H 3150 650 50  0001 C CNN
F 3 "" H 3150 650 50  0001 C CNN
	1    3150 650 
	1    0    0    -1  
$EndComp
$Comp
L power:+3V3 #PWR0186
U 1 1 6030BE2F
P 2550 2050
F 0 "#PWR0186" H 2550 1900 50  0001 C CNN
F 1 "+3V3" V 2565 2178 50  0000 L CNN
F 2 "" H 2550 2050 50  0001 C CNN
F 3 "" H 2550 2050 50  0001 C CNN
	1    2550 2050
	0    -1   -1   0   
$EndComp
$Comp
L power:+3V3 #PWR0187
U 1 1 6030C951
P 2550 1450
F 0 "#PWR0187" H 2550 1300 50  0001 C CNN
F 1 "+3V3" V 2565 1578 50  0000 L CNN
F 2 "" H 2550 1450 50  0001 C CNN
F 3 "" H 2550 1450 50  0001 C CNN
	1    2550 1450
	0    -1   -1   0   
$EndComp
$Comp
L power:+3V3 #PWR0188
U 1 1 6030CFD5
P 1400 800
F 0 "#PWR0188" H 1400 650 50  0001 C CNN
F 1 "+3V3" V 1415 928 50  0000 L CNN
F 2 "" H 1400 800 50  0001 C CNN
F 3 "" H 1400 800 50  0001 C CNN
	1    1400 800 
	0    -1   -1   0   
$EndComp
$Comp
L power:+3V3 #PWR0189
U 1 1 6030D637
P 1700 800
F 0 "#PWR0189" H 1700 650 50  0001 C CNN
F 1 "+3V3" V 1715 928 50  0000 L CNN
F 2 "" H 1700 800 50  0001 C CNN
F 3 "" H 1700 800 50  0001 C CNN
	1    1700 800 
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0190
U 1 1 6031FC1D
P 3250 2450
F 0 "#PWR0190" H 3250 2200 50  0001 C CNN
F 1 "GND" V 3255 2322 50  0000 R CNN
F 2 "" H 3250 2450 50  0001 C CNN
F 3 "" H 3250 2450 50  0001 C CNN
	1    3250 2450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0191
U 1 1 603211CB
P 3150 2450
F 0 "#PWR0191" H 3150 2200 50  0001 C CNN
F 1 "GND" V 3155 2322 50  0000 R CNN
F 2 "" H 3150 2450 50  0001 C CNN
F 3 "" H 3150 2450 50  0001 C CNN
	1    3150 2450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0192
U 1 1 60321417
P 2950 2450
F 0 "#PWR0192" H 2950 2200 50  0001 C CNN
F 1 "GND" V 2955 2322 50  0000 R CNN
F 2 "" H 2950 2450 50  0001 C CNN
F 3 "" H 2950 2450 50  0001 C CNN
	1    2950 2450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0193
U 1 1 603216E0
P 2850 2450
F 0 "#PWR0193" H 2850 2200 50  0001 C CNN
F 1 "GND" V 2855 2322 50  0000 R CNN
F 2 "" H 2850 2450 50  0001 C CNN
F 3 "" H 2850 2450 50  0001 C CNN
	1    2850 2450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0194
U 1 1 60321937
P 1700 1300
F 0 "#PWR0194" H 1700 1050 50  0001 C CNN
F 1 "GND" V 1705 1172 50  0000 R CNN
F 2 "" H 1700 1300 50  0001 C CNN
F 3 "" H 1700 1300 50  0001 C CNN
	1    1700 1300
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR0195
U 1 1 6032211F
P 1400 1300
F 0 "#PWR0195" H 1400 1050 50  0001 C CNN
F 1 "GND" V 1405 1172 50  0000 R CNN
F 2 "" H 1400 1300 50  0001 C CNN
F 3 "" H 1400 1300 50  0001 C CNN
	1    1400 1300
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0196
U 1 1 6032281A
P 1400 1800
F 0 "#PWR0196" H 1400 1550 50  0001 C CNN
F 1 "GND" V 1405 1672 50  0000 R CNN
F 2 "" H 1400 1800 50  0001 C CNN
F 3 "" H 1400 1800 50  0001 C CNN
	1    1400 1800
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0197
U 1 1 60322C33
P 1700 1800
F 0 "#PWR0197" H 1700 1550 50  0001 C CNN
F 1 "GND" V 1705 1672 50  0000 R CNN
F 2 "" H 1700 1800 50  0001 C CNN
F 3 "" H 1700 1800 50  0001 C CNN
	1    1700 1800
	0    -1   -1   0   
$EndComp
$Comp
L pinhead:PINHD-2X13 JP6
U 1 1 6032781A
P 4450 1500
F 0 "JP6" H 4500 646 45  0000 C CNN
F 1 "PINHD-2X13" H 4500 730 45  0000 C CNN
F 2 "pinhead:pinhead-2X13" H 4480 1650 20  0001 C CNN
F 3 "" H 4450 1500 50  0001 C CNN
	1    4450 1500
	-1   0    0    1   
$EndComp
$Comp
L power:+3V3 #PWR0198
U 1 1 60327824
P 4250 900
F 0 "#PWR0198" H 4250 750 50  0001 C CNN
F 1 "+3V3" V 4265 1028 50  0000 L CNN
F 2 "" H 4250 900 50  0001 C CNN
F 3 "" H 4250 900 50  0001 C CNN
	1    4250 900 
	0    -1   -1   0   
$EndComp
$Comp
L power:+3V3 #PWR0199
U 1 1 6032782E
P 4550 900
F 0 "#PWR0199" H 4550 750 50  0001 C CNN
F 1 "+3V3" V 4565 1028 50  0000 L CNN
F 2 "" H 4550 900 50  0001 C CNN
F 3 "" H 4550 900 50  0001 C CNN
	1    4550 900 
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0200
U 1 1 60327838
P 4550 1400
F 0 "#PWR0200" H 4550 1150 50  0001 C CNN
F 1 "GND" V 4555 1272 50  0000 R CNN
F 2 "" H 4550 1400 50  0001 C CNN
F 3 "" H 4550 1400 50  0001 C CNN
	1    4550 1400
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR0201
U 1 1 60327842
P 4250 1400
F 0 "#PWR0201" H 4250 1150 50  0001 C CNN
F 1 "GND" V 4255 1272 50  0000 R CNN
F 2 "" H 4250 1400 50  0001 C CNN
F 3 "" H 4250 1400 50  0001 C CNN
	1    4250 1400
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0202
U 1 1 6032784C
P 4250 1900
F 0 "#PWR0202" H 4250 1650 50  0001 C CNN
F 1 "GND" V 4255 1772 50  0000 R CNN
F 2 "" H 4250 1900 50  0001 C CNN
F 3 "" H 4250 1900 50  0001 C CNN
	1    4250 1900
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0203
U 1 1 60327856
P 4550 1900
F 0 "#PWR0203" H 4550 1650 50  0001 C CNN
F 1 "GND" V 4555 1772 50  0000 R CNN
F 2 "" H 4550 1900 50  0001 C CNN
F 3 "" H 4550 1900 50  0001 C CNN
	1    4550 1900
	0    -1   -1   0   
$EndComp
Wire Wire Line
	4550 2000 4350 2000
Wire Wire Line
	4350 2000 4350 2750
Wire Wire Line
	4350 2750 2150 2750
Wire Wire Line
	2150 2750 2150 1900
Wire Wire Line
	2150 1900 1700 1900
Wire Wire Line
	1700 2000 2050 2000
Wire Wire Line
	2050 2850 4550 2850
Wire Wire Line
	4550 2850 4550 2100
Wire Wire Line
	4250 2100 4250 2950
Wire Wire Line
	4250 2950 1400 2950
Wire Wire Line
	1400 2950 1400 2000
Wire Wire Line
	1400 1900 1300 1900
Wire Wire Line
	1300 1900 1300 3050
Wire Wire Line
	1300 3050 4200 3050
Wire Wire Line
	4200 3050 4200 2000
Wire Wire Line
	4200 2000 4250 2000
Wire Wire Line
	1700 1700 2200 1700
Wire Wire Line
	2200 1700 2200 3100
Wire Wire Line
	2200 3100 4750 3100
Wire Wire Line
	4750 3100 4750 1800
Wire Wire Line
	4750 1800 4550 1800
Wire Wire Line
	1700 1600 2300 1600
Wire Wire Line
	2300 1600 2300 3200
Wire Wire Line
	2300 3200 4800 3200
Wire Wire Line
	4800 3200 4800 1700
Wire Wire Line
	4800 1700 4550 1700
Wire Wire Line
	1700 1500 2350 1500
Wire Wire Line
	2350 1500 2350 3250
Wire Wire Line
	2350 3250 4850 3250
Wire Wire Line
	4850 3250 4850 1600
Wire Wire Line
	4850 1600 4550 1600
Wire Wire Line
	2050 2000 2050 2850
Wire Wire Line
	1700 1400 2000 1400
Wire Wire Line
	2000 1400 2000 3300
Wire Wire Line
	4900 3300 4900 1500
Wire Wire Line
	4900 1500 4550 1500
Wire Wire Line
	2000 3300 4900 3300
Wire Wire Line
	1400 1700 1200 1700
Wire Wire Line
	1200 1700 1200 3350
Wire Wire Line
	1200 3350 4000 3350
Wire Wire Line
	4000 3350 4000 1800
Wire Wire Line
	4000 1800 4250 1800
Wire Wire Line
	4250 1700 3950 1700
Wire Wire Line
	3950 1700 3950 3400
Wire Wire Line
	3950 3400 1150 3400
Wire Wire Line
	1150 3400 1150 1600
Wire Wire Line
	1150 1600 1400 1600
Wire Wire Line
	1400 1500 1100 1500
Wire Wire Line
	1100 1500 1100 3450
Wire Wire Line
	1100 3450 3900 3450
Wire Wire Line
	3900 3450 3900 1600
Wire Wire Line
	3900 1600 4250 1600
Wire Wire Line
	4250 1500 3850 1500
Wire Wire Line
	3850 1500 3850 3500
Wire Wire Line
	3850 3500 1050 3500
Wire Wire Line
	1050 3500 1050 1400
Wire Wire Line
	1050 1400 1400 1400
$Comp
L power:GND #PWR0204
U 1 1 60411DC6
P 2150 5650
F 0 "#PWR0204" H 2150 5400 50  0001 C CNN
F 1 "GND" V 2155 5522 50  0000 R CNN
F 2 "" H 2150 5650 50  0001 C CNN
F 3 "" H 2150 5650 50  0001 C CNN
	1    2150 5650
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0205
U 1 1 60412273
P 2650 5650
F 0 "#PWR0205" H 2650 5400 50  0001 C CNN
F 1 "GND" V 2655 5522 50  0000 R CNN
F 2 "" H 2650 5650 50  0001 C CNN
F 3 "" H 2650 5650 50  0001 C CNN
	1    2650 5650
	0    1    1    0   
$EndComp
Wire Wire Line
	1700 900  2550 900 
Wire Wire Line
	2550 900  2550 1050
Wire Wire Line
	1700 1000 2500 1000
Wire Wire Line
	2500 1000 2500 1250
Wire Wire Line
	2500 1250 2550 1250
Wire Wire Line
	2550 1650 2450 1650
Wire Wire Line
	2450 1650 2450 1100
Wire Wire Line
	2450 1100 1700 1100
Wire Wire Line
	2550 1850 2400 1850
Wire Wire Line
	2400 1850 2400 1200
Wire Wire Line
	2400 1200 1700 1200
Wire Wire Line
	3550 1050 3550 950 
Wire Wire Line
	3550 950  4550 950 
Wire Wire Line
	4550 950  4550 1000
Wire Wire Line
	3550 1250 3600 1250
Wire Wire Line
	3600 1250 3600 1050
Wire Wire Line
	3600 1050 4550 1050
Wire Wire Line
	4550 1050 4550 1100
Wire Wire Line
	3550 1650 3650 1650
Wire Wire Line
	3650 1650 3650 1150
Wire Wire Line
	3650 1150 4550 1150
Wire Wire Line
	4550 1150 4550 1200
Wire Wire Line
	3550 1850 3700 1850
Wire Wire Line
	3700 1850 3700 1250
Wire Wire Line
	3700 1250 4550 1250
Wire Wire Line
	4550 1250 4550 1300
Wire Wire Line
	1400 900  1400 850 
Wire Wire Line
	1400 850  4000 850 
Wire Wire Line
	4000 850  4000 1000
Wire Wire Line
	4000 1000 4250 1000
Wire Wire Line
	4250 1100 3950 1100
Wire Wire Line
	3950 1100 3950 1000
Wire Wire Line
	3950 1000 2600 1000
Wire Wire Line
	2600 1000 2600 950 
Wire Wire Line
	2600 950  1400 950 
Wire Wire Line
	1400 950  1400 1000
Wire Wire Line
	4250 1200 3900 1200
Wire Wire Line
	3900 1200 3900 1100
Wire Wire Line
	3900 1100 2600 1100
Wire Wire Line
	2600 1100 2600 1150
Wire Wire Line
	2600 1150 1400 1150
Wire Wire Line
	1400 1150 1400 1100
Wire Wire Line
	4250 1300 2100 1300
Wire Wire Line
	2100 1300 2100 1250
Wire Wire Line
	2100 1250 1400 1250
Wire Wire Line
	1400 1250 1400 1200
$Comp
L Driver_Motor:L293D U4
U 1 1 60547B6C
P 7650 1700
F 0 "U4" H 7650 2881 50  0000 C CNN
F 1 "L293D" H 7650 2790 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm" H 7900 950 50  0001 L CNN
F 3 "http://www.ti.com/lit/ds/symlink/l293.pdf" H 7350 2400 50  0001 C CNN
	1    7650 1700
	1    0    0    -1  
$EndComp
$Comp
L pinhead:PINHD-2X13 JP7
U 1 1 60547B76
P 6200 1450
F 0 "JP7" H 6250 596 45  0000 C CNN
F 1 "PINHD-2X13" H 6250 680 45  0000 C CNN
F 2 "pinhead:pinhead-2X13" H 6230 1600 20  0001 C CNN
F 3 "" H 6200 1450 50  0001 C CNN
	1    6200 1450
	-1   0    0    1   
$EndComp
$Comp
L power:+5V #PWR0206
U 1 1 60547B80
P 7550 700
F 0 "#PWR0206" H 7550 550 50  0001 C CNN
F 1 "+5V" H 7565 873 50  0000 C CNN
F 2 "" H 7550 700 50  0001 C CNN
F 3 "" H 7550 700 50  0001 C CNN
	1    7550 700 
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0207
U 1 1 60547B8A
P 7750 700
F 0 "#PWR0207" H 7750 550 50  0001 C CNN
F 1 "+5V" H 7765 873 50  0000 C CNN
F 2 "" H 7750 700 50  0001 C CNN
F 3 "" H 7750 700 50  0001 C CNN
	1    7750 700 
	1    0    0    -1  
$EndComp
$Comp
L power:+3V3 #PWR0208
U 1 1 60547B94
P 7150 2100
F 0 "#PWR0208" H 7150 1950 50  0001 C CNN
F 1 "+3V3" V 7165 2228 50  0000 L CNN
F 2 "" H 7150 2100 50  0001 C CNN
F 3 "" H 7150 2100 50  0001 C CNN
	1    7150 2100
	0    -1   -1   0   
$EndComp
$Comp
L power:+3V3 #PWR0209
U 1 1 60547B9E
P 7150 1500
F 0 "#PWR0209" H 7150 1350 50  0001 C CNN
F 1 "+3V3" V 7165 1628 50  0000 L CNN
F 2 "" H 7150 1500 50  0001 C CNN
F 3 "" H 7150 1500 50  0001 C CNN
	1    7150 1500
	0    -1   -1   0   
$EndComp
$Comp
L power:+3V3 #PWR0210
U 1 1 60547BA8
P 6000 850
F 0 "#PWR0210" H 6000 700 50  0001 C CNN
F 1 "+3V3" V 6015 978 50  0000 L CNN
F 2 "" H 6000 850 50  0001 C CNN
F 3 "" H 6000 850 50  0001 C CNN
	1    6000 850 
	0    -1   -1   0   
$EndComp
$Comp
L power:+3V3 #PWR0211
U 1 1 60547BB2
P 6300 850
F 0 "#PWR0211" H 6300 700 50  0001 C CNN
F 1 "+3V3" V 6315 978 50  0000 L CNN
F 2 "" H 6300 850 50  0001 C CNN
F 3 "" H 6300 850 50  0001 C CNN
	1    6300 850 
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0212
U 1 1 60547BBC
P 7850 2500
F 0 "#PWR0212" H 7850 2250 50  0001 C CNN
F 1 "GND" V 7855 2372 50  0000 R CNN
F 2 "" H 7850 2500 50  0001 C CNN
F 3 "" H 7850 2500 50  0001 C CNN
	1    7850 2500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0213
U 1 1 60547BC6
P 7750 2500
F 0 "#PWR0213" H 7750 2250 50  0001 C CNN
F 1 "GND" V 7755 2372 50  0000 R CNN
F 2 "" H 7750 2500 50  0001 C CNN
F 3 "" H 7750 2500 50  0001 C CNN
	1    7750 2500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0214
U 1 1 60547BD0
P 7550 2500
F 0 "#PWR0214" H 7550 2250 50  0001 C CNN
F 1 "GND" V 7555 2372 50  0000 R CNN
F 2 "" H 7550 2500 50  0001 C CNN
F 3 "" H 7550 2500 50  0001 C CNN
	1    7550 2500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0215
U 1 1 60547BDA
P 7450 2500
F 0 "#PWR0215" H 7450 2250 50  0001 C CNN
F 1 "GND" V 7455 2372 50  0000 R CNN
F 2 "" H 7450 2500 50  0001 C CNN
F 3 "" H 7450 2500 50  0001 C CNN
	1    7450 2500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0216
U 1 1 60547BE4
P 6300 1350
F 0 "#PWR0216" H 6300 1100 50  0001 C CNN
F 1 "GND" V 6305 1222 50  0000 R CNN
F 2 "" H 6300 1350 50  0001 C CNN
F 3 "" H 6300 1350 50  0001 C CNN
	1    6300 1350
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR0217
U 1 1 60547BEE
P 6000 1350
F 0 "#PWR0217" H 6000 1100 50  0001 C CNN
F 1 "GND" V 6005 1222 50  0000 R CNN
F 2 "" H 6000 1350 50  0001 C CNN
F 3 "" H 6000 1350 50  0001 C CNN
	1    6000 1350
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0218
U 1 1 60547BF8
P 6000 1850
F 0 "#PWR0218" H 6000 1600 50  0001 C CNN
F 1 "GND" V 6005 1722 50  0000 R CNN
F 2 "" H 6000 1850 50  0001 C CNN
F 3 "" H 6000 1850 50  0001 C CNN
	1    6000 1850
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0219
U 1 1 60547C02
P 6300 1850
F 0 "#PWR0219" H 6300 1600 50  0001 C CNN
F 1 "GND" V 6305 1722 50  0000 R CNN
F 2 "" H 6300 1850 50  0001 C CNN
F 3 "" H 6300 1850 50  0001 C CNN
	1    6300 1850
	0    -1   -1   0   
$EndComp
$Comp
L pinhead:PINHD-2X13 JP8
U 1 1 60547C0C
P 9050 1550
F 0 "JP8" H 9100 696 45  0000 C CNN
F 1 "PINHD-2X13" H 9100 780 45  0000 C CNN
F 2 "pinhead:pinhead-2X13" H 9080 1700 20  0001 C CNN
F 3 "" H 9050 1550 50  0001 C CNN
	1    9050 1550
	-1   0    0    1   
$EndComp
$Comp
L power:+3V3 #PWR0220
U 1 1 60547C16
P 8850 950
F 0 "#PWR0220" H 8850 800 50  0001 C CNN
F 1 "+3V3" V 8865 1078 50  0000 L CNN
F 2 "" H 8850 950 50  0001 C CNN
F 3 "" H 8850 950 50  0001 C CNN
	1    8850 950 
	0    -1   -1   0   
$EndComp
$Comp
L power:+3V3 #PWR0221
U 1 1 60547C20
P 9150 950
F 0 "#PWR0221" H 9150 800 50  0001 C CNN
F 1 "+3V3" V 9165 1078 50  0000 L CNN
F 2 "" H 9150 950 50  0001 C CNN
F 3 "" H 9150 950 50  0001 C CNN
	1    9150 950 
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0222
U 1 1 60547C2A
P 9150 1450
F 0 "#PWR0222" H 9150 1200 50  0001 C CNN
F 1 "GND" V 9155 1322 50  0000 R CNN
F 2 "" H 9150 1450 50  0001 C CNN
F 3 "" H 9150 1450 50  0001 C CNN
	1    9150 1450
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR0223
U 1 1 60547C34
P 8850 1450
F 0 "#PWR0223" H 8850 1200 50  0001 C CNN
F 1 "GND" V 8855 1322 50  0000 R CNN
F 2 "" H 8850 1450 50  0001 C CNN
F 3 "" H 8850 1450 50  0001 C CNN
	1    8850 1450
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0224
U 1 1 60547C3E
P 8850 1950
F 0 "#PWR0224" H 8850 1700 50  0001 C CNN
F 1 "GND" V 8855 1822 50  0000 R CNN
F 2 "" H 8850 1950 50  0001 C CNN
F 3 "" H 8850 1950 50  0001 C CNN
	1    8850 1950
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0225
U 1 1 60547C48
P 9150 1950
F 0 "#PWR0225" H 9150 1700 50  0001 C CNN
F 1 "GND" V 9155 1822 50  0000 R CNN
F 2 "" H 9150 1950 50  0001 C CNN
F 3 "" H 9150 1950 50  0001 C CNN
	1    9150 1950
	0    -1   -1   0   
$EndComp
Wire Wire Line
	9150 2050 8950 2050
Wire Wire Line
	8950 2050 8950 2800
Wire Wire Line
	8950 2800 6750 2800
Wire Wire Line
	6750 2800 6750 1950
Wire Wire Line
	6750 1950 6300 1950
Wire Wire Line
	6300 2050 6650 2050
Wire Wire Line
	6650 2900 9150 2900
Wire Wire Line
	9150 2900 9150 2150
Wire Wire Line
	8850 2150 8850 3000
Wire Wire Line
	8850 3000 6000 3000
Wire Wire Line
	6000 3000 6000 2050
Wire Wire Line
	6000 1950 5900 1950
Wire Wire Line
	5900 1950 5900 3100
Wire Wire Line
	5900 3100 8800 3100
Wire Wire Line
	8800 3100 8800 2050
Wire Wire Line
	8800 2050 8850 2050
Wire Wire Line
	6300 1750 6800 1750
Wire Wire Line
	6800 1750 6800 3150
Wire Wire Line
	6800 3150 9350 3150
Wire Wire Line
	9350 3150 9350 1850
Wire Wire Line
	9350 1850 9150 1850
Wire Wire Line
	6300 1650 6900 1650
Wire Wire Line
	6900 1650 6900 3250
Wire Wire Line
	6900 3250 9400 3250
Wire Wire Line
	9400 3250 9400 1750
Wire Wire Line
	9400 1750 9150 1750
Wire Wire Line
	6300 1550 6950 1550
Wire Wire Line
	6950 1550 6950 3300
Wire Wire Line
	6950 3300 9450 3300
Wire Wire Line
	9450 3300 9450 1650
Wire Wire Line
	9450 1650 9150 1650
Wire Wire Line
	6650 2050 6650 2900
Wire Wire Line
	6300 1450 6600 1450
Wire Wire Line
	6600 1450 6600 3350
Wire Wire Line
	9500 3350 9500 1550
Wire Wire Line
	9500 1550 9150 1550
Wire Wire Line
	6600 3350 9500 3350
Wire Wire Line
	6000 1750 5800 1750
Wire Wire Line
	5800 1750 5800 3400
Wire Wire Line
	5800 3400 8600 3400
Wire Wire Line
	8600 3400 8600 1850
Wire Wire Line
	8600 1850 8850 1850
Wire Wire Line
	8850 1750 8550 1750
Wire Wire Line
	8550 1750 8550 3450
Wire Wire Line
	8550 3450 5750 3450
Wire Wire Line
	5750 3450 5750 1650
Wire Wire Line
	5750 1650 6000 1650
Wire Wire Line
	6000 1550 5700 1550
Wire Wire Line
	5700 1550 5700 3500
Wire Wire Line
	5700 3500 8500 3500
Wire Wire Line
	8500 3500 8500 1650
Wire Wire Line
	8500 1650 8850 1650
Wire Wire Line
	8850 1550 8450 1550
Wire Wire Line
	8450 1550 8450 3550
Wire Wire Line
	8450 3550 5650 3550
Wire Wire Line
	5650 3550 5650 1450
Wire Wire Line
	5650 1450 6000 1450
Wire Wire Line
	6300 950  7150 950 
Wire Wire Line
	7150 950  7150 1100
Wire Wire Line
	6300 1050 7100 1050
Wire Wire Line
	7100 1050 7100 1300
Wire Wire Line
	7100 1300 7150 1300
Wire Wire Line
	7150 1700 7050 1700
Wire Wire Line
	7050 1700 7050 1150
Wire Wire Line
	7050 1150 6300 1150
Wire Wire Line
	7150 1900 7000 1900
Wire Wire Line
	7000 1900 7000 1250
Wire Wire Line
	7000 1250 6300 1250
Wire Wire Line
	8150 1100 8150 1000
Wire Wire Line
	8150 1000 9150 1000
Wire Wire Line
	9150 1000 9150 1050
Wire Wire Line
	8150 1300 8200 1300
Wire Wire Line
	8200 1300 8200 1100
Wire Wire Line
	8200 1100 9150 1100
Wire Wire Line
	9150 1100 9150 1150
Wire Wire Line
	8150 1700 8250 1700
Wire Wire Line
	8250 1700 8250 1200
Wire Wire Line
	8250 1200 9150 1200
Wire Wire Line
	9150 1200 9150 1250
Wire Wire Line
	8150 1900 8300 1900
Wire Wire Line
	8300 1900 8300 1300
Wire Wire Line
	8300 1300 9150 1300
Wire Wire Line
	9150 1300 9150 1350
Wire Wire Line
	6000 950  6000 900 
Wire Wire Line
	6000 900  8600 900 
Wire Wire Line
	8600 900  8600 1050
Wire Wire Line
	8600 1050 8850 1050
Wire Wire Line
	8850 1150 8550 1150
Wire Wire Line
	8550 1150 8550 1050
Wire Wire Line
	8550 1050 7200 1050
Wire Wire Line
	7200 1050 7200 1000
Wire Wire Line
	7200 1000 6000 1000
Wire Wire Line
	6000 1000 6000 1050
Wire Wire Line
	8850 1250 8500 1250
Wire Wire Line
	8500 1250 8500 1150
Wire Wire Line
	8500 1150 7200 1150
Wire Wire Line
	7200 1150 7200 1200
Wire Wire Line
	7200 1200 6000 1200
Wire Wire Line
	6000 1200 6000 1150
Wire Wire Line
	8850 1350 6700 1350
Wire Wire Line
	6700 1350 6700 1300
Wire Wire Line
	6700 1300 6000 1300
Wire Wire Line
	6000 1300 6000 1250
$EndSCHEMATC
