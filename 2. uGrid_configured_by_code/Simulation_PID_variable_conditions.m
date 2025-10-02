tim_vec=0:1:6;                      % Used in Simulink as time vector.

Ir_V=[0 100 500 1000 500 100 0];    %Used to change irradiance in simulink
I_pv_sp_V=0.0662*Ir_V+0.0549;       %Used to change current set-point in simulink
RL_var_vec=[1 6 8 15 7 3 5];       %Used to change load resistance in simulink
S1=sim('PID_uGrid_changed_by_code.slx');   %Run the simulation
Data_graph=squeeze(S1.graph.Data);  %Obtain data from the simulation
V_bus=Data_graph(:,1);              %Voltage vector
I_pv=Data_graph(:,2);               %Current of the solar array
I_pv_ref=Data_graph(:,3);           %Current set point
V_sup_limit=Data_graph(:,4);        %5 % limit for the voltage
V_inf_limit=Data_graph(:,5);        %5 % limit for the voltage
time=[0:1e-6:0.08]*1000;            % timein ms
%% Code to generate a nice graph
figure('Units','inches','Position',[0 0 3.5 2.2],'PaperPositionMode','auto')
yyaxis left
plot(time,V_bus)
axis([0 time(end) 0 90])
set(gca,'Units','normalized','YTick',0:10:90,'XTick',0:10:80,'Position',[.15 .2 .75 .7]...
    ,'FontUnits','points','FontWeight','normal','FontSize',9,'FontName','SansSerif')
ylabel({'Voltage(V)'},'FontUnits','points','interpreter','latex','FontSize',9,'FontName','Times')
xlabel('Time(ms)','FontUnits','points','FontWeight','normal','FontSize',9,'FontName','Times')

yyaxis right
plot(time,I_pv)
legend({'$V_L$','$I_{pv}$'},'FontWeight','normal','interpreter','latex','FontSize',7,...
    'FontName','Times','Location','Northeast') 
axis([0 time(end) 0 70])
set(gca,'Units','normalized','YTick',0:10:70,'XTick',0:10:80,'Position',[.15 .2 .75 .7]...
    ,'FontUnits','points','FontWeight','normal','FontSize',9,'FontName','SansSerif')
ylabel({'Current(A)'},'FontUnits','points','interpreter','latex','FontSize',9,'FontName','Times')

hold
yyaxis left
p3=plot(time,V_sup_limit,'--')
p3.Annotation.LegendInformation.IconDisplayStyle = 'off';
p4=plot(time,V_inf_limit,'--')
p4.Annotation.LegendInformation.IconDisplayStyle = 'off';

yyaxis right
p5=plot(time,I_pv_ref,'--')
p5.Annotation.LegendInformation.IconDisplayStyle = 'off';
grid on