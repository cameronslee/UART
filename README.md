# UART
Design decisions:
Based on board with the following specs:
25 MHz internal clock, 115200 baud

RX:
8 data bits
115200 baud
no parity 
1 stop bit
No flow control

Clocks Per bit = (Frequency of internal clock) / (UART frequency)
= 25000000 / 115200 = 217 clocks per bit

References
https://nandland.com/project-7-uart-part-1-receive-data-from-computer/
https://nandland.com/project-8-uart-part-2-transmit-data-to-computer/