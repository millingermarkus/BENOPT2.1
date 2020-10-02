%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BENOPT (BioENergy OPTimisation model)
%     Copyright (C) 2012-2020 Markus Millinger
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
% Contact: markus.millinger@ufz.de
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plotting of results (example)

function plotting(s,f,o,p,g,surplusPowerVar,surplusPowerVar2,gamsOut,noScenarios,paretoVar,noPareto,iterStep)


%%
%FIGURES
tic
%%
col =   setCol;
% colororder=col;
titleVector={'S1 Base','S2 MoreH2','S3 NoLand','S4 CCSBase','S5 CCSMoreH2','S6 CCSNoLand'};
titleVector2={'Base','MoreH2','NoLand','CCSBase','CCSMoreH2','CCSNoLand'};
%%
%% Sorting techs into sectors for plotting
g.TS=cell(1,s.numSectors);
for j=1:s.numSectors
    g.TS{j}=transpose(find(g.techsectors(:,j)==1));
end

[row,cols]=find(g.techsectors(:,6:9)==1);
g.TStrans=transpose(unique(row));

[row,cols]=find(g.techsectors(:,1:9)==1);
g.TSall=transpose(unique(row));

[row,cols]=find(g.techsectors(:,1)==1);
g.TSindTH=transpose(unique(row));

[row,cols]=find(g.techsectors(:,2)==1);
g.TSghdTH=transpose(unique(row));

[row,cols]=find(g.techsectors(:,3)==1);
g.TShhTH=transpose(unique(row));

[row,cols]=find(s.powerByprodInit(:)==1);
g.TSconvEL=transpose(unique(row));

[row,cols]=find(g.techsectors(:,4)==1);
g.TSconvELgrid=transpose(unique(row));

[row,cols]=find(g.techsectors(:,5)==1);
g.TSconvTH=transpose(unique(row));

% %%
% for scenario    =   1
%
%     %     Dsum                            =   sum(g.Demand,1)';    % Sum of demand
%
% %     if scenario <=2
%     %% Surplus power plot
%     figure(92918)
% %     x = [7,5,3,1];
%     x = [2500,1500,800,10];
%     timePoint=[2050,2040,2030,2020]-2019;
%     for i=1:4
% %         stairs(surplusPowerVar(scenario,:,timePoint(i)));
%         hold on
%         plot(1000*surplusPowerVar2(scenario,:,timePoint(i)));
%
%         text(x(i),1000*surplusPowerVar(scenario,x(i),timePoint(i))+4,num2str(timePoint(i)+2019),'VerticalAlignment','top');%,'HorizontalAlignment','center')
%     end
%     grid on
% %         xlim([1 max(g.timeStepsIntraYear)])
%         xlim([0 5000])
%     if scenario==1%noScenarios
%         ylabel('GW')
% %         xlabel(['Intra-year steps (1 \leq t_{st} \leq ' num2str(max(g.timeStepsIntraYear)) ')'])
%         xlabel('Hours per year')
%         title('Surplus power within given years')
%         print(gcf,'-painters','-depsc','-loose','../fig/residualLoad')
%         saveas(gcf,'../fig/residualLoad.tif')
%     end
% end

%% Fuel deployment across sectors
for scenario=1:3
    figure (1+scenario)
    k=1;
    for j=1:s.numSectors%[6 8 9 7 10 11] %1:s.numSectors
        %         if k<4
        subplot(3,4,k)
        %         else
        %             subplot(2,4,k+1)
        %         end
        k=k+1;
        if j==4 % CONVel = CONVel+ KWK Power from Industrie and Gebäude
            h=area(gamsOut(scenario).prd(:,g.TSconvEL,j).*s.powerByprod(:,g.TSconvEL));
        elseif j==5 % CONVth
            h=area(gamsOut(scenario).prd(:,g.TSconvELgrid,j-1).*s.heatByprod(:,g.TSconvELgrid));
        else % all other markets
            h=area(gamsOut(scenario).prd(:,g.TS2{j},j).*s.heatByprod(:,g.TS2{j}));
        end
        hold on
        if j==5
            for i = 1:length(g.TSconvELgrid)
                set(h(i),'FaceColor',col(g.TSconvELgrid(i),:))
            end
        elseif j==4
            for i = 1:length(g.TSconvEL)
                set(h(i),'FaceColor',col(g.TSconvEL(i),:))
            end
        else
            for i = 1:length(g.TS2{j})
                set(h(i),'FaceColor',col(g.TS2{j}(i),:))
            end
        end
        set(h,'LineStyle','none');
        xlim([1 s.runTime])
        set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'},'XTick',[1,6,11,16,21,26,31])
        plot(gamsOut(scenario).DemandAdapt(j,:),'color','black','LineStyle',':') % plot Demand
        title(s.sectorNamesLegend{j});
        
        if j==4
            hLegend1=legend(h(end:-1:1),s.techNamesLegend{g.TSconvEL(end:-1:1)},'Location','best');
        elseif j==5
            hLegend1=legend(h(end:-1:1),s.techNamesLegend{g.TSconvELgrid(end:-1:1)},'Location','best');
        else
            hLegend1=legend(h(end:-1:1),s.techNamesLegend{g.TS2{j}(end:-1:1)},'Location','best');
        end
        
        set(hLegend1,'Interpreter','none')% verhindert, dass ein Unterstrich tief gestellt wird
        set(hLegend1.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[1;1;1;.5]));
        hLegend1.FontSize=10;
    end
    %     h2=suplabel('Fuel deployment (PJ)','y');
    %     set(h2,'FontSize',20)
    %     end
    picName=['../fig/productionSecS'  int2str(scenario)];
    set(gcf,'Position',[0 0 1000 600])
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 1000 600],'PaperPositionMode','auto');
    print(gcf,'-painters','-depsc','-loose',picName)
    saveas(gcf,picName,'tif') % possibly 'pdf' or 'epsc'
end
%% Fuel deployment across main scenarios
figure(126789546)
for scenario=1:noScenarios
    col =   setCol;
    paretoIter=1;    
    subplot(1,noScenarios+1,scenario)
    h1=area(paretoVar(scenario,paretoIter).prd2(:,g.TSall));
    hold on
    for i = 1:length(g.TSall)
        set(h1(i),'FaceColor',col(g.TSall(i),:))
    end
    grid on
%     Dsum                            =   sum(paretoVar(scenario,paretoIter).DemandAdapt([6 8 9 7],:),1)';    % Sum of demand
%     plot(Dsum,'color','black','LineStyle',':')
    set(h1,'LineStyle','none');
    xlim([1 s.runTime])
    ylim([0 1600])
%     biomass={'412 PJ Wood','207 PJ Wood','715 PJ Wood'};
    
