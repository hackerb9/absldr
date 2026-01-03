# HDOS Shim 

This is an untested attempt to make shims which can be sent to ABSLDR
to setup RAM as if the machine was running HDOS. The .sys files have
been converted into peculiar `.abs` files by modifying the 8 byte
header:

* MAGIC: First two bytes changed to 0FFH and 00 (Binary, ABS object).
* ADDRESS: Second two bytes left unchanged.
* LENGTH: Third two bytes left unchanged.
* ENTRY: Fourth two bytes set to 00 and 14H. 

Since 1400H is the address of ABSLDR, after these shims are loaded
into memory by ABSLDR, instead of being executed, ABSLDR will restart
and wait for another `.abs` file.
