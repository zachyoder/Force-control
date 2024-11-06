classdef ForceControl_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        LiveplotCheckBox                matlab.ui.control.CheckBox
        AdvancedsettingsCheckBox        matlab.ui.control.CheckBox
        AdvancedsettingsPanel           matlab.ui.container.Panel
        V_BonCheckBox                   matlab.ui.control.CheckBox
        kVLabel_4                       matlab.ui.control.Label
        V_AEditField                    matlab.ui.control.NumericEditField
        V_AEditFieldLabel               matlab.ui.control.Label
        msLabel_7                       matlab.ui.control.Label
        RampfromBEditField              matlab.ui.control.NumericEditField
        RampfromBEditFieldLabel         matlab.ui.control.Label
        msLabel_6                       matlab.ui.control.Label
        TimeAEditField                  matlab.ui.control.NumericEditField
        TimeAEditFieldLabel             matlab.ui.control.Label
        HzLabel_3                       matlab.ui.control.Label
        ACfrequencyEditField            matlab.ui.control.NumericEditField
        ACfrequencyEditFieldLabel       matlab.ui.control.Label
        ACactuationCheckBox             matlab.ui.control.CheckBox
        V_highEditField                 matlab.ui.control.NumericEditField
        V_highEditFieldLabel            matlab.ui.control.Label
        msLabel_5                       matlab.ui.control.Label
        msLabel_4                       matlab.ui.control.Label
        msLabel_3                       matlab.ui.control.Label
        msLabel_2                       matlab.ui.control.Label
        kVLabel_3                       matlab.ui.control.Label
        kVLabel_2                       matlab.ui.control.Label
        RampdownEditField               matlab.ui.control.NumericEditField
        RampdownEditFieldLabel          matlab.ui.control.Label
        V_BEditField                    matlab.ui.control.NumericEditField
        V_BEditFieldLabel               matlab.ui.control.Label
        RampupEditField                 matlab.ui.control.NumericEditField
        RampupEditFieldLabel            matlab.ui.control.Label
        TimehighEditField               matlab.ui.control.NumericEditField
        TimehighEditFieldLabel          matlab.ui.control.Label
        TimeBEditField                  matlab.ui.control.NumericEditField
        TimeBEditFieldLabel             matlab.ui.control.Label
        Lamp                            matlab.ui.control.Lamp
        MonitorlimittripstatusCheckBox  matlab.ui.control.CheckBox
        ForceParametersPanel            matlab.ui.container.Panel
        NumberofvoltcyclesperstepEditField  matlab.ui.control.NumericEditField
        NumberofvoltcyclesperstepEditFieldLabel  matlab.ui.control.Label
        LogdistributionCheckBox         matlab.ui.control.CheckBox
        inclzeroLabel                   matlab.ui.control.Label
        NumberofforcestepsEditField     matlab.ui.control.NumericEditField
        NumberofforcestepsLabel         matlab.ui.control.Label
        NLabel                          matlab.ui.control.Label
        MaxforceEditField               matlab.ui.control.NumericEditField
        MaxforceEditFieldLabel          matlab.ui.control.Label
        CalibrationPanel                matlab.ui.container.Panel
        VVLabel                         matlab.ui.control.Label
        mmVLabel                        matlab.ui.control.Label
        NVLabel                         matlab.ui.control.Label
        MTlengthconstantkLEditField     matlab.ui.control.NumericEditField
        MTlengthconstantkLEditFieldLabel  matlab.ui.control.Label
        MTforceconstantkFEditField      matlab.ui.control.NumericEditField
        MTforceconstantkFEditFieldLabel  matlab.ui.control.Label
        TREKvoltageconstantkVEditField  matlab.ui.control.NumericEditField
        TREKvoltageconstantkVEditFieldLabel  matlab.ui.control.Label
        HzLabel                         matlab.ui.control.Label
        SamplerateEditField             matlab.ui.control.NumericEditField
        SamplerateEditFieldLabel        matlab.ui.control.Label
        VoltageParametersPanel          matlab.ui.container.Panel
        msLabel                         matlab.ui.control.Label
        RamptimeEditField               matlab.ui.control.NumericEditField
        RamptimeEditFieldLabel          matlab.ui.control.Label
        SignaltypeDropDown              matlab.ui.control.DropDown
        SignaltypeLabel                 matlab.ui.control.Label
        ReversepolarityCheckBox         matlab.ui.control.CheckBox
        kVLabel                         matlab.ui.control.Label
        MaxvoltageEditField             matlab.ui.control.NumericEditField
        MaxvoltageEditFieldLabel        matlab.ui.control.Label
        HzLabel_2                       matlab.ui.control.Label
        VoltagefrequencyEditField       matlab.ui.control.NumericEditField
        VoltagefrequencyEditFieldLabel  matlab.ui.control.Label
        SetupPanel                      matlab.ui.container.Panel
        ao0ao1ai0ai1ai2Label            matlab.ui.control.Label
        RawdatafilenameEditField        matlab.ui.control.EditField
        RawdatafilenameEditFieldLabel   matlab.ui.control.Label
        SelectfilepathEditField         matlab.ui.control.EditField
        SelectfilepathEditFieldLabel    matlab.ui.control.Label
        GoButton                        matlab.ui.control.StateButton
        BrowseButton                    matlab.ui.control.Button
        UIAxes                          matlab.ui.control.UIAxes
    end

    % Author: Zachary Yoder
    % Created: May 2020
    % Last updated: 21 October 2024
    % Notes: Added DAQ selection function
    %{
    % --------------------- GENERAL STRUCTURE -------------------- %
                             
        % ------------------- startupFcn ------------------- %

            Runs when the app is first launched. Connects
            to the DAQ, sets up input/output channels,
            sets up UI and calls buildPreview to plot
            the default signal.

        % -------------------------------------------------- %

        % ----------- user interaction/ callbacks ---------- %

            User can change values and set up the test
            as desired. Whenever a value in the UI is changed,
            its callback function is called. In most callbacks,
            the user input is checked and properties of the app
            are updated as needed. Then, buildPreview fcn is
            called to update the plot with the new values.

        % -------------------------------------------------- %

        % --------------- GoButtonValueChanged ------------- %

            This is where the test starts and ends. When
            the test starts (GoButtonValue = 1), build the signal,
            open the data file and start the data acquisition.

            Acquisition is carried out in a background operation.
            This means that the user can interact with the app
            while the test is running. To store the data, we use
            the scansAvailableFcn and scansAvailableFcnCount properties
            of the DAQ, which is set up in the startupFcn and adjusted
            as the user changes various test parameters.

            Every n = scansAvailableFcnCount data points, the
            scansAvailableFunction = storeData is called. In that function,
            we read the available data from the DAQ and write it to the
            file, among a few other things (like checking if the test
            is over).

            Once the test is over (GoButtonValue = 0), we end the test
            by closing the data file, cleaning up the DAQ output and 
            resetting the UI for the next test.

        % -------------------------------------------------- %

        % --------------------- errorFcn ------------------- %

            During testing, the DAQ sometimes throws a 'time out'
            error. I can't figure out why, no matter how hard
            I try. To counter this, I set the DAQ property
            errorOccurredFcn to call our own errorFcn, and save
            the test data and shut down the app safely.

            Probably, we can just delete the daq object and set it
            back up, without having to close the app.

        % -------------------------------------------------- %

% ------------------------------------------------------------------- %
    %}
    
    properties (Access = private)
        d; % DAQ object
        devName; % daq device name
        sampleRate;
        
        kV; % TREK voltage factor
        kF; % MT force factor
        kL; % MT length factor
        maxVoltage;
        
        numScansAcquired;
        lastOutputIndex;
        
        rawFileID;
        
        actTimeArr;
    end
    
    methods (Access = private)
        
        % This function builds the voltage and force output signals
        function fullSignal = buildSignal(app)
            numVoltsPerStep = app.NumberofvoltcyclesperstepEditField.Value;
            numForceSteps = app.NumberofforcestepsEditField.Value;
            maxForce = app.MaxforceEditField.Value;
            
            totalCycles = numForceSteps*numVoltsPerStep;

            % Build custom signal
            if app.AdvancedsettingsCheckBox.Value
                % Calculate total length of voltage output signal
                cycleSamples = cast(sum(app.actTimeArr)*app.sampleRate, 'int64');
                totalSamples = cycleSamples*totalCycles;
                
                % Initiate empty arrays
                voltageCycle = zeros(cycleSamples, 1);
                voltageSignal = zeros(totalSamples, 1);
                forceSignal = voltageSignal;
                
                if isempty(voltageSignal)
                    fullSignal = [voltageSignal, forceSignal];
                    return
                end
                
                % Calculate number of samples for each part of the voltage output signal
                numA = app.actTimeArr(1)*app.sampleRate;
                numRampUp = app.actTimeArr(2)*app.sampleRate;
                numHigh = app.actTimeArr(3)*app.sampleRate;
                numRampDown = app.actTimeArr(4)*app.sampleRate;
                
                cycleIndices = [numA,...
                    numA + numRampUp,...
                    numA + numRampUp + numHigh,...
                    numA + numRampUp + numHigh + numRampDown];
                
                % Populate single DC voltage signal
                voltageCycle(1: cycleIndices(1), 1) = app.maxVoltage(1);
                voltageCycle(cycleIndices(1) + 1: cycleIndices(2), 1) = linspace(app.maxVoltage(1), app.maxVoltage(2), numRampUp).';
                voltageCycle(cycleIndices(2) + 1: cycleIndices(3), 1) = app.maxVoltage(2);
                if app.ReversepolarityCheckBox.Value
                    returnVoltage = -app.maxVoltage(1);
                else
                    returnVoltage = app.maxVoltage(1);
                end
                voltageCycle(cycleIndices(3) + 1: cycleIndices(4), 1) = linspace(app.maxVoltage(2), returnVoltage, numRampDown).';

                % If V_B on
                if app.V_BonCheckBox.Value
                    numB = app.actTimeArr(5)*app.sampleRate;
                    numRampUpFromLow = app.actTimeArr(6)*app.sampleRate;
                    cycleIndices = [cycleIndices, numA + numRampUp + numHigh + numRampDown + numB,...
                    numA + numRampUp + numHigh + numRampDown + numB + numRampUpFromLow];
                         
                    % Overwrite end of the signal
                    voltageCycle(cycleIndices(3) + 1: cycleIndices(4), 1) = linspace(app.maxVoltage(2), app.maxVoltage(3), numRampDown).';
                    voltageCycle(cycleIndices(4) + 1: cycleIndices(5), 1) = app.maxVoltage(3);
                    voltageCycle(cycleIndices(5) + 1: cycleIndices(6), 1) = linspace(app.maxVoltage(3), returnVoltage, numRampUpFromLow).';
                end
                
                % Populate single AC voltage signal
                if app.ACactuationCheckBox.Value
                    % Set up AC signal here
                    singleSineSamples = app.sampleRate/app.ACfrequencyEditField.Value;
                    singleSine = sin(linspace(0, 2*pi, singleSineSamples).');
                    fullSine = ones(cycleSamples, 1);
                    numSineCycles = floor(cycleSamples/singleSineSamples);
                    for i = 1:numSineCycles
                        startIndex = (i - 1)*singleSineSamples + 1;
                        endIndex = startIndex - 1 + singleSineSamples;
                        fullSine(startIndex: endIndex, 1) = singleSine;
                    end
                    
                    voltageCycle = voltageCycle.*fullSine;
                end
            % Build 'normal' signal
            else
                % Calculate total length of voltage output signal
                frequency = app.VoltagefrequencyEditField.Value;
                cycleSamples = app.sampleRate/frequency; %samples/cycle
                totalSamples = cycleSamples*totalCycles;
                
                % Initiate empty arrays
                voltageCycle = zeros(cycleSamples, 1);
                voltageSignal = zeros(totalSamples, 1);
                forceSignal = voltageSignal;
                
                % Build various signal types
                switch app.SignaltypeDropDown.Value
                case 'Ramped square'
                    numRamp = app.RamptimeEditField.Value/1000*app.sampleRate;
                    numHold = (cycleSamples - 2*numRamp)/2;
                    
                    voltageCycle(numHold + 1: numHold + numRamp, 1) = linspace(0, app.maxVoltage, numRamp).';
                    voltageCycle(numHold + numRamp + 1: 2*numHold + numRamp, 1) = app.maxVoltage;
                    voltageCycle(2*numHold + numRamp + 1: end, 1) = linspace(app.maxVoltage, 0, numRamp).';
                case 'Square'
                    voltageCycle(cycleSamples/2 + 1: end - 1) = app.maxVoltage;
                        % This would probably be better if the square wave
                        % was in the middle of the cycle
                otherwise
                    voltageCycle(1:cycleSamples/2, 1) = linspace(0, app.maxVoltage, cycleSamples/2).';
                    voltageCycle(cycleSamples/2 + 1: end, 1) = linspace(app.maxVoltage, 0, cycleSamples/2).';
                end
            end
            
            voltageSignal(1: cycleSamples, 1) = voltageCycle;
            for i = 1:totalCycles - 1
                j = i*cycleSamples;
                if app.ReversepolarityCheckBox.Value
                    voltageCycle = -voltageCycle;
                end
                voltageSignal(j + 1: j+cycleSamples, 1) = voltageCycle;
            end
            
            % Build force signal
            stepSamples = cycleSamples * numVoltsPerStep; % num samples per force step
            
            if app.LogdistributionCheckBox.Value
                for i = 1: numForceSteps - 1
                    forceSignal(i*stepSamples + 1: (i + 1)*stepSamples, 1) = (maxForce/app.kF)*(1 - (log(numForceSteps - i)/log(numForceSteps)));
                end
            else
                if numForceSteps == 1
                    forceSignal(:, 1) = maxForce/app.kF;
                else
                    reference = linspace(0, maxForce/app.kF, numForceSteps);
                    for i = 0:numForceSteps - 1
                        forceSignal(i*stepSamples + 1: (i + 1)*stepSamples, 1) = reference(i + 1);
                    end
                end
            end
            forceSignal(end, 1) = 0;
            
            fullSignal = [voltageSignal, forceSignal];
        end
        
        function buildPreview(app)
            % Currently not clearing axes after previous test run...
            hold(app.UIAxes, 'off');
            cla(app.UIAxes);
            fullSignal = buildSignal(app);

            if isempty(fullSignal)
                return
            end
            
            time = linspace(0, length(fullSignal)/app.sampleRate, length(fullSignal));
            yyaxis(app.UIAxes, 'right');
            plot(app.UIAxes, time, fullSignal(:, 2)*app.kF);
            ylabel(app.UIAxes, 'Force (N)');
            
            yyaxis(app.UIAxes, 'left');
            plot(app.UIAxes, time, fullSignal(:, 1)*app.kV);
            ylabel(app.UIAxes, 'Voltage (kV)');
        end
        
        function storeData(app, ~, ~)
            % This function is called every n = scansAvailableFcnCount data points read by the DAQ

            startIndex = cast(app.numScansAcquired, 'double');
            numScansAvailable = cast(app.d.NumScansAvailable, 'double');

            % Increment number of data points acquired
            app.numScansAcquired = cast(app.numScansAcquired + numScansAvailable, 'double');

            % Read available data from DAQ
            scanData = read(app.d, numScansAvailable, "OutputFormat", "Matrix");           
            voltage = scanData(:, 1);
            force = scanData(:, 2);
            displacement = scanData(:, 3);
            current = scanData(:, 4);

            % Save raw data here
            time = linspace(startIndex, app.numScansAcquired, numScansAvailable)/app.sampleRate;
            fprintf(app.rawFileID, '%.5f, %.4f, %.4f, %.4f, %.4f\n', [time; voltage.'; force.'; displacement.'; current.']);

            % Plot data every cycle
            if app.LiveplotCheckBox.Value
                yyaxis(app.UIAxes, 'left');
                plot(app.UIAxes, time, displacement*app.kL, '-');
                yyaxis(app.UIAxes, 'right');
                plot(app.UIAxes, time, force*app.kF, '-');
            end
            
            % Check trip status
            trip = scanData(end, 5);
            if trip < 4 && app.MonitorlimittripstatusCheckBox.Value
                app.Lamp.Color = 'red';
                app.GoButton.Value = 0;
                GoButtonValueChanged(app);
            end

            % If all scans have been output, end the program
            if app.numScansAcquired == app.lastOutputIndex
                app.GoButton.Value = 0;
                GoButtonValueChanged(app);
            end
        end
        
        function errorFcn(app, ~, ~)
            % Function called when DAQ throws an error

            % Block user input to prevent error
            app.GoButton.Enable = 0;
            
            % Close raw file to make sure that all saves
            fclose(app.rawFileID);
            
            % Ensure zero voltage
            write(app.d, [0, 0]);

            % Alert user and close app
            uialert(app.UIFigure, {'All data saved. Please restart the app.', 'App will now close.'}, 'DAQ timeout error',...
                'CloseFcn', @(src, event) UIFigureCloseRequest(app, event), 'Icon', 'info');
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % DAQ ao0 = Voltage output to Trek
            % DAQ ao1 = Force output to muscle tester
            
            % DAQ ai0 = Voltage monitor from Trek
            % DAQ ai1 = Force monitor from muscle tester
            % DAQ ai2 = Displacement monitor from muscle tester
            % DAQ ai3 = Current monitor from TREK
            % DAQ ai7 = Limit/trip status from TREK

            % Collect calibration constants
            app.kV = app.TREKvoltageconstantkVEditField.Value/1000;
                % Calibration is Vdaq/Vtrek, but I like to use Vdaq/kVtrek
            app.kF = app.MTforceconstantkFEditField.Value;
            app.kL = app.MTlengthconstantkLEditField.Value;
            app.maxVoltage = app.MaxvoltageEditField.Value/app.kV;
                        
            app.sampleRate = app.SamplerateEditField.Value;
             
            % Set up UI
            app.Lamp.Enable = 0;
            app.Lamp.Color = [0.96, 0.96, 0.96];
            
            buildPreview(app);

            % Select and connect to DAQ
            available_daqs = daqlist;
            if isempty(available_daqs)
                uiwait(msgbox("No DAQ selected, preview mode only", "Error", 'modal'));
                app.GoButton.Enable = 0;
            else
                [idx, ~] = listdlg('PromptString', 'Select a device.', ...
                    'SelectionMode', 'single', 'ListString', available_daqs.Model);
                app.d = daq("ni");
                app.d.Rate = app.SamplerateEditField.Value;
                app.dev_name = available_daqs.DeviceID(idx);
    
                %   Set up callback functions
                app.d.ScansAvailableFcn = @(src, event) storeData(app, src, event);
                    % call storeData fcn when scans are available
                app.d.ScansAvailableFcnCount = app.SamplerateEditField.Value/app.VoltagefrequencyEditField.Value;
                    % by default, call storeData every cycle
                app.d.ErrorOccurredFcn = @(src, event) errorFcn(app, src, event);
                    % call errorFcn when DAQ throws an error
                
                % Add output channels to the DAQ
                addoutput(app.d, app.devName, "ao0", "Voltage");
                    % TREK voltage input
                addoutput(app.d, app.devName, "ao1", "Voltage");
                    % MT force input
                
                % Add input channels to the DAQ
                addinput(app.d, app.devName, "ai0", "Voltage");
                    % TREK voltage monitor
                addinput(app.d, app.devName, "ai1", "Voltage");
                    % MT force out
                addinput(app.d, app.devName, "ai2", "Voltage");
                    % MT length out
                addinput(app.d, app.devName, "ai3", "Voltage");
                    % TREK current out
                addinput(app.d, app.devName, "ai7", "Voltage");
                    % TREK limit/trip status
            end   
            pause('on');
        end

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)
            % Collect filepath
            filepath = uigetdir;
            
            % Bring UI window to the front (MATLAB bug)
            drawnow;
            figure(app.UIFigure)
            
            % Check for empty filepath
            try
                app.SelectfilepathEditField.Value = filepath;
            catch
                uiwait(msgbox("No filepath selected", "Warning", 'warn', 'modal'));
                app.SelectfilepathEditField.Value = "";
            end
        end

        % Value changed function: GoButton
        function GoButtonValueChanged(app, event)
            if app.GoButton.Value
                % Block button input until function complete
                app.GoButton.Enable = 0;

                % Check for valid filenames
                if app.RawdatafilenameEditField == ""
                    uiwait(msgbox("Empty filename", "Error", 'modal'));
                    app.GoButton.Value = 0;
                    buildPreview(app);
                    return
                end
                
                % Open data file ID
                app.rawFileID = fopen(fullfile(app.SelectfilepathEditField.Value, app.RawdatafilenameEditField.Value), 'w');

                % Print header
                if app.ACactuationCheckBox.Value
                    fprintf(app.rawFileID, 'Sample rate: %.4f Hz\tkV: %.4f kV/V\tkF: %.4f N/V\tkL: %.4f mm/V\tAC frequency: %.4f Hz\nTime (s), Voltage (V), Force (V), Length (V), Current (V)\n',...
                        [app.sampleRate; app.kV; app.kF; app.kL; app.ACfrequencyEditField.Value]);
                else
                    fprintf(app.rawFileID, 'Sample rate: %.4f Hz\tkV: %.4f kV/V\tkF: %.4f N/V\tkL: %.4f mm/V\nTime (s), Voltage (V), Force (V), Length (V), Current (V)\n',...
                        [app.sampleRate; app.kV; app.kF; app.kL]);
                end
                
                % Prepare axes
                % Check this, seems redundant...
                app.UIAxes.YAxis(2).Visible = 'on';
                xlabel(app.UIAxes, 'Time (s)');
                yyaxis(app.UIAxes, 'right');
                cla(app.UIAxes);
                ylim(app.UIAxes, 'auto');
                hold(app.UIAxes, 'on');
                ylabel(app.UIAxes, 'Force (N)');
                yyaxis(app.UIAxes, 'left');
                cla(app.UIAxes);
                ylim(app.UIAxes, 'auto');
                hold(app.UIAxes, 'on');
                ylabel(app.UIAxes, 'Displacement (mm)');
                
                app.GoButton.Text = "Stop";
                app.GoButton.BackgroundColor = 'red';
                if app.MonitorlimittripstatusCheckBox.Value
                    app.Lamp.Color = 'green';
                end
                
                % Build output signal and preload
                fullSignal = buildSignal(app);
                app.lastOutputIndex = length(fullSignal(:, 1));
                app.numScansAcquired = 0;
                
                preload(app.d, fullSignal);
                start(app.d);

                app.GoButton.Enable = 1;
            else
                % End test

                % Block button input until function complete
                app.GoButton.Enable = 0;
                
                % Stop the DAQ
                stop(app.d);
                                
                % Read residual data from DAQ
                if app.d.NumScansAvailable > 0
                    storeData(app, app.d, 0);
                end
                
                % Close file ID
                fclose(app.rawFileID);
                
                % Fush the DAQ and ensure zero voltage
                flush(app.d);
                write(app.d, [0, 0]);
                
                app.GoButton.BackgroundColor = [0.96, 0.96, 0.96];
                app.GoButton.Text = 'Go';

                app.GoButton.Enable = 1;
            end
        end

        % Value changed function: SamplerateEditField
        function SamplerateEditFieldValueChanged(app, event)
            % Change app property
            app.sampleRate = app.SamplerateEditField.Value;

            % Change DAQ buffer count
            if app.AdvancedsettingsCheckBox.Value
                app.d.ScansAvailableFcnCount = cast(app.sampleRate*sum(app.actTimeArr), 'uint64');
            else
                app.d.ScansAvailableFcnCount = cast(app.sampleRate/app.VoltagefrequencyEditField.Value, 'uint64');
            end

            % Change DAQ rate
            app.d.Rate = app.sampleRate;
            
            buildPreview(app);
        end

        % Value changed function: TREKvoltageconstantkVEditField
        function TREKvoltageconstantkVEditFieldValueChanged(app, event)
           app.kV = app.TREKvoltageconstantkVEditField.Value/1000;
           app.MaxvoltageEditFieldValueChanged(app);
        end

        % Value changed function: MTforceconstantkFEditField
        function MTforceconstantkFEditFieldValueChanged(app, event)
            app.kF = app.MTforceconstantkFEditField.Value;
        end

        % Value changed function: MTlengthconstantkLEditField
        function MTlengthconstantkLEditFieldValueChanged(app, event)
            app.kL = app.MTlengthconstantkLEditField.Value;
        end

        % Value changed function: VoltagefrequencyEditField
        function VoltagefrequencyEditFieldValueChanged(app, event)
            buildPreview(app);
        end

        % Value changed function: MaxvoltageEditField
        function MaxvoltageEditFieldValueChanged(app, event)
            app.maxVoltage = app.MaxvoltageEditField.Value/app.kV;
            buildPreview(app);
        end

        % Value changed function: NumberofvoltcyclesperstepEditField
        function NumberofvoltcyclesperstepEditFieldValueChanged(app, event)
            buildPreview(app);
        end

        % Value changed function: ReversepolarityCheckBox
        function ReversepolarityCheckBoxValueChanged(app, event)
            buildPreview(app);
        end

        % Value changed function: LogdistributionCheckBox
        function LogdistributionCheckBoxValueChanged(app, event)
            buildPreview(app);
        end

        % Value changed function: MaxforceEditField
        function MaxforceEditFieldValueChanged(app, event)
            buildPreview(app);
        end

        % Value changed function: NumberofforcestepsEditField
        function NumberofforcestepsEditFieldValueChanged(app, event)
            if app.NumberofforcestepsEditField.Value == 1
                app.LogdistributionCheckBox.Value = 0;
                app.LogdistributionCheckBox.Enable = 0;
            elseif ~app.LogdistributionCheckBox.Enable
                app.LogdistributionCheckBox.Enable = 1;
            end
            
            buildPreview(app);
        end

        % Value changed function: MonitorlimittripstatusCheckBox
        function MonitorlimittripstatusCheckBoxValueChanged(app, event)
            if app.MonitorlimittripstatusCheckBox.Value
                app.Lamp.Enable = 1;
                app.Lamp.Color = 'green';
            else
                app.Lamp.Enable = 0;
                app.Lamp.Color = [0.96, 0.96, 0.96];
            end
        end

        % Value changed function: SignaltypeDropDown
        function SignaltypeDropDownValueChanged(app, event)
            if strcmp(app.SignaltypeDropDown.Value, 'Ramped square')
                app.RamptimeEditField.Enable = 1;
            else
                app.RamptimeEditField.Enable = 0;
            end
            
            buildPreview(app);
        end

        % Value changed function: RamptimeEditField
        function RamptimeEditFieldValueChanged(app, event)
            if app.RamptimeEditField.Value > (1/(app.VoltagefrequencyEditField.Value*2)*1000)
                uiwait(msgbox("Ramp time too long you fool", "Error", 'modal'));
                app.RamptimeEditField.Value = 1/(app.VoltagefrequencyEditField.Value*6)*1000;
            end
            
            buildPreview(app);            
        end

        % Value changed function: AdvancedsettingsCheckBox
        function AdvancedsettingsCheckBoxValueChanged(app, event)
            if app.AdvancedsettingsCheckBox.Value
                app.AdvancedsettingsPanel.Enable = 'on';
                app.MaxvoltageEditField.Enable = 0;
                app.SignaltypeDropDown.Enable = 0;
                app.VoltagefrequencyEditField.Enable = 0;
                app.RamptimeEditField.Enable = 0;
                
                app.maxVoltage = [app.V_AEditField.Value, app.V_highEditField.Value, app.V_BEditField.Value]/app.kV;

                if app.V_BonCheckBox.Value
                    app.actTimeArr = [app.TimeAEditField.Value, app.RampupEditField.Value, app.TimehighEditField.Value,...
                        app.RampdownEditField.Value, app.TimeBEditField.Value, app.RampfromBEditField.Value]/1000;
                else
                    app.actTimeArr = [app.TimeAEditField.Value, app.RampupEditField.Value, app.TimehighEditField.Value,...
                        app.RampdownEditField.Value]/1000;
                end
                app.d.ScansAvailableFcnCount = cast(app.SamplerateEditField.Value*sum(app.actTimeArr), 'uint64');

            else
                app.AdvancedsettingsPanel.Enable = 'off';
                app.MaxvoltageEditField.Enable = 1;
                app.SignaltypeDropDown.Enable = 1;
                app.VoltagefrequencyEditField.Enable = 1;
                if strcmp(app.SignaltypeDropDown.Value, 'Ramped square')
                    app.RamptimeEditField.Enable = 1;
                end
                
                app.maxVoltage = app.MaxvoltageEditField.Value/app.kV;

                app.d.ScansAvailableFcnCount = cast(app.SamplerateEditField.Value/app.VoltagefrequencyEditField.Value, 'uint64');
            end
            buildPreview(app);
        end

        % Value changed function: V_AEditField
        function V_AEditFieldValueChanged(app, event)
            app.maxVoltage(1) = app.V_AEditField.Value/app.kV;
            buildPreview(app);
        end

        % Value changed function: V_highEditField
        function V_highEditFieldValueChanged(app, event)
            app.maxVoltage(2) = app.V_highEditField.Value/app.kV;
            buildPreview(app);
        end

        % Value changed function: V_BEditField
        function V_BEditFieldValueChanged(app, event)
            app.maxVoltage(3) = app.V_BEditField.Value/app.kV;
            buildPreview(app);
        end

        % Value changed function: TimeAEditField
        function TimeAEditFieldValueChanged(app, event)
            app.actTimeArr(1) = app.TimeAEditField.Value/1000;
            app.d.ScansAvailableFcnCount = cast(app.SamplerateEditField.Value*sum(app.actTimeArr), 'uint64');
            buildPreview(app);
        end

        % Value changed function: RampupEditField
        function RampupEditFieldValueChanged(app, event)
            app.actTimeArr(2) = app.RampupEditField.Value/1000;
            app.d.ScansAvailableFcnCount = cast(app.SamplerateEditField.Value*sum(app.actTimeArr), 'uint64');
            buildPreview(app);
        end

        % Value changed function: TimehighEditField
        function TimehighEditFieldValueChanged(app, event)
            app.actTimeArr(3) = app.TimehighEditField.Value/1000;
            app.d.ScansAvailableFcnCount = cast(app.SamplerateEditField.Value*sum(app.actTimeArr), 'uint64');
            buildPreview(app);
        end

        % Value changed function: RampdownEditField
        function RampdownEditFieldValueChanged(app, event)
            app.actTimeArr(4) = app.RampdownEditField.Value/1000;
            app.d.ScansAvailableFcnCount = cast(app.SamplerateEditField.Value*sum(app.actTimeArr), 'uint64');
            buildPreview(app);
        end

        % Value changed function: TimeBEditField
        function TimeBEditFieldValueChanged(app, event)
            app.actTimeArr(5) = app.TimeBEditField.Value/1000;
            app.d.ScansAvailableFcnCount = cast(app.SamplerateEditField.Value*sum(app.actTimeArr), 'uint64');
            buildPreview(app);
        end

        % Value changed function: RampfromBEditField
        function RampfromBEditFieldValueChanged(app, event)
            app.actTimeArr(6) = app.RampfromBEditField.Value/1000;
            app.d.ScansAvailableFcnCount = cast(app.SamplerateEditField.Value*sum(app.actTimeArr), 'uint64');
            buildPreview(app);
        end

        % Value changed function: ACactuationCheckBox
        function ACactuationCheckBoxValueChanged(app, event)
            buildPreview(app);
        end

        % Value changed function: ACfrequencyEditField
        function ACfrequencyEditFieldValueChanged(app, event)
            buildPreview(app);
        end

        % Value changed function: V_BonCheckBox
        function V_BonCheckBoxValueChanged(app, event)
            if app.V_BonCheckBox.Value
                app.V_BEditField.Enable = 1;
                app.TimeBEditField.Enable = 1;
                app.RampfromBEditField.Enable = 1;
                
                app.maxVoltage = [app.V_AEditField.Value, app.V_highEditField.Value, app.V_BEditField.Value]/app.kV;
                app.actTimeArr = [app.TimeAEditField.Value, app.RampupEditField.Value, app.TimehighEditField.Value,...
                    app.RampdownEditField.Value, app.TimeBEditField.Value, app.RampfromBEditField.Value]/1000;
                
                buildPreview(app);
            else
                app.V_BEditField.Enable = 0;
                app.TimeBEditField.Enable = 0;
                app.RampfromBEditField.Enable = 0;
                                
                app.maxVoltage = [app.V_AEditField.Value, app.V_highEditField.Value]/app.kV;
                app.actTimeArr = [app.TimeAEditField.Value, app.RampupEditField.Value, app.TimehighEditField.Value,...
                    app.RampdownEditField.Value]/1000;
                
                buildPreview(app);
            end
        end

        % Value changed function: RawdatafilenameEditField
        function RawdatafilenameEditFieldValueChanged(app, event)
            if isfile(fullfile(app.SelectfilepathEditField.Value, app.RawdatafilenameEditField.Value))
                uialert(app.UIFigure, 'Filename already exists!', 'Overwrite warning', 'Icon', 'warning');
            elseif strcmp(app.RawdatafilenameEditField.Value, '')
                uialert(app.UIFigure, 'Empty filename!', 'Filename warning', 'Icon', 'warning');
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 813 659];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Data')
            xlabel(app.UIAxes, 'Time (s)')
            ylabel(app.UIAxes, 'Voltage (kV)')
            app.UIAxes.PlotBoxAspectRatio = [1.45226130653266 1 1];
            app.UIAxes.XTickLabelRotation = 0;
            app.UIAxes.YTickLabelRotation = 0;
            app.UIAxes.ZTickLabelRotation = 0;
            app.UIAxes.Position = [9 378 404 278];

            % Create BrowseButton
            app.BrowseButton = uibutton(app.UIFigure, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Position = [699 619 100 22];
            app.BrowseButton.Text = 'Browse';

            % Create GoButton
            app.GoButton = uibutton(app.UIFigure, 'state');
            app.GoButton.ValueChangedFcn = createCallbackFcn(app, @GoButtonValueChanged, true);
            app.GoButton.Text = 'Go';
            app.GoButton.BackgroundColor = [0.9608 0.9608 0.9608];
            app.GoButton.FontSize = 18;
            app.GoButton.FontWeight = 'bold';
            app.GoButton.Position = [642 455 146 69];

            % Create SelectfilepathEditFieldLabel
            app.SelectfilepathEditFieldLabel = uilabel(app.UIFigure);
            app.SelectfilepathEditFieldLabel.HorizontalAlignment = 'right';
            app.SelectfilepathEditFieldLabel.Position = [584 619 101 22];
            app.SelectfilepathEditFieldLabel.Text = 'Select file path:';

            % Create SelectfilepathEditField
            app.SelectfilepathEditField = uieditfield(app.UIFigure, 'text');
            app.SelectfilepathEditField.Position = [412 589 389 22];

            % Create RawdatafilenameEditFieldLabel
            app.RawdatafilenameEditFieldLabel = uilabel(app.UIFigure);
            app.RawdatafilenameEditFieldLabel.HorizontalAlignment = 'right';
            app.RawdatafilenameEditFieldLabel.Position = [413 558 108 22];
            app.RawdatafilenameEditFieldLabel.Text = 'Raw data filename:';

            % Create RawdatafilenameEditField
            app.RawdatafilenameEditField = uieditfield(app.UIFigure, 'text');
            app.RawdatafilenameEditField.ValueChangedFcn = createCallbackFcn(app, @RawdatafilenameEditFieldValueChanged, true);
            app.RawdatafilenameEditField.Position = [537 558 263 22];
            app.RawdatafilenameEditField.Value = 'data.txt';

            % Create SetupPanel
            app.SetupPanel = uipanel(app.UIFigure);
            app.SetupPanel.TitlePosition = 'centertop';
            app.SetupPanel.Title = 'Setup';
            app.SetupPanel.FontWeight = 'bold';
            app.SetupPanel.FontSize = 14;
            app.SetupPanel.Position = [24 151 187 221];

            % Create ao0ao1ai0ai1ai2Label
            app.ao0ao1ai0ai1ai2Label = uilabel(app.SetupPanel);
            app.ao0ao1ai0ai1ai2Label.Position = [12 14 168 175];
            app.ao0ao1ai0ai1ai2Label.Text = {'AO0: TREK "voltage in"'; 'AO1: Muscle tester "force in"'; 'AI0: TREK "voltage monitor"'; 'AI1: Muscle tester "force out"'; 'AI2: Muscle tester "length out"'; 'AI3: TREK current monitor'; 'AI7: TREK "limit/trip status"'; ''; 'Setup:'; '1) Turn length knob to 10 V'; '2) Turn force knob to 0 V'; ''};

            % Create VoltageParametersPanel
            app.VoltageParametersPanel = uipanel(app.UIFigure);
            app.VoltageParametersPanel.TitlePosition = 'centertop';
            app.VoltageParametersPanel.Title = 'Voltage Parameters';
            app.VoltageParametersPanel.FontWeight = 'bold';
            app.VoltageParametersPanel.FontSize = 14;
            app.VoltageParametersPanel.Position = [414 151 187 221];

            % Create VoltagefrequencyEditFieldLabel
            app.VoltagefrequencyEditFieldLabel = uilabel(app.VoltageParametersPanel);
            app.VoltagefrequencyEditFieldLabel.HorizontalAlignment = 'right';
            app.VoltagefrequencyEditFieldLabel.Position = [9 167 99 22];
            app.VoltagefrequencyEditFieldLabel.Text = 'Voltage frequency';

            % Create VoltagefrequencyEditField
            app.VoltagefrequencyEditField = uieditfield(app.VoltageParametersPanel, 'numeric');
            app.VoltagefrequencyEditField.Limits = [0 Inf];
            app.VoltagefrequencyEditField.ValueChangedFcn = createCallbackFcn(app, @VoltagefrequencyEditFieldValueChanged, true);
            app.VoltagefrequencyEditField.Position = [116 167 38 22];
            app.VoltagefrequencyEditField.Value = 1;

            % Create HzLabel_2
            app.HzLabel_2 = uilabel(app.VoltageParametersPanel);
            app.HzLabel_2.Position = [159 167 25 22];
            app.HzLabel_2.Text = 'Hz';

            % Create MaxvoltageEditFieldLabel
            app.MaxvoltageEditFieldLabel = uilabel(app.VoltageParametersPanel);
            app.MaxvoltageEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxvoltageEditFieldLabel.Position = [38 131 70 22];
            app.MaxvoltageEditFieldLabel.Text = 'Max voltage';

            % Create MaxvoltageEditField
            app.MaxvoltageEditField = uieditfield(app.VoltageParametersPanel, 'numeric');
            app.MaxvoltageEditField.Limits = [0 20];
            app.MaxvoltageEditField.ValueChangedFcn = createCallbackFcn(app, @MaxvoltageEditFieldValueChanged, true);
            app.MaxvoltageEditField.Position = [116 131 38 22];
            app.MaxvoltageEditField.Value = 6;

            % Create kVLabel
            app.kVLabel = uilabel(app.VoltageParametersPanel);
            app.kVLabel.Position = [160 131 25 22];
            app.kVLabel.Text = 'kV';

            % Create ReversepolarityCheckBox
            app.ReversepolarityCheckBox = uicheckbox(app.VoltageParametersPanel);
            app.ReversepolarityCheckBox.ValueChangedFcn = createCallbackFcn(app, @ReversepolarityCheckBoxValueChanged, true);
            app.ReversepolarityCheckBox.Text = 'Reverse polarity';
            app.ReversepolarityCheckBox.Position = [47 14 109 22];
            app.ReversepolarityCheckBox.Value = true;

            % Create SignaltypeLabel
            app.SignaltypeLabel = uilabel(app.VoltageParametersPanel);
            app.SignaltypeLabel.HorizontalAlignment = 'right';
            app.SignaltypeLabel.Position = [9 90 39 28];
            app.SignaltypeLabel.Text = {'Signal'; 'type'};

            % Create SignaltypeDropDown
            app.SignaltypeDropDown = uidropdown(app.VoltageParametersPanel);
            app.SignaltypeDropDown.Items = {'Ramped square', 'Triangle', 'Square'};
            app.SignaltypeDropDown.ValueChangedFcn = createCallbackFcn(app, @SignaltypeDropDownValueChanged, true);
            app.SignaltypeDropDown.Position = [55 91 124 22];
            app.SignaltypeDropDown.Value = 'Square';

            % Create RamptimeEditFieldLabel
            app.RamptimeEditFieldLabel = uilabel(app.VoltageParametersPanel);
            app.RamptimeEditFieldLabel.HorizontalAlignment = 'right';
            app.RamptimeEditFieldLabel.Position = [35 52 64 22];
            app.RamptimeEditFieldLabel.Text = 'Ramp time';

            % Create RamptimeEditField
            app.RamptimeEditField = uieditfield(app.VoltageParametersPanel, 'numeric');
            app.RamptimeEditField.Limits = [0 Inf];
            app.RamptimeEditField.RoundFractionalValues = 'on';
            app.RamptimeEditField.ValueChangedFcn = createCallbackFcn(app, @RamptimeEditFieldValueChanged, true);
            app.RamptimeEditField.Enable = 'off';
            app.RamptimeEditField.Position = [112 52 40 22];
            app.RamptimeEditField.Value = 333;

            % Create msLabel
            app.msLabel = uilabel(app.VoltageParametersPanel);
            app.msLabel.Position = [160 52 25 22];
            app.msLabel.Text = 'ms';

            % Create CalibrationPanel
            app.CalibrationPanel = uipanel(app.UIFigure);
            app.CalibrationPanel.TitlePosition = 'centertop';
            app.CalibrationPanel.Title = 'Calibration';
            app.CalibrationPanel.FontWeight = 'bold';
            app.CalibrationPanel.FontSize = 14;
            app.CalibrationPanel.Position = [218 151 187 221];

            % Create SamplerateEditFieldLabel
            app.SamplerateEditFieldLabel = uilabel(app.CalibrationPanel);
            app.SamplerateEditFieldLabel.HorizontalAlignment = 'right';
            app.SamplerateEditFieldLabel.Position = [1 169 75 22];
            app.SamplerateEditFieldLabel.Text = 'Sample rate';

            % Create SamplerateEditField
            app.SamplerateEditField = uieditfield(app.CalibrationPanel, 'numeric');
            app.SamplerateEditField.Limits = [0 Inf];
            app.SamplerateEditField.ValueChangedFcn = createCallbackFcn(app, @SamplerateEditFieldValueChanged, true);
            app.SamplerateEditField.Position = [90 169 58 22];
            app.SamplerateEditField.Value = 1000;

            % Create HzLabel
            app.HzLabel = uilabel(app.CalibrationPanel);
            app.HzLabel.Position = [156 169 25 22];
            app.HzLabel.Text = 'Hz';

            % Create TREKvoltageconstantkVEditFieldLabel
            app.TREKvoltageconstantkVEditFieldLabel = uilabel(app.CalibrationPanel);
            app.TREKvoltageconstantkVEditFieldLabel.HorizontalAlignment = 'center';
            app.TREKvoltageconstantkVEditFieldLabel.Position = [10 123 79 27];
            app.TREKvoltageconstantkVEditFieldLabel.Text = {'TREK voltage'; 'constant (kV)'};

            % Create TREKvoltageconstantkVEditField
            app.TREKvoltageconstantkVEditField = uieditfield(app.CalibrationPanel, 'numeric');
            app.TREKvoltageconstantkVEditField.Limits = [0 Inf];
            app.TREKvoltageconstantkVEditField.ValueChangedFcn = createCallbackFcn(app, @TREKvoltageconstantkVEditFieldValueChanged, true);
            app.TREKvoltageconstantkVEditField.Position = [100 125 48 22];
            app.TREKvoltageconstantkVEditField.Value = 1000;

            % Create MTforceconstantkFEditFieldLabel
            app.MTforceconstantkFEditFieldLabel = uilabel(app.CalibrationPanel);
            app.MTforceconstantkFEditFieldLabel.HorizontalAlignment = 'center';
            app.MTforceconstantkFEditFieldLabel.Position = [11 77 75 27];
            app.MTforceconstantkFEditFieldLabel.Text = {'MT force'; 'constant (kF)'};

            % Create MTforceconstantkFEditField
            app.MTforceconstantkFEditField = uieditfield(app.CalibrationPanel, 'numeric');
            app.MTforceconstantkFEditField.Limits = [0 Inf];
            app.MTforceconstantkFEditField.ValueChangedFcn = createCallbackFcn(app, @MTforceconstantkFEditFieldValueChanged, true);
            app.MTforceconstantkFEditField.Position = [100 82 48 22];
            app.MTforceconstantkFEditField.Value = 9.96;

            % Create MTlengthconstantkLEditFieldLabel
            app.MTlengthconstantkLEditFieldLabel = uilabel(app.CalibrationPanel);
            app.MTlengthconstantkLEditFieldLabel.HorizontalAlignment = 'center';
            app.MTlengthconstantkLEditFieldLabel.Position = [10 31 75 27];
            app.MTlengthconstantkLEditFieldLabel.Text = {'MT length'; 'constant (kL)'};

            % Create MTlengthconstantkLEditField
            app.MTlengthconstantkLEditField = uieditfield(app.CalibrationPanel, 'numeric');
            app.MTlengthconstantkLEditField.Limits = [0 Inf];
            app.MTlengthconstantkLEditField.ValueChangedFcn = createCallbackFcn(app, @MTlengthconstantkLEditFieldValueChanged, true);
            app.MTlengthconstantkLEditField.Position = [100 33 45 22];
            app.MTlengthconstantkLEditField.Value = 1.93;

            % Create NVLabel
            app.NVLabel = uilabel(app.CalibrationPanel);
            app.NVLabel.Position = [155 82 26 22];
            app.NVLabel.Text = 'N/V';

            % Create mmVLabel
            app.mmVLabel = uilabel(app.CalibrationPanel);
            app.mmVLabel.Position = [148 33 37 22];
            app.mmVLabel.Text = 'mm/V';

            % Create VVLabel
            app.VVLabel = uilabel(app.CalibrationPanel);
            app.VVLabel.Position = [156 125 25 22];
            app.VVLabel.Text = 'V/V';

            % Create ForceParametersPanel
            app.ForceParametersPanel = uipanel(app.UIFigure);
            app.ForceParametersPanel.TitlePosition = 'centertop';
            app.ForceParametersPanel.Title = 'Force Parameters';
            app.ForceParametersPanel.FontWeight = 'bold';
            app.ForceParametersPanel.FontSize = 14;
            app.ForceParametersPanel.Position = [612 186 187 186];

            % Create MaxforceEditFieldLabel
            app.MaxforceEditFieldLabel = uilabel(app.ForceParametersPanel);
            app.MaxforceEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxforceEditFieldLabel.Position = [-5 134 104 22];
            app.MaxforceEditFieldLabel.Text = 'Max force';

            % Create MaxforceEditField
            app.MaxforceEditField = uieditfield(app.ForceParametersPanel, 'numeric');
            app.MaxforceEditField.Limits = [0 90];
            app.MaxforceEditField.ValueChangedFcn = createCallbackFcn(app, @MaxforceEditFieldValueChanged, true);
            app.MaxforceEditField.Position = [114 134 28 22];
            app.MaxforceEditField.Value = 20;

            % Create NLabel
            app.NLabel = uilabel(app.ForceParametersPanel);
            app.NLabel.Position = [148 134 25 22];
            app.NLabel.Text = 'N';

            % Create NumberofforcestepsLabel
            app.NumberofforcestepsLabel = uilabel(app.ForceParametersPanel);
            app.NumberofforcestepsLabel.HorizontalAlignment = 'right';
            app.NumberofforcestepsLabel.Position = [25 93 74 28];
            app.NumberofforcestepsLabel.Text = {'Number of'; 'force steps'};

            % Create NumberofforcestepsEditField
            app.NumberofforcestepsEditField = uieditfield(app.ForceParametersPanel, 'numeric');
            app.NumberofforcestepsEditField.Limits = [1 Inf];
            app.NumberofforcestepsEditField.RoundFractionalValues = 'on';
            app.NumberofforcestepsEditField.ValueChangedFcn = createCallbackFcn(app, @NumberofforcestepsEditFieldValueChanged, true);
            app.NumberofforcestepsEditField.Position = [114 96 28 22];
            app.NumberofforcestepsEditField.Value = 10;

            % Create inclzeroLabel
            app.inclzeroLabel = uilabel(app.ForceParametersPanel);
            app.inclzeroLabel.HorizontalAlignment = 'center';
            app.inclzeroLabel.Position = [139 88 43 39];
            app.inclzeroLabel.Text = {'(incl.'; 'zero)'};

            % Create LogdistributionCheckBox
            app.LogdistributionCheckBox = uicheckbox(app.ForceParametersPanel);
            app.LogdistributionCheckBox.ValueChangedFcn = createCallbackFcn(app, @LogdistributionCheckBoxValueChanged, true);
            app.LogdistributionCheckBox.Text = 'Log distribution';
            app.LogdistributionCheckBox.Position = [42 13 103 22];
            app.LogdistributionCheckBox.Value = true;

            % Create NumberofvoltcyclesperstepEditFieldLabel
            app.NumberofvoltcyclesperstepEditFieldLabel = uilabel(app.ForceParametersPanel);
            app.NumberofvoltcyclesperstepEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofvoltcyclesperstepEditFieldLabel.Position = [-37 52 142 28];
            app.NumberofvoltcyclesperstepEditFieldLabel.Text = {'Number of volt'; 'cycles per step'};

            % Create NumberofvoltcyclesperstepEditField
            app.NumberofvoltcyclesperstepEditField = uieditfield(app.ForceParametersPanel, 'numeric');
            app.NumberofvoltcyclesperstepEditField.Limits = [1 Inf];
            app.NumberofvoltcyclesperstepEditField.RoundFractionalValues = 'on';
            app.NumberofvoltcyclesperstepEditField.ValueChangedFcn = createCallbackFcn(app, @NumberofvoltcyclesperstepEditFieldValueChanged, true);
            app.NumberofvoltcyclesperstepEditField.Position = [114 55 28 22];
            app.NumberofvoltcyclesperstepEditField.Value = 4;

            % Create MonitorlimittripstatusCheckBox
            app.MonitorlimittripstatusCheckBox = uicheckbox(app.UIFigure);
            app.MonitorlimittripstatusCheckBox.ValueChangedFcn = createCallbackFcn(app, @MonitorlimittripstatusCheckBoxValueChanged, true);
            app.MonitorlimittripstatusCheckBox.Text = 'Monitor limit/trip status';
            app.MonitorlimittripstatusCheckBox.Position = [644 402 142 22];

            % Create Lamp
            app.Lamp = uilamp(app.UIFigure);
            app.Lamp.Position = [618 403 20 20];

            % Create AdvancedsettingsPanel
            app.AdvancedsettingsPanel = uipanel(app.UIFigure);
            app.AdvancedsettingsPanel.Enable = 'off';
            app.AdvancedsettingsPanel.Title = 'Advanced settings';
            app.AdvancedsettingsPanel.Position = [24 14 773 126];

            % Create TimeBEditFieldLabel
            app.TimeBEditFieldLabel = uilabel(app.AdvancedsettingsPanel);
            app.TimeBEditFieldLabel.HorizontalAlignment = 'right';
            app.TimeBEditFieldLabel.Position = [262 8 43 22];
            app.TimeBEditFieldLabel.Text = 'Time B';

            % Create TimeBEditField
            app.TimeBEditField = uieditfield(app.AdvancedsettingsPanel, 'numeric');
            app.TimeBEditField.ValueChangedFcn = createCallbackFcn(app, @TimeBEditFieldValueChanged, true);
            app.TimeBEditField.Enable = 'off';
            app.TimeBEditField.Position = [311 8 55 22];

            % Create TimehighEditFieldLabel
            app.TimehighEditFieldLabel = uilabel(app.AdvancedsettingsPanel);
            app.TimehighEditFieldLabel.HorizontalAlignment = 'right';
            app.TimehighEditFieldLabel.Position = [248 41 58 22];
            app.TimehighEditFieldLabel.Text = 'Time high';

            % Create TimehighEditField
            app.TimehighEditField = uieditfield(app.AdvancedsettingsPanel, 'numeric');
            app.TimehighEditField.ValueChangedFcn = createCallbackFcn(app, @TimehighEditFieldValueChanged, true);
            app.TimehighEditField.Position = [311 41 55 22];
            app.TimehighEditField.Value = 950;

            % Create RampupEditFieldLabel
            app.RampupEditFieldLabel = uilabel(app.AdvancedsettingsPanel);
            app.RampupEditFieldLabel.HorizontalAlignment = 'right';
            app.RampupEditFieldLabel.Position = [424 72 54 22];
            app.RampupEditFieldLabel.Text = 'Ramp up';

            % Create RampupEditField
            app.RampupEditField = uieditfield(app.AdvancedsettingsPanel, 'numeric');
            app.RampupEditField.ValueChangedFcn = createCallbackFcn(app, @RampupEditFieldValueChanged, true);
            app.RampupEditField.Position = [483 72 48 22];
            app.RampupEditField.Value = 50;

            % Create V_BEditFieldLabel
            app.V_BEditFieldLabel = uilabel(app.AdvancedsettingsPanel);
            app.V_BEditFieldLabel.HorizontalAlignment = 'right';
            app.V_BEditFieldLabel.Position = [140 8 28 22];
            app.V_BEditFieldLabel.Text = 'V_B';

            % Create V_BEditField
            app.V_BEditField = uieditfield(app.AdvancedsettingsPanel, 'numeric');
            app.V_BEditField.Limits = [-50 50];
            app.V_BEditField.ValueChangedFcn = createCallbackFcn(app, @V_BEditFieldValueChanged, true);
            app.V_BEditField.Enable = 'off';
            app.V_BEditField.Position = [179 8 37 22];

            % Create RampdownEditFieldLabel
            app.RampdownEditFieldLabel = uilabel(app.AdvancedsettingsPanel);
            app.RampdownEditFieldLabel.HorizontalAlignment = 'right';
            app.RampdownEditFieldLabel.Position = [408 41 70 22];
            app.RampdownEditFieldLabel.Text = 'Ramp down';

            % Create RampdownEditField
            app.RampdownEditField = uieditfield(app.AdvancedsettingsPanel, 'numeric');
            app.RampdownEditField.ValueChangedFcn = createCallbackFcn(app, @RampdownEditFieldValueChanged, true);
            app.RampdownEditField.Position = [484 41 47 22];
            app.RampdownEditField.Value = 50;

            % Create kVLabel_2
            app.kVLabel_2 = uilabel(app.AdvancedsettingsPanel);
            app.kVLabel_2.Position = [224 8 25 22];
            app.kVLabel_2.Text = 'kV';

            % Create kVLabel_3
            app.kVLabel_3 = uilabel(app.AdvancedsettingsPanel);
            app.kVLabel_3.Position = [224 42 25 22];
            app.kVLabel_3.Text = 'kV';

            % Create msLabel_2
            app.msLabel_2 = uilabel(app.AdvancedsettingsPanel);
            app.msLabel_2.Position = [372 72 25 22];
            app.msLabel_2.Text = 'ms';

            % Create msLabel_3
            app.msLabel_3 = uilabel(app.AdvancedsettingsPanel);
            app.msLabel_3.Position = [373 8 25 22];
            app.msLabel_3.Text = 'ms';

            % Create msLabel_4
            app.msLabel_4 = uilabel(app.AdvancedsettingsPanel);
            app.msLabel_4.Position = [539 72 25 22];
            app.msLabel_4.Text = 'ms';

            % Create msLabel_5
            app.msLabel_5 = uilabel(app.AdvancedsettingsPanel);
            app.msLabel_5.Position = [540 41 25 22];
            app.msLabel_5.Text = 'ms';

            % Create V_highEditFieldLabel
            app.V_highEditFieldLabel = uilabel(app.AdvancedsettingsPanel);
            app.V_highEditFieldLabel.HorizontalAlignment = 'right';
            app.V_highEditFieldLabel.Position = [128 42 43 22];
            app.V_highEditFieldLabel.Text = 'V_high';

            % Create V_highEditField
            app.V_highEditField = uieditfield(app.AdvancedsettingsPanel, 'numeric');
            app.V_highEditField.Limits = [-50 50];
            app.V_highEditField.ValueChangedFcn = createCallbackFcn(app, @V_highEditFieldValueChanged, true);
            app.V_highEditField.Position = [179 42 37 22];
            app.V_highEditField.Value = 5;

            % Create ACactuationCheckBox
            app.ACactuationCheckBox = uicheckbox(app.AdvancedsettingsPanel);
            app.ACactuationCheckBox.ValueChangedFcn = createCallbackFcn(app, @ACactuationCheckBoxValueChanged, true);
            app.ACactuationCheckBox.Text = 'AC actuation';
            app.ACactuationCheckBox.Position = [618 72 91 22];

            % Create ACfrequencyEditFieldLabel
            app.ACfrequencyEditFieldLabel = uilabel(app.AdvancedsettingsPanel);
            app.ACfrequencyEditFieldLabel.HorizontalAlignment = 'right';
            app.ACfrequencyEditFieldLabel.Position = [571 38 78 22];
            app.ACfrequencyEditFieldLabel.Text = 'AC frequency';

            % Create ACfrequencyEditField
            app.ACfrequencyEditField = uieditfield(app.AdvancedsettingsPanel, 'numeric');
            app.ACfrequencyEditField.ValueChangedFcn = createCallbackFcn(app, @ACfrequencyEditFieldValueChanged, true);
            app.ACfrequencyEditField.Position = [663 38 65 22];
            app.ACfrequencyEditField.Value = 500;

            % Create HzLabel_3
            app.HzLabel_3 = uilabel(app.AdvancedsettingsPanel);
            app.HzLabel_3.Position = [733 38 25 22];
            app.HzLabel_3.Text = 'Hz';

            % Create TimeAEditFieldLabel
            app.TimeAEditFieldLabel = uilabel(app.AdvancedsettingsPanel);
            app.TimeAEditFieldLabel.HorizontalAlignment = 'right';
            app.TimeAEditFieldLabel.Position = [262 72 43 22];
            app.TimeAEditFieldLabel.Text = 'Time A';

            % Create TimeAEditField
            app.TimeAEditField = uieditfield(app.AdvancedsettingsPanel, 'numeric');
            app.TimeAEditField.ValueChangedFcn = createCallbackFcn(app, @TimeAEditFieldValueChanged, true);
            app.TimeAEditField.Position = [312 72 54 22];
            app.TimeAEditField.Value = 950;

            % Create msLabel_6
            app.msLabel_6 = uilabel(app.AdvancedsettingsPanel);
            app.msLabel_6.Position = [373 41 25 22];
            app.msLabel_6.Text = 'ms';

            % Create RampfromBEditFieldLabel
            app.RampfromBEditFieldLabel = uilabel(app.AdvancedsettingsPanel);
            app.RampfromBEditFieldLabel.HorizontalAlignment = 'right';
            app.RampfromBEditFieldLabel.Position = [403 8 76 22];
            app.RampfromBEditFieldLabel.Text = 'Ramp from B';

            % Create RampfromBEditField
            app.RampfromBEditField = uieditfield(app.AdvancedsettingsPanel, 'numeric');
            app.RampfromBEditField.ValueChangedFcn = createCallbackFcn(app, @RampfromBEditFieldValueChanged, true);
            app.RampfromBEditField.Enable = 'off';
            app.RampfromBEditField.Position = [485 8 46 22];

            % Create msLabel_7
            app.msLabel_7 = uilabel(app.AdvancedsettingsPanel);
            app.msLabel_7.Position = [540 8 25 22];
            app.msLabel_7.Text = 'ms';

            % Create V_AEditFieldLabel
            app.V_AEditFieldLabel = uilabel(app.AdvancedsettingsPanel);
            app.V_AEditFieldLabel.HorizontalAlignment = 'right';
            app.V_AEditFieldLabel.Position = [143 72 28 22];
            app.V_AEditFieldLabel.Text = 'V_A';

            % Create V_AEditField
            app.V_AEditField = uieditfield(app.AdvancedsettingsPanel, 'numeric');
            app.V_AEditField.Limits = [-50 50];
            app.V_AEditField.ValueChangedFcn = createCallbackFcn(app, @V_AEditFieldValueChanged, true);
            app.V_AEditField.Position = [179 72 37 22];

            % Create kVLabel_4
            app.kVLabel_4 = uilabel(app.AdvancedsettingsPanel);
            app.kVLabel_4.Position = [223 72 25 22];
            app.kVLabel_4.Text = 'kV';

            % Create V_BonCheckBox
            app.V_BonCheckBox = uicheckbox(app.AdvancedsettingsPanel);
            app.V_BonCheckBox.ValueChangedFcn = createCallbackFcn(app, @V_BonCheckBoxValueChanged, true);
            app.V_BonCheckBox.Text = 'V_B on';
            app.V_BonCheckBox.Position = [33 8 62 22];

            % Create AdvancedsettingsCheckBox
            app.AdvancedsettingsCheckBox = uicheckbox(app.UIFigure);
            app.AdvancedsettingsCheckBox.ValueChangedFcn = createCallbackFcn(app, @AdvancedsettingsCheckBoxValueChanged, true);
            app.AdvancedsettingsCheckBox.Text = 'Advanced settings';
            app.AdvancedsettingsCheckBox.Position = [646 151 120 22];

            % Create LiveplotCheckBox
            app.LiveplotCheckBox = uicheckbox(app.UIFigure);
            app.LiveplotCheckBox.Text = 'Live plot';
            app.LiveplotCheckBox.Position = [405 414 67 22];
            app.LiveplotCheckBox.Value = true;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ForceControl_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end