%         title([biomass(scenario) '=>' num2str(gamsOut(scenario).ghgTarget*10^-6) ' GtCO_2eq']);
        title([num2str(gamsOut(scenario).ghgTarget*10^-6) ' GtCO_2eq']);
        set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'},'XTick',[1,6,11,16,21,26,31])
    if scenario==1
%         set(gca,'YTickLabel',{'100','200','300','400','500','600','700'},'YTick',[100,200,300,400,500,600,700])
        ylabel('Petajoule')%['S' num2str(scenario)])
    else
%         set(gca,'YTickLabel',{'','','','','','',''},'YTick',[100,200,300,400,500,600,700])
    end
end


            hLegend=legend(h1(end:-1:1),s.techNamesLegend(g.TSall(end:-1:1)));
            set(hLegend,'Position',[0.82 0.385 0.1 0.25],'Interpreter','none','FontSize',9);
            
            set(hLegend.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[1;1;1;.5]));

% %     h2=suplabel('Cost-optimal fuel deployment (PJ) @ 99% of max. GHG abatement (PJ)','y');
if scenario==noScenarios
    picName=['../fig/productionAllScenarios'];
    set(gcf,'Position',[0 0 1000 500])
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 1000 500],'PaperPositionMode','auto');
    print(gcf,'-painters','-depsc','-loose',picName)
    saveas(gcf,picName,'png') % possibly 'pdf' or 'epsc'
end


%% Fuel deployment across sectors and scenarios
figure(123456789)
for scenario=1:noScenarios
    paretoIter=1;
    %Total fuel production first
    k=1+6*(scenario-1);
%     FuelTot=cat(2,paretoVar(scenario,paretoIter).prd(:,g.TStrans,1).*s.heatByprod(:,g.TStrans)...
%         +paretoVar(scenario,paretoIter).prd(:,g.TStrans,2).*s.heatByprod(:,g.TStrans)...
%         +paretoVar(scenario,paretoIter).prd(:,g.TStrans,3).*s.heatByprod(:,g.TStrans)...
%         +paretoVar(scenario,paretoIter).prd(:,g.TStrans,4).*s.heatByprod(:,g.TStrans)...
%         +paretoVar(scenario,paretoIter).prd(:,g.TStrans,5).*s.heatByprod(:,g.TStrans)...
%         +paretoVar(scenario,paretoIter).prd(:,g.TStrans,6).*s.heatByprod(:,g.TStrans)...
%         +paretoVar(scenario,paretoIter).prd(:,g.TStrans,7).*s.heatByprod(:,g.TStrans)...
%         +paretoVar(scenario,paretoIter).prd(:,g.TStrans,8).*s.heatByprod(:,g.TStrans)...
%         +paretoVar(scenario,paretoIter).prd(:,g.TStrans,9).*s.heatByprod(:,g.TStrans));
    
    subplot(noScenarios,6,k)
    h1=area(paretoVar(scenario,paretoIter).prd2(:,g.TSall));%FuelTot);
    k=k+1;
    hold on
    for i = 1:length(g.TSall)
        set(h1(i),'FaceColor',col(g.TSall(i),:))
    end
    grid on
%     Dsum                            =   sum(paretoVar(scenario,paretoIter).DemandAdapt([6 8 9 7],:),1)';    % Sum of demand
%     plot(Dsum,'color','black','LineStyle',':')
    set(h1,'LineStyle','none');
    xlim([1 s.runTime])
    ylim([0 1200])
    
    if scenario==1
        title('Total');
    end
    ylabel(['S' num2str(scenario)])
    if scenario==noScenarios
        set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'},'XTick',[1,6,11,16,21,26,31])
    else
        set(gca,'XTickLabel',{'','','','','','',''},'XTick',[1,6,11,16,21,26,31])
    end
    
    for j=[6 8 9 7]
        subplot(noScenarios,6,k)
        k=k+1;
        h=area(gamsOut(scenario).prd(:,g.TStrans,j).*s.heatByprod(:,g.TStrans));
        hold on
        for i = 1:length(g.TStrans)
            set(h(i),'FaceColor',col(g.TStrans(i),:))
        end
        set(h,'LineStyle','none');
        xlim([1 s.runTime])
        plot(gamsOut(scenario).DemandAdapt(j,:),'color','black','LineStyle',':') % plot Demand
        grid on
        if scenario==1
            title(s.sectorNamesLegend{j});
        end
        %         if j==6
        %             ylabel(['S' num2str(scenario)])
        %         end
        if scenario==noScenarios
            set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'},'XTick',[1,6,11,16,21,26,31])
        else
            set(gca,'XTickLabel',{'','','','','','',''},'XTick',[1,6,11,16,21,26,31])
        end
    end
end


FuelTotLegend2={s.techNamesLegend{g.TStrans(end:-1:1)}};
hLegend=legend(h(end:-1:1),FuelTotLegend2,'Position',[0.82 0.385 0.1 0.25],'Interpreter','none','FontSize',13);
set(hLegend.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[1;1;1;.5]));

% %     h2=suplabel('Cost-optimal fuel deployment (PJ) @ 99% of max. GHG abatement (PJ)','y');
if scenario==noScenarios
    picName=['../fig/productionAllSec'];
    set(gcf,'Position',[0 0 1000 600])
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 1000 600],'PaperPositionMode','auto');
    print(gcf,'-painters','-depsc','-loose',picName)
    saveas(gcf,picName,'tif') % possibly 'pdf' or 'epsc'
end

%% Fuel deployment across sectors and scenarios in pareto
figure(123456789)
for scenario=1:noScenarios
    paretoIter=1;
    k=1+6*(scenario-1);
    
    subplot(noScenarios,6,k)
    h1=area(paretoVar(scenario,paretoIter).prd2(:,g.TSall));%FuelTot);
    k=k+1;
    hold on
    for i = 1:length(g.TSall)
        set(h1(i),'FaceColor',col(g.TSall(i),:))
    end
    grid on
    set(h1,'LineStyle','none');
    xlim([1 s.runTime])
    ylim([0 650])
    
%     if scenario==1
format bank
        title([num2str(gamsOut(scenario).ghgTarget*10^-6) ' GtCO_2eq']);
%     end
    
    
    ylabel(['S' num2str(scenario)])
    if scenario==noScenarios
        set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'},'XTick',[1,6,11,16,21,26,31])
    else
        set(gca,'XTickLabel',{'','','','','','',''},'XTick',[1,6,11,16,21,26,31])
    end
    
    for paretoIter=2:5
        subplot(noScenarios,6,k)
        k=k+1;
        h=area(paretoVar(scenario,paretoIter).prd2(:,g.TSall));
        hold on
        ylim([0 650])

    for i = 1:length(g.TSall)
        set(h(i),'FaceColor',col(g.TSall(i),:))
    end
        %         for i = 1:length(g.TStrans)
