# ice_flow
- Lattice iCEcube2 makefile build flow for Linux.<br/>
- Adapted from a Windows-oriented flow by [VHDLwhiz](https://vhdlwhiz.com/).<br>
- Targets [iCEstick](https://www.latticesemi.com/icestick) (iCE40-HX1K) with a simple circuit to PWM the LEDs 

## Dependencies
[Lattice iCEcube2](https://www.latticesemi.com/iCEcube2)<br/>
[YosysHQ icestorm](https://github.com/YosysHQ/icestorm)<br/>
```make```<br/>

## Usage
(1) Adjust the starting lines of the makefile for the path of your iCEcube2 installation<br/>
(2) ```git clone https://github.com/justinabate/ice_mod.git```<br/>
(3) ```cd ice_mod; make fpga``` (synthesize, implement, and program), or ```make help``` for an individual process

## Remarks
The makefile assumes ```iceprog``` can be found in the ```$PATH``` <br/>
```libelf.so.1``` messages can be fixed by getting the 32-bit lib, finding the install, and putting a symlink in icecube2's installation directory below:
```
sudo apt-get install -qy libelf1:i386
find /usr/ -type f -name "libelf*" -exec ls -l {} \; # got /usr/lib/i386-linux-gnu/libelf-0.176.so
ln -s /usr/lib/i386-linux-gnu/libelf-0.176.so /opt/lscc/iCEcube2.2017.08/sbt_backend/lib/linux/opt/libelf.so.1
```
The makefile sets a ```$LD_LIBRARY_PATH``` variable which finds the symlink 
