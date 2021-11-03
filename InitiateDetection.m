function InitiateDetection(arduinoObj,threshold_R,threshold_L,threshold_FS,steps,duration)

%initialization of detection
writeline(arduinoObj,"d");
strD_param = strcat(num2str(threshold_R),",",num2str(threshold_L),",",num2str(threshold_FS),",",num2str(steps),",",num2str(duration));
%send thresholds to Arduino
writeline(arduinoObj,strD_param);

readNline(arduinoObj,3)  %"Complete Recieving D_params"
                         %  
                         %"start detection"

end