%             set(h(i),'FaceColor',col(g.TStrans(i),:))
%         end
        tempNum=100*iterStep(paretoIter);%(1-(paretoIter/(2*noPareto))+1/(2*noPareto));
        title([num2str(tempNum) '% of max.']);%);
        
        set(h,'LineStyle','none');
        xlim([1 s.runTime])
%         plot(gamsOut(scenario).DemandAdapt(j,:),'color','black','LineStyle',':') % plot Demand
        grid on
        if scenario==noScenarios
            set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'},'XTick',[1,6,11,16,21,26,31])
        else
            set(gca,'XTickLabel',{'','','','','','',''},'XTick',[1,6,11,16,21,26,31])
        end
    end
end

            hLegend=legend(h1(end:-1:1),s.techNamesLegend(g.TSall(end:-1:1)));
            set(hLegend,'Position',[0.82 0.385 0.1 0.25],'Interpreter','none','FontSize',9);
            
            set(hLegend.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[1;1;1;.5]));

% %     h2=suplabel('Cost-optimal fuel deployment (PJ) @ 99% of max. GHG abatement (PJ)','y');
if scenario==noScenarios
    picName=['../fig/productionAllSecPar'];
    set(gcf,'Position',[0 0 1000 600])
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 1000 600],'PaperPositionMode','auto');
    print(gcf,'-painters','-depsc','-loose',picName)
    saveas(gcf,picName,'png') % possibly 'pdf' or 'epsc'
end



%% Renewable fuel deployment at various GHG budget constraints (PJ)
for scenario=1
    for paretoIter=1:size(paretoVar,2)
        figure (992347+scenario);
        %                                  if paretoIter>=6
        %                                  subplot(1,6,paretoIter+1)
        %                                  else
        Dsum                            =   sum(paretoVar(scenario,paretoIter).DemandAdapt(1:9,:),1)';    % Sum of demand
        subplot(1,6,paretoIter)
        %                                  end
        %         FuelTot=cat(2,paretoVar(scenario,paretoIter).prd(:,g.TSindTH,1).*s.heatByprod(:,g.TSindTH)...
        %             +paretoVar(scenario,paretoIter).prd(:,g.TSghdTH,2).*s.heatByprod(:,g.TSghdTH)...
        %             +paretoVar(scenario,paretoIter).prd(:,g.TShhTH,3).*s.heatByprod(:,g.TShhTH)...
        %             +paretoVar(scenario,paretoIter).prd(:,g.TSconvEL,4).*s.powerByprod(:,g.TSconvEL)...
        %             +paretoVar(scenario,paretoIter).prd(:,g.TSconvTH,5).*s.heatByprod(:,g.TSconvTH)...
        %             +paretoVar(scenario,paretoIter).prd(:,g.TStrans,6).*s.heatByprod(:,g.TStrans)...
        %             +paretoVar(scenario,paretoIter).prd(:,g.TStrans,7).*s.heatByprod(:,g.TStrans)...
        %             +paretoVar(scenario,paretoIter).prd(:,g.TStrans,8).*s.heatByprod(:,g.TStrans)...
        %             +paretoVar(scenario,paretoIter).prd(:,g.TStrans,9).*s.heatByprod(:,g.TStrans));
        FuelTot=cat(2,paretoVar(scenario,paretoIter).prd(:,g.TSall,1).*s.heatByprod(:,g.TSall)...
            +paretoVar(scenario,paretoIter).prd(:,g.TSall,2).*s.heatByprod(:,g.TSall)...
            +paretoVar(scenario,paretoIter).prd(:,g.TSall,3).*s.heatByprod(:,g.TSall)...
            +paretoVar(scenario,paretoIter).prd(:,g.TSall,4).*s.powerByprod(:,g.TSall)...
            +paretoVar(scenario,paretoIter).prd(:,g.TSall,5).*s.heatByprod(:,g.TSall)...
            +paretoVar(scenario,paretoIter).prd(:,g.TSall,6).*s.heatByprod(:,g.TSall)...
            +paretoVar(scenario,paretoIter).prd(:,g.TSall,7).*s.heatByprod(:,g.TSall)...
            +paretoVar(scenario,paretoIter).prd(:,g.TSall,8).*s.heatByprod(:,g.TSall)...
            +paretoVar(scenario,paretoIter).prd(:,g.TSall,9).*s.heatByprod(:,g.TSall));
        h1=area(FuelTot);
        hold on
        for i = 1:length(g.TStrans)
            set(h1(i),'FaceColor',col(g.TSall(i),:))
        end
        plot(Dsum,'color','black','LineStyle',':')
        
        set(h1,'LineStyle','none');
        xlim([1 s.runTime])
        ylim([0 3000])
        set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'},'XTick',[1,6,11,16,21,26,31])
        %             plot(Demand(j,:)','color','black','LineStyle',':') % plot Demand
        tempNum=100*iterStep(paretoIter);%(1-(paretoIter/(2*noPareto))+1/(2*noPareto));
        title([num2str(tempNum) '% of max.']);%);
        %
        if paretoIter==1
            FuelTotLegend2={s.techNamesLegend{g.TSall(end:-1:1)}};
            hLegend=legend(h1(end:-1:1),FuelTotLegend2,'Location','best');
            set(hLegend,'Position',[0.82 0.385 0.1 0.25],'Interpreter','none','FontSize',12);
            
            set(hLegend.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[1;1;1;.5]));
            %                                      hLegend.FontSize=10;
        end
        %
        if paretoIter==1
            ylabel('Petajoule (PJ)')
        elseif paretoIter==3
            xlabel('Year')
        end
        hold off
        %             end
        if paretoIter==size(paretoVar,2)
            %             h2=suplabel('Fuel deployment','y');
            %                                      title('Renewable fuel deployment at various GHG budget constraints')
            %             set(h2,'FontSize',15)
            picName=['../fig/productionFuelPareto' int2str(scenario)];
            set(gcf,'Position',[0 0 1500 300])
            set(gcf,'PaperUnits','points','PaperPosition',[0 0 1500 400],'PaperPositionMode','auto');
            print(gcf,'-painters','-depsc','-loose',picName)
            saveas(gcf,picName,'tif') % possibly 'pdf' or 'epsc'
        end
    end
end

