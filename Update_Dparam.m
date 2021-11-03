%Update Detection parameters
function Update_Dparam(arduinoObj,threshold_R,threshold_L,threshold_FS,steps,duration)
   writeline(arduinoObj,"u");
   new_strD_param = strcat(num2str(threshold_R),",",num2str(threshold_L),",",num2str(threshold_FS),",",num2str(steps),",",num2str(duration));
   
   writeline(arduinoObj,new_strD_param);
   readNline(arduinoObj,3); %"Complete recieving new D_params"
                            %
                            %"Restart detection"
end