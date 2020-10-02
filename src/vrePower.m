%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Copyright (C) 2016-2020 Philip Tafarte
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.
%
% Contact: philip.tafarte@ufz.de
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function for variable renewable electricity generation including power storage
%

function [residualLoad,powerYear,RENsharedynstorage,RENshare100]...
    =   vrePower(onShore,offShore,photoV,powerLoad,totLoadPower,...
    MustRun,RENMustRun,powerStorage,powerStorageMax,PVcapFacInst,WindOncapFacInst,WindOffcapFacInst)

for i=1:7
    powerYear(i)=2020+5*(i-1);
    
    Demand = powerLoad'*(totLoadPower(i)/totLoadPower(1));
    
    S_S = PVcapFacInst(i,:)';
    S_E = powerLoad*0;
    S_W = powerLoad*0;
    W_B = WindOncapFacInst(i,:)';
    W_A = powerLoad*0;
    W_O = WindOffcapFacInst(i,:)';
      
    %check for Demand - MustRun < 0
    % if Demand in any time is already served by Mustrun, RENshare
    % calculations are not correct
    
    SumnegMustRun = 0;
    
    for k=1:length(powerLoad)
        if ( Demand(k) - MustRun - RENMustRun) < 0
            SumnegMustRun = SumnegMustRun  -  ( Demand(k) - ( MustRun / (1) + RENMustRun / (1) ) );
            % elseif  Demand(k) - (Sscaled(k) + Wscaled(k)) > 0
            %    SumposRL = SumposRL  + ( Demand(k) - ( Sscaled(k) + Wscaled(k) ) / (3) );
        end
        
    end
    %multiplication factor for each step of the 100x100 array
    %with 1 equivalent to 1MW for the profile time series (dimension less share of overall installed capacities
    CAPFAC= 1000;
    
    s_S_loop=photoV(i);
    s_E_loop=1;
    s_W_loop=1;
    
    s_S= CAPFAC.*(s_S_loop-1);
    s_E= CAPFAC.*(s_E_loop-1);
    s_W= CAPFAC.*(s_W_loop-1);
    
    w_B_loop=onShore(i);
    w_A_loop=1;
    w_O_loop=offShore(i);
    
    % multiplication with capacity factor which are equivalent with 1000MW of installed
    % capacity in the feed-in time series for wind
    % different to the timeseries code, Factor 2 is applied (2000MW steps) to cover
    % sufficient capacities in a 100x100 Matrix
    
    w_B= CAPFAC.*(w_B_loop-1);%[CAPFAC * (w_B_loop-1) ];
    w_A= CAPFAC.*(w_A_loop-1);%[CAPFAC * (w_A_loop-1) ];
    w_O= CAPFAC.*(w_O_loop-1);%[CAPFAC * (w_O_loop-1) ];
    
    %resulting feed-in
    S_S_scaled = S_S.*s_S;
    S_E_scaled = S_E.*s_E;
    S_W_scaled = S_W.*s_W;
    W_B_scaled = W_B.*w_B;
    W_A_scaled = W_A.*w_A;
    W_O_scaled = W_O.*w_O;
    
    %resulting RL
    RL= Demand' - S_S_scaled - S_E_scaled - S_W_scaled - W_B_scaled - W_A_scaled - W_O_scaled - MustRun - RENMustRun;
    
    % 3 year balances of 1h values [MWh/a]
    SumDemand = sum(Demand);
    SumS = ( sum(S_S_scaled) + sum(S_E_scaled) + sum(S_W_scaled) );
    SumW = ( sum(W_B_scaled) + sum(W_A_scaled) + sum(W_O_scaled) );
    %SumRL = sum(RL)/(3)
    
    % calculation sum for all elements RL < 0
    % or alternatively "sum (RL (RL<=0)) / 1"
    
    SumnegRL = 0;
    %SumposRL = 0;
    
    for k=1:length(powerLoad)
        if ( Demand(k) - (S_S_scaled(k) + S_E_scaled(k) + S_W_scaled(k) + W_B_scaled(k) + W_A_scaled(k) + W_O_scaled(k)+ MustRun + RENMustRun ) ) < 0
            SumnegRL = SumnegRL  - ( ( Demand(k) - (S_S_scaled(k) + S_E_scaled(k) + S_E_scaled(k) + W_B_scaled(k) + W_A_scaled(k) + W_O_scaled(k)+ MustRun + RENMustRun) ) / (1) );
            % elseif  Demand(k) - (Sscaled(k) + Wscaled(k)) > 0
            %    SumposRL = SumposRL  + ( Demand(k) - ( Sscaled(k) + Wscaled(k) ) / (3) );
        end
    end
    
    %%
    
    %  Storage model parametrization
    
    % storage efficiency
    StE = [0.9];
    
    % storage power limit
    StP = powerStorage(i);
    
    StCmax = powerStorageMax(i);
    
    % storage calculation
    StC = [0];
    %     StCread = [];
    
    % RLafterstorage is the RL after transfer to/from storage
    RLafterstorage = [0];
    SumposRLafterstorage = [0];
    
    for k=1:length(powerLoad)
        
        % if there is excess power
        if    RL(k) < 0
            
            % if storage is full allready
            if  StC >= StCmax
                RLafterstorage(k) = RL(k);
                StC = StCmax;
                
            else
                % if available storage is bigger than actual excess
                if   (StCmax - StC)   >=  - ( RL(k) / StE )
                    % case in which excess exceeds StP
                    if StP <= - RL(k)
                        RLafterstorage(k)= RL(k) + StP;
                        StC = StC + ( StP * StE ) ;
                        % case in which excess is lower than StP
                    else
                        RLafterstorage(k)= 0;
                        StC = StC - ( RL(k) *StE );
                    end
                    
                    % case in which available storage is lower than actual excess
                else
                    
                    % if available storage is smaller than actual excess
                    if   StP   >= (StCmax - StC )
                        
                        RLafterstorage(k) = RL(k) + (StCmax - StC ) ;
                        StC = StC + ( (StCmax - StC )* StE );
                        
                    else
                        % case in which excess exceeds StP
                        %    if StP <= - RL(k)
                        RLafterstorage(k)= RL(k) + StP;
                        StC = StC + (StP * StE) ;
                        
                    end
                    
                end
            end
            
            
            % cases with no excess energy (or pos. RL)
        else
            
            % case in which storage is empty
            if  StC <= 0
                SumposRLafterstorage = SumposRLafterstorage + RL(k) ;
                RLafterstorage(k) = RL(k);
                
                % cases with storage not empty
            else
                % case for storage content bigger than RL
                if StC >=  RL(k)
                    % case RL bigger than StP
                    if  RL(k) >= StP
                        SumposRLafterstorage = SumposRLafterstorage +  RL(k) -StP ;
                        RLafterstorage(k) = RL(k) - StP;
                        StC = StC - (StP * (1/StE) );
                        % case RL lower than StP
                    else
                        SumposRLafterstorage = SumposRLafterstorage +  0 ;
                        RLafterstorage(k) = 0;
                        StC = StC - (RL(k) * (1/StE));
                    end
                    
                    % case storage content lower than RL
                else
                    
                    
                    % case storage content bigger than StP
                    if  StC >= StP
                        SumposRLafterstorage = SumposRLafterstorage +  RL(k) -StP ;
                        RLafterstorage(k) = RL(k) - StP;
                        StC = StC - (StP * (1/StE));
                        % case RL lower than StP
                    else
                        
                        
                        
                        SumposRLafterstorage = SumposRLafterstorage +  RL(k) - StC ;
                        RLafterstorage(k) = RL(k) - StC ;
                        StC = 0;
                    end
                end
            end
        end
        
        % adding of StCread is very time consuming and only used to verify storage operation
        %StCread= [StCread StC];
        
    end
    
    
    %%
    SumposRL = SumDemand - (SumS + SumW - SumnegRL) - (length(powerLoad) * MustRun)/ 1 - (length(powerLoad) * RENMustRun)/ 1 ;
    
    % disp('number of points in time '); disp(k);
    
    RENshare100(i) =   (SumS + SumW + (length(powerLoad) * RENMustRun) / 1)  / SumDemand ;
    % disp('REN share with 100% effective storage '); disp(RENshare100);
    
    RENsharestorage(i) = 1 - ( (SumposRL - SumnegRL * StE ) / SumDemand ) ;
    % disp('REN share with XY% effective storage and unlimited power+capacity '); disp(RENsharestorage);
    % disp('assuming a storage efficiency of');  disp(StE);
    
    % new
    RENsharedynstorage(i) =  1 - ( (SumposRLafterstorage / 1 + (length(powerLoad) * MustRun)/ 1  ) / SumDemand ) ;
    % disp('RENshare with dynamic storage'); disp(RENsharedynstorage);
    
    SumposRLafterstorage;
    
    RENshare(i) =  1 - ((SumposRL + (length(powerLoad) * MustRun)/ 1 ) / SumDemand ) ;
    % disp('REN share without storage '); disp(RENshare);
      
    residualLoad(:,i)   =   RLafterstorage;
end
end