%% Renewable fuel deployment at 95% from max in all scenarios (PJ)
for scenario=1:noScenarios
    paretoIter=1;
    figure (1234)
    if scenario<4
        subplot(2,4,scenario)
    else
        subplot(2,4,scenario+1)
    end
    FuelTot=cat(2,paretoVar(scenario,paretoIter).prd(:,g.TStrans,6)...
        +paretoVar(scenario,paretoIter).prd(:,g.TStrans,7)...
        +paretoVar(scenario,paretoIter).prd(:,g.TStrans,8)...
        +paretoVar(scenario,paretoIter).prd(:,g.TStrans,9));
    h1=area(FuelTot);
    hold on
    for i = 1:length(g.TStrans)
        set(h1(i),'FaceColor',col(g.TStrans(i),:))
    end
    grid on
    %         Dsum                            =   sum(g.Demand([6 8 9 7],:),1)';    % Sum of demand
    Dsum                            =   sum(paretoVar(scenario,paretoIter).DemandAdapt([6 8 9 7],:),1)';    % Sum of demand
    %               plot(squeeze(g.DemandAdapt(scenario,j,:)),'color','black','LineStyle',':') % plot Demand
    plot(Dsum,'color','black','LineStyle',':')
    set(h1,'LineStyle','none');
    xlim([1 s.runTime])
    ylim([0 1200])
    set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'},'XTick',[1,6,11,16,21,26,31])
    tempNum=100*iterStep(paretoIter);
    
    title([titleVector{scenario}]);
    %
    if scenario==1
        FuelTotLegend2={s.techNamesLegend{g.TStrans(end:-1:1)}};
        hLegend=legend(h1(end:-1:1),FuelTotLegend2,'Location','best');
        set(hLegend,'Position',[0.82 0.385 0.1 0.25],'Interpreter','none','FontSize',15);
        
        set(hLegend.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[1;1;1;.5]));
        %                                      hLegend.FontSize=10;
    end
    %
    %         if scenarparetoIter==1
    %     ylabel('Petajoule (PJ)')
    %         elseif paretoIter==3
    %     xlabel('Year')
    %         end
    hold off
    %             end
    if scenario==noScenarios
        %         h2=suplabel('Cost-optimal fuel deployment (PJ) @ 99% of max. GHG abatement','y');
        %                                      title('Renewable fuel deployment at various GHG budget constraints')
        %             set(h2,'FontSize',20)
        picName=['../fig/prodFuel95procAllScen'];
        set(gcf,'Position',[0 0 1000 600])
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 1000 600],'PaperPositionMode','auto');
        print(gcf,'-painters','-depsc','-loose',picName)
        saveas(gcf,picName,'tif') % possibly 'pdf' or 'epsc'
    end
end

%% Surplus power usage
for scenario=1:noScenarios
    paretoIter=2;%:1:size(paretoVar,2)
    figure (99234547);
    %         yyaxis left
    if scenario==1
        h2=stairs(o(scenario).surplusPowerVar(:,max(s.runTime)),'DisplayName','Surplus power limit');
        %             title('Surplus power usage 2050');
    end
    grid on
    %         tempNum=100*iterStep(paretoIter);
    hold on
    h(paretoIter)=stairs(paretoVar(scenario,paretoIter).powerResUse(:,max(s.runTime))./3.6,'DisplayName',['S' num2str(scenario)]);
    %                                  set(h1,'FaceColor',[212,255,0]/255)
    %                                     set(h(paretoIter),'LineStyle','none');
    hold on
    xlim([1 max(g.timeStepsIntraYear)])
    legend('Location','NorthEast')
    if paretoIter==1
        ylabel('ERE usage 2050 (TW j^{-1})')
        xlabel('Intra-year slices (j)')
    end
    if scenario==noScenarios
        picName=['../fig/residualPowerUse'];
        set(gcf,'Position',[0 0 400 250])
        set(gcf,'PaperUnits','points','PaperPosition',[0 0 400 200],'PaperPositionMode','auto');
        print(gcf,'-painters','-depsc','-loose',picName)
        saveas(gcf,picName,'tif')
    end
end

% %% Dispatchable power production
% for scenario=1
%     for paretoIter=1:size(paretoVar,2)
% %         figure (992577);
% %         yyaxis left
%         if paretoIter==1
%             h2=stairs(-o(scenario).posResLoad(:,max(s.runTime)).*3.6,'DisplayName','Residual load');
% %             title('Power dispatch 2050');
%         end
%         tempNum=100*iterStep(paretoIter);
%         hold on
%         h(paretoIter)=stairs(-sum(paretoVar(scenario,paretoIter).dispatchPrd2(max(s.runTime),:,:),3),'DisplayName',[num2str(tempNum) '% of max.']);
%         %                                  set(h1,'FaceColor',[212,255,0]/255)
%         %                                     set(h(paretoIter),'LineStyle','none');
%         hold on
%         xlim([1 max(g.timeStepsIntraYear)])
%         legend('Location','NorthEast')
%         if paretoIter==1
%             ylabel('Petajoule (PJ {\delta}t^{-1})')
%             xlabel('Intra-year steps ({\delta}t)')
%         end
%         if paretoIter==size(paretoVar,2)
%             picName=['../fig/dispatchPrd'];
%             set(gcf,'Position',[0 0 400 500])
%             set(gcf,'PaperUnits','points','PaperPosition',[0 0 400 200],'PaperPositionMode','auto');
%             print(gcf,'-painters','-depsc','-loose',picName)
%             saveas(gcf,picName,'tif')
%         end
%     end
% end

%% CO2 usage
for scenario=1:noScenarios
    figure(57682)
    for paretoIter=1%1:size(paretoVar,2)
        %         if paretoIter==1 && scenario==1
        %             h2=plot(o(scenario).co2source,'DisplayName','CO_{2} limit');
        %         elseif paretoIter==1 && scenario==4
        %             h2=plot(o(scenario).co2source,'DisplayName','CO_{2} limit');
        %         end
        hold on
        %         tempNum=100*iterStep(paretoIter);
        
        h(paretoIter)=plot(paretoVar(scenario,paretoIter).CO2Use,'DisplayName',[titleVector2{scenario}]);%['S' num2str(scenario)]);
        
        xlim([1 s.runTime])
        ylim([-1 25])
        set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'},'XTick',[1,6,11,16,21,26,31])
        %         title('CO_{2} usage');
        legend('Location','NorthWest')
        grid on
        if scenario==1
            ylabel('Fuel CO_{2} usage (Mt)')
            %         elseif paretoIter==3
            xlabel('Year')
        end
        if scenario==noScenarios
            picName=['../fig/CO2useScenarios'];
            set(gcf,'Position',[0 0 400 250])
            set(gcf,'PaperUnits','points','PaperPosition',[0 0 400 400],'PaperPositionMode','auto');
            print(gcf,'-painters','-depsc','-loose',picName)
            saveas(gcf,picName,'tif')
        end
    end
end

