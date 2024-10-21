# Force-control
This program is designed to apply particular forces to an actuator, actaute the actuator with a specificed high-voltage waveform, and measure the resulting displacement. This is typically used to collect force-stroke or force-strain curves of an actuator.

Hardware interfaces:
National Instruments DAQ (many models will work)
High-voltage amplifier (TREK, EEL, or any amplifier that linearly scales output high-voltage to input signal low-voltage)
Dual-mode muscle lever (Aurora Scientific range)

The program is .mlapp file type, meant for running and editing in MATLAB's app designer. To track changes in Git, the .mlapp file must be exported as a .m file (ForceControl_exported) - .changes to .mlapp files cannot be viewed in Git. Both the .mlapp and .m files should be committed.