%% Merit order plot
for scenario=1
    figure()
    plotNum=3;
    yearVector=[2030,2040,2050];
    for i=1:plotNum
        subplot(1,plotNum,i)
        paretoIter  =   1;
        year        =   yearVector(i);
        timePoint   =   year-2019;
        techIndex   =   g.fuelTypeDef(:,3)==0 & g.fuelTypeDef(:,4)==0 & g.techsectors(:,end)==0; %Exclude LNG, CH4 and intermediate H2
        prod        =   paretoVar(scenario,paretoIter).prd2(timePoint,techIndex);
        
        
        costBase    =   paretoVar(scenario,paretoIter).techCost(timePoint,techIndex);
        costH2in    =   s.feed2ndH2in(timePoint,techIndex).*paretoVar(scenario,paretoIter).techCost(timePoint,g.techsectors(:,end)==1);
        cost        =   (costBase + costH2in)./prod; %Divided by production to get price per GJ
        cost(isnan(cost))   =   0;
        cost(isinf(cost))   =   0;
        
        xLabel      =   ['Merit order of fuel production ' num2str(year) ' (PJ)'];
        yLabel      =   'Cost (€ GJ^{-1})';
        fileName    =   ['../fig/meritOrderPJ' num2str(year)];
        yMax        =   200;
        xMax        =   sum(prod);
        %     if i==2
        %         tit       =   ['Merit order of fuel production, Scenario ' num2str(scenario)];
        %     else
        tit   =   '';
        %     end
        
        meritOrderPlot(prod,cost,s.techNames(techIndex),col(techIndex,:),year,scenario,xLabel,yLabel,tit,yMax,xMax,fileName)
    end
end
%% Merit order GHG/cost
% j=0;
% figure()
for scenario=1:1%:6%[1]
    figure()
    yearVector=[2030,2050];
    plotNum=size(yearVector,2);
    %     yearVector=[2050];
    for i=1:plotNum
        %         j=j+1;
        %     subplot(1,6,j)
        subplot(1,plotNum,i)
        paretoIter          =   1;
        year                =   yearVector(i);%2050;
        timePoint           =   year-2019;
        techIndex           =   g.fuelTypeDef(:,3)==0 & g.fuelTypeDef(:,4)==0 & g.techsectors(:,end)==0;% & g.fuelTypeDef(:,7)==0; %Exclude LNG, CH4 and intermediate H2 AND EVs
        prod                =   paretoVar(scenario,paretoIter).ghgAbateTech(timePoint,techIndex);
        prod(prod<0)        =   s.referenceGHGemission.*paretoVar(scenario,paretoIter).prd2(timePoint,prod<0) - prod(prod<0); %Abatement of intermediate CH4 is without GHG reference and thus negative, this has to be corrected here
        prod                =   prod*10^-3;
        prodTemp(scenario,i,:)   =   prod;
        if yearVector(i)==2050
            prodtemp2(scenario)  =   sum(prod);
        end
        
        %     prod(g.fuelTypeDef(:,7)==1)        =   (prod(g.fuelTypeDef(:,7)==1)-s.referenceGHGemission.*paretoVar(scenario,paretoIter).prd2(timePoint,g.fuelTypeDef(:,7)==1))./s.relativeFuelEconomy(g.fuelTypeDef(:,7)==1)+...
        %         s.referenceGHGemission.*paretoVar(scenario,paretoIter).prd2(timePoint,g.fuelTypeDef(:,7)==1);
        
        %     H2prodIndex         =   contains(s.techNames(techIndex),'FCEV');
        costBase            =   paretoVar(scenario,paretoIter).techCost(timePoint,techIndex);
        costH2in            =   s.feed2ndH2in(timePoint,techIndex).*paretoVar(scenario,paretoIter).techCost(timePoint,g.techsectors(:,end)==1);
        %     H2InputIndex        =   s.feed2ndH2in(timePoint,techIndex)>0 & s.feed2ndH2in(timePoint,techIndex)~=1;
        
        %     H2inputTot          =   sum(s.feed2ndH2in(timePoint,H2InputIndex).*paretoVar(scenario,paretoIter).prd2(timePoint,H2InputIndex));
        %     H2shareDirect       =   1 - H2inputTot/paretoVar(scenario,paretoIter).prd2(timePoint,H2prodIndex);
        cost                =   (costBase + costH2in)./prod; %Divided by production to get price per GJ
        %     cost(H2prodIndex)   =   H2shareDirect*costBase(H2prodIndex)./prod(H2prodIndex)
        cost(isnan(cost))   =   0;
        cost(isinf(cost))   =   0;
        %     cost(cost<0)   =   0;
        xLabel      =   ['GHG abatement ' num2str(year) ' (MtCO_2eq)'];
        if i==1%year==yearVector(1)
            yLabel      =   ['Merit order of fuels (€ tCO_2eq^{-1})'];
        else
            yLabel      =   [''];
        end
        fileName    =   ['../fig/meritOrderGHG_S' num2str(scenario) '_' num2str(year)];
        yMax        =   2000;
        xMax        =   sum(prod);
        %     if i==2
        %         tit       =   ['Merit order of fuel production, Scenario ' num2str(scenario)];
        %     else
        tit   =   '';
        %     end
        
        meritOrderPlot(prod,cost,s.techNames(techIndex),col(techIndex,:),year,scenario,xLabel,yLabel,tit,yMax,xMax,fileName)
        
    end
    
    set(gcf,'Position',[0 0 800 350])
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 800 350],'PaperPositionMode','auto');
    print(gcf,'-painters','-depsc','-loose',fileName)
    %     saveas(gcf,fileName)
    saveas(gcf,fileName,'png')
end
%% Calculation of different fuel type (biofuel, electrofuel, electrobiofuel) GHG abatement
for j=1:6
    biofuelGHG(j)=sum(prodTemp(j,2,:))-sum(prodTemp(j,2,10:14));
    %     prodTemp(j,2,1:14)
    %     evGHG(j)=prodTemp(j,2,end)
    electrofuelGHG(j)=sum(prodTemp(j,2,12:14));
    electrobiofuelGHG(j)=sum(prodTemp(j,2,10:12));
    totalGHG(j)=sum(prodTemp(j,2,:));
end
biofuelGHG
electrofuelGHG
electrobiofuelGHG
totalGHG
%%
if scenario==6
    prodTemp3      =   [prodtemp2(4) prodtemp2(1)-prodtemp2(4);
        prodtemp2(5) prodtemp2(2)-prodtemp2(5);
        prodtemp2(6) prodtemp2(3)-prodtemp2(6)];
    %     prodTemp2(2,:)      =   [prodtemp(5) prodtemp(2)-prodtemp(5)];
    %     prodTemp2(3,:)      =   [prodtemp(6) prodtemp(3)-prodtemp(6)];
    
    fig=figure();
    set(fig,'defaultAxesColorOrder',col)
    barh(prodTemp3,'stacked','LineStyle','none')
    legend('CCS','No CCS')
    grid on
    %     xlim([1 100])
    %     xlabel('Scenario')
    xlabel('Renewable fuel GHG abatement 2050 (Mt CO_2eq)')
    set(gca,'YTickLabel',{titleVector{1} titleVector{2} titleVector{3}})
    set(gcf,'Position',[0 0 400 200])
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 400 200],'PaperPositionMode','auto');
    fileName='../fig/GHGabate2050';
    print(gcf,'-painters','-depsc','-loose',fileName)
    %     saveas(gcf,fileName)
    saveas(gcf,fileName,'png')
end
%% Pareto front cost vs GHG
for scenario=1:noScenarios
    for paretoIter=1:size(paretoVar,2)
        figure (9923447);
        hold on
        
        tempNum=100*iterStep(paretoIter);
        x(paretoIter)   =   paretoVar(scenario,paretoIter).cost.*10^-3;
        y(paretoIter)   =   iterStep(paretoIter)*gamsOut(scenario).ghgTarget*10^-3;
    end
    %     if paretoIter==1
    %         x1=x;
    %         y1=y;
    %     end
    h(scenario) =   plot(x,y,'-','DisplayName',['S' num2str(scenario)]);
    set(h(scenario),'Color',col(scenario,:))
    %     plot(x,y,'-','MarkerSize',20,'DisplayName',[num2str(tempNum) '%, S' num2str(scenario)])
    %             text(x,y-50,['(',num2str(round(x)),',',num2str(round(y)),')'],'VerticalAlignment','cap','HorizontalAlignment','center')
    text(x(1),y(1),['S' num2str(scenario)],'VerticalAlignment','cap','HorizontalAlignment','center')
    %             if paretoIter>=2
    %                 text(x,y-350,['',num2str(round(100*(x-x1)/x1)),'%,',num2str(round(100*(y-y1)/y1)),'%'],'VerticalAlignment','cap','HorizontalAlignment','center')
    %             end
    
    %     legend('Location','SouthEast')
    xlim([0 900])
    ylim([900 2800])
    grid on
end
if scenario==noScenarios
    xlabel('Total cost (Billion €)')
    ylabel('Total GHG abatement (Mton)')
    picName=['../fig/productionFuelParetoFront'];
    set(gcf,'Position',[0 0 700 500])
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 700 500],'PaperPositionMode','auto');
    print(gcf,'-painters','-depsc','-loose',picName)
end

%% Passenger car emissions from power mix
index1=find(contains(s.techNames,{'PtG-H2'}));
index2=find(contains(s.techNames,{'PtG-C','PtL','FCEV'}));
index3=find(contains(s.techNames,{'BEV'}));

index23=unique([index2,index3]);

etaPowerToTank              =   s.plantConvEta(:,index1).*s.plantConvEta(:,index2);
etaPowerToTank(:,end+1)     =   s.plantConvEta(:,index3);

fuelVehicleEmissions        =   1000*s.ghgEFPower/3.6.*s.MJperKMavgICEV./(s.relativeFuelEconomy(index23,6)'.*etaPowerToTank)'; %kgCO2/kWh * kWh/MJ_in * MJ_out/km /[MJ_out/MJin]^-1 = kgCO2/veh-km
% fuelVehicleEmissions        =   1000*s.ghgEFPower/3.6.*s.MJperKMavgICEV./(s.relativeFuelEconomy(index23).*etaPowerToTank)'; %kgCO2/kWh * kWh/MJ_in * MJ_out/km /[MJ_out/MJin]^-1 = kgCO2/veh-km
fossilICEVemissions                 =   s.referenceGHGemission.*s.MJperKMavgICEV; %gCO2/MJ * MJ/veh-km * (g/kg)^-1= gCO2/veh-km
EU2021target                =   95*ones(s.runTime,1);
EU2015target                =   130*ones(s.runTime,1);

figure()
plot(fuelVehicleEmissions')
hold on
plot(fossilICEVemissions)
plot(EU2015target','--')
plot(EU2021target','--')
% plot(s.ghgEFPower*1000,':')
xlim([1 s.runTime])
grid on
set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'},'XTick',[1,6,11,16,21,26,31])

%         title('Passenger car CO_{2} emissions from German power mix');%,'FontSize',14);
legend([s.techNames(index23) 'Fossil reference' 'EU 2015 target' 'EU 2021 target' 'Power mix [gCO_2eq kWh^{-1}]'],'Location','NorthEast')
ylabel('Passenger car CO_{2} emissions (gCO_2eq vehicle-km^{-1})')
xlabel('Year')


picName='../fig/fuelGHGeconomy';
%     set(gcf,'Position',[0 0 700 500])
%     set(gcf,'PaperUnits','points','PaperPosition',[0 0 700 500],'PaperPositionMode','auto');
print(gcf,'-painters','-depsc','-loose',picName)
saveas(gcf,[picName '.tif'])
%%
%% Passenger car power input per km
index1=find(contains(s.techNames,{'PtG-H2'}));
index2=find(contains(s.techNames,{'PtG-C','PtL','FCEV'}));
index3=find(contains(s.techNames,{'BEV'}));

index23=unique([index2,index3]);

etaPowerToTank              =   s.plantConvEta(:,index1).*s.plantConvEta(:,index2);
etaPowerToTank(:,end+1)     =   s.plantConvEta(:,index3);

year                        =   2020;
timePoint                   =   year-2019;

fuelVehiclePowerPerKM       =   s.MJperKMavgICEV(timePoint)./(3.6.*etaPowerToTank(timePoint,:).*s.relativeFuelEconomy(index23,6)'); %kWh per KM


figure()
h = barh(fuelVehiclePowerPerKM);
%                     for i = 1:length(index23)
%                         set(h(i),'FaceColor',col(index23(i),:))
%                     end
hold on
% xlim([0 1])
grid on
set(gca,'YTickLabel',s.techNames(index23));%,'XTick',[1,6,11,16,21,26,31])

%         title('Passenger car power demand');%,'FontSize',14);
%         legend(s.techNames(index23),'Location','NorthEast')
xlabel('Passenger car power demand (kWh_{el} vehicle-km^{-1})')
%             xlabel(s.techNames(index23))


picName='../fig/fuelPowerEconomy';
%     set(gcf,'Position',[0 0 700 500])
%     set(gcf,'PaperUnits','points','PaperPosition',[0 0 700 500],'PaperPositionMode','auto');
print(gcf,'-painters','-depsc','-loose',picName)
saveas(gcf,[picName '.tif'])

%%  Calculating total renewable share

prodTot     =   zeros([noScenarios s.runTime]);
demTot     =   zeros([noScenarios s.runTime]);
for scenario=1:noScenarios
    for j=[6 8 9 7]
        prod                    =   sum(gamsOut(scenario).prd(:,g.TS2{j},j).*s.heatByprod(:,g.TS2{j}),2);
        %         if j==6
        %             dem                 =   gamsOut(scenario).DemandRoadPass';
        %         else
        dem                 =   gamsOut(scenario).DemandAdapt(j,:)';%g.Demand(j,:)';
        %         end
        shareRenSector(scenario,j,:)    =   prod./dem;
        prodTot(scenario,:)             =   prodTot(scenario,:) + prod';
        demTot(scenario,:)              =   demTot(scenario,:) + dem';
    end
    shareRenTot         =   prodTot./demTot;
end

shareRenTot(:,end)

figure()
plot(shareRenTot')

xlim([1 s.runTime])
ylim([0 1])
grid on
set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'},'XTick',[1,6,11,16,21,26,31])
set(gca,'YTickLabel',{'0','25','50','75','100'},'YTick',[0,0.25,0.5,0.75,1])
ylabel('Total renewable fuel share across sectors [%]')
legend('S1 Base','S2 MoreH2','S3 NoLand','S4 CCSBase','S5 CCSMoreH2','S6 CCSNoLand','S7','S8','S9','S10','Location','NorthWest')
picName='../fig/renShareTot';
%     set(gcf,'Position',[0 0 700 500])
%     set(gcf,'PaperUnits','points','PaperPosition',[0 0 700 500],'PaperPositionMode','auto');
print(gcf,'-painters','-depsc','-loose',picName)
saveas(gcf,[picName '.tif'])
% legend(['S' num2str(scenario)]
%                 save(['runData' datestr(now,'yymmddhhMM') '.mat'])
%%
toc
%% Plot surplus power vs societal CO2 emissions
figure()
yyaxis left
plot(sum(s.surplusPowerGW)/1000)
ylabel('Surplus power [TWh]')
yyaxis right
plot(s.co2source)
grid on
xlim([1 31])
ylabel('CO_2 emissions in Germany [Mton]')
set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'},'XTick',[1,6,11,16,21,26,31])
%     xlabel('GW')
title('Surplus power and CO_2 emissions')
picName='../fig/surplusCO2';
print(gcf,'-painters','-depsc','-loose',picName)
saveas(gcf,[picName '.tif'])
%% Plot PtX potential from surplus power and CO2 emissions
index1=find(contains(s.techNames,{'PtG-H2'}));
index2=find(contains(s.techNames,{'PtL'}));
% index3=find(contains(s.techNames,{'BEV'}));

% index23=unique([index2,index3]);

etaPowerToTank              =   s.plantConvEta(:,index1).*s.plantConvEta(:,index2);
s.feed2ndCO2Amount(index2); %Mt/PJ

figure()
% yyaxis left


plot(sum(s.surplusPowerGW).*3.6.*etaPowerToTank'./1000)
% ylabel('PtL production potential from surplus power [PJ]')
% yyaxis right
hold on
plot(s.co2source/s.feed2ndCO2Amount(index2))
plot(linspace(0,1,s.runTime).*sum(s.posResLoad,1).*3.6.*55/1000/s.feed2ndCO2Amount(index2)/0.5)
grid on
xlim([1 31])
ylim([0 1000])
%     ylabel('CO_2 emissions in Germany [Mton]')
ylabel('Theoretical limits for PtL production (PJ_{fuel})')
set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'},'XTick',[1,6,11,16,21,26,31])
%     xlabel('GW')
legend('PtL potential from excess energy from surplus power',['PtL potential from German power production emissions'],['PtL potential from residual load covered' newline 'fully by CH_4 in 2050 [\eta_{el}=50%], CO_2 captured'],'Location','NorthWest')
%     title(['Theoretical limits for PtL production' newline 'from surplus power and CO_2 sources'])
picName='../fig/surplusCO2PtL';
print(gcf,'-painters','-depsc','-loose',picName)
saveas(gcf,[picName '.tif'])
%%


%% Plot capacity factor in 2050 vs CAPEX at different production levels
if max(g.timeStepsIntraYear)>8000
    figure()
    numPlot=3;
    s.surplusPowerGW   =   1000.*s.surplusPowerVar;
    timePoint=31;
    index1=find(contains(s.techNames,{'PtG-H2'}));
    %     maxProd(0)  =   0;
    for i=1:max(s.surplusPowerGW(:,timePoint))
        capFac(i)           =   sum(s.surplusPowerGW(:,timePoint)>i)/max(g.timeStepsIntraYear); % no of hours of surplus power with given capacity / total hours
        vals                =   s.surplusPowerGW(:,timePoint);
        vals(vals>i)        =   i;
        maxProd(i)          =   sum(vals)/1000; %TWh @ cap i
        capex(i)            =   o.plantInvCostLevel(timePoint,index1)*(maxProd(i)*3.6*o.plantConvEta(timePoint,index1)/i)^-1; %M€/PJ = €/GJ
        capexGJ(i)          =   capex(i)/(maxProd(i)/i);
        if i==1
            marginalCapex(i)    =   o.plantInvCostLevel(timePoint,index1)*(maxProd(i)*3.6*o.plantConvEta(timePoint,index1))^-1; %M€/PJ = €/GJ
        else
            marginalCapex(i)    =   o.plantInvCostLevel(timePoint,index1)*((maxProd(i)-maxProd(i-1))*3.6*o.plantConvEta(timePoint,index1))^-1; %M€/PJ = €/GJ
        end
        
        %             marginalCapex(i)    =   o.plantInvCostLevel(timePoint,index1)*((maxProd(i))*3.6/i)^-1; %M€/PJ = €/GJ
        %         for j=1:i
        %             weightedCapFac(i)   =   sum(s.surplusPowerGW(1:i,timePoint).*capFac(1:i)')/max(s.surplusPowerGW(:,timePoint));%maxProd(i);
    end
    
    subplot(1,numPlot,1)
    plot(capFac);
    xlim([0 167])
    grid on
    ylabel('Capacity factor (C_f)')
    xlabel('Excess electricity (GW)')
    title('a')
    
    subplot(1,numPlot,2)
    %     for capacity=1:max(s.surplusPowerGW(:,timePoint))
    %     end
    plot(maxProd)
    grid on
    ylabel('Potential ERE usage (TWh)')
    xlabel('Capacity (GW)')
    title('b')
    xlim([0 167])
    
    subplot(1,numPlot,3)
    plot(maxProd,capex)
    grid on
    ylabel('H_2 CAPEX (€ GJ^{-1})')
    xlabel('ERE usage (TWh)')
    title('c')
    xlim([0 250])
    ylim([0 16])
    %
    %     subplot(1,4,4)
    %     plot(marginalCapex)
    %     grid on
    %     ylim([0 100])
    %     ylabel('Marginal H_2 CAPEX (€ GJ^{-1})')
    %     xlabel('Capacity (GW)')
    %     title('d')
    %     xlim([0 167])
    
    set(gcf,'Position',[0 0 700 200])
    set(gcf,'PaperUnits','points','PaperPosition',[0 0 700 200],'PaperPositionMode','auto');
    picName=['../fig/capFac' num2str(2019+timePoint)];
    print(gcf,'-painters','-depsc','-loose',picName)
    saveas(gcf,[picName '.tif'])
end

%% Hydrogen Cost break down
costH2=0;
indexH2=find(contains(s.techNames,{'PtG-H2'}));
indexFCEV=find(contains(s.techNames,{'FCEV'}));
indexPtCH4=find(contains(s.techNames,{'PtG-CH4'}));
indexPtL=find(contains(s.techNames,{'PtL'}));
fig=figure();
set(fig,'defaultAxesColorOrder',col)
% capex H2, capex 2nd conversion, CO2, electricity price of 10ct/kWh

for index = [indexFCEV,indexPtCH4,indexPtL]
    GJpKM       =   s.MJperKMavgICEV.*10^-3./s.relativeFuelEconomy(index,6); %GJ per vehicle-km
    costH2(end+1:end+2,1:6)     =   [[min(capex)/max(s.plantConvEta(:,index)) min(o(1).fuelInvCostLevel(:,index)) min(s.co2price)*s.feed2ndCO2Amount(index)  s.powerInput(indexH2)*0 min(s.transportCost(index,:)) min(s.storageCost(index,:))]*min(GJpKM);% min(o.vehicleCostPerKm(:,index));
        [max(capex)/min(s.plantConvEta(:,index)) max(o(1).fuelInvCostLevel(:,index)) max(s.co2price)*s.feed2ndCO2Amount(index) (40/3.6)/(min(s.plantConvEta(indexH2)*s.plantConvEta(:,index))) max(s.transportCost(index,:)) max(s.storageCost(index,:))]*max(GJpKM)];% max(o.vehicleCostPerKm(:,index))]; %€/vehicle-km
    %                 min(GJpKM)
    %                 max(GJpKM)
end


barh(costH2(2:end,:),'stacked','LineStyle','none')

%         for i = 1:7
%             set(h(i),'FaceColor',col(i,:))
%         end

grid on
%         grid minor
legend('CAPEX H_2','CAPEX 2nd','CO_2','Electricity','Transport','Storage/fuelling','Location','EastOutside')
%         xlabel('FCEV,low','FCEV,high','PtG-CH4,low','PtG-CH4,low','PtL,low','PtL,low')
set(gca,'YTickLabel',{'FCEV,low','FCEV,high','PtG-CH4,low','PtG-CH4,high','PtL,low','PtL,high'})
xlim([0 0.105])
xlabel('Electrofuel cost breakdown (€ vehicle-km^{-1})')
set(gcf,'Position',[0 0 500 200])
set(gcf,'PaperUnits','points','PaperPosition',[0 0 500 200],'PaperPositionMode','auto');
picName=['../fig/prodCostH2'];
print(gcf,'-painters','-depsc','-loose',picName)
saveas(gcf,[picName '.tif'])
%%

%% Plot renewables share with storage setting and with perfect storage
onShoreDev                       =   s.onShore./s.onShore(1);
offShoreDev                      =   s.offShore./s.offShore(1);
photoVDev                        =   s.photoV./s.photoV(1);
demandPowerDev                   =   s.demandPower./s.demandPower(1);
figure()
subplot(2,1,1)
plot(s.RENshare)
hold on
plot(s.RENshare100)
grid on
legend('Limited storage','Perfect storage','Location','NorthWest')
%     title('Renewables share with limited and perfect storage')
ylabel('Renewables share')
set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'})

subplot(2,1,2)
plot(onShoreDev)
hold on
grid on
plot(offShoreDev)
plot(photoVDev)
plot(demandPowerDev)
%     plot(s.onShore)
%     hold on
%     grid on
%     plot(s.offShore)
%     plot(s.photoV)
%     plot(s.demandPower)
%     ylim([0 1.2])
title('Capacity expansion of variable renewable options (normed)')
ylabel('Factor increase')
legend('Onshore Wind','Offshore Wind','PV','Power demand','Location','NorthWest')
set(gca,'XTickLabel',{'2020','','2030','','2040','','2050'})
%     set(gcf,'Position',[0 0 400 200])
%     set(gcf,'PaperUnits','points','PaperPosition',[0 0 400 200],'PaperPositionMode','auto');
picName='../fig/renShareDevPower';
print(gcf,'-painters','-depsc','-loose',picName)
saveas(gcf,[picName '.tif'])
%%
%% Residual load curves
figure()
plot(1000*s.resLoadDataHour(:,[1 3 5 7]))
xlim([0 8760])
grid on
surplusTotYear      =   round(sum(s.surplusPowerVar(:,[2020 2030 2040 2050]-2019,1)));
residualTotYear     =   round(sum(s.posResLoad(:,[2020 2030 2040 2050]-2019,1)));
% title('Residual load curves for selected years')
xlabel('Hour')
ylabel('Residual load curves (GW)')
legend(['2020, ERE = ' num2str(surplusTotYear(1)) ' TWh, residual = '  num2str(residualTotYear(1)) ' TWh'],...
    ['2030, ERE = ' num2str(surplusTotYear(2)) ' TWh, residual = '  num2str(residualTotYear(2)) ' TWh'],...
    ['2040, ERE = ' num2str(surplusTotYear(3)) ' TWh, residual = '  num2str(residualTotYear(3)) ' TWh'],...
    ['2050, ERE = ' num2str(surplusTotYear(4)) ' TWh, residual = '  num2str(residualTotYear(4)) ' TWh'],'Location','SouthEast')
picName='../fig/resLoadCurve';
print(gcf,'-painters','-depsc','-loose',picName)
saveas(gcf,[picName '.tif'])
%%

figure()
%     subplot(1,2,1)
p1 = bar([s.demLand(1),gamsOut(1).DemandRoadPass(end);s.demShip(1),s.demShip(end);s.demGoodsLand(1),s.demGoodsLand(end);s.demAviation(1),s.demAviation(end)]);

title('Fuel demand in transport sectors including international')
%     subplot(1,2,2)
% p1 = bar([s.demAviation(end),s.demGoodsLand(end),s.demShip(end),gamsOut(1).DemandRoadPass(end)]);
set(gca,'XTickLabel',{'Passenger car','Marine','Freight land','Aviation'});
ylabel('Fuel demand (PJ)')
legend('2020','2050')
picName='../fig/fuelDemSectors';
print(gcf,'-painters','-depsc','-loose',picName)
saveas(gcf,[picName '.tif'])
%%
fig=figure();
set(fig,'defaultAxesColorOrder',col)
for scenario=1:6
    if scenario<4
        subplot(2,4,scenario)
    else
        subplot(2,4,scenario+1)
    end
    area(gamsOut(scenario).feedUse3,'LineStyle','none')
end
legend([f.feedNames f.residueNames f.powerNames],'Position',[0.82 0.385 0.1 0.25],'Interpreter','none','FontSize',13)
%%
end