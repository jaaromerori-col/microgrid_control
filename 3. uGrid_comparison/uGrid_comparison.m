ntest=5;    %Number of simulations
test_conditions=zeros(4,7,ntest);
Comparison=zeros(3,3,ntest);

tim_vec=0:1:6;
Ir_max=500+1; %Set up maximum irradiance/2. It means 500 would be to setup 1kW/m2
R_max=20;   %Configure the maximum load resistance
disp("Advance:0%")
for k=1:ntest
    Ir_V=[randi(Ir_max) randi(Ir_max) randi(Ir_max) randi(Ir_max) randi(Ir_max) randi(Ir_max) randi(Ir_max)]-1;
    I_pv_sp_V=0.0662*Ir_V+0.0549;
    RL_var_vec=[randi(R_max) randi(R_max) randi(R_max) randi(R_max) randi(R_max) randi(R_max) randi(R_max)];
    Ppv=I_pv_sp_V*32;
    Pr=(48^2)./RL_var_vec;
    Charge=Ppv>Pr;
    test_conditions(1,:,k)=Ir_V;
    test_conditions(2,:,k)=I_pv_sp_V;
    test_conditions(3,:,k)=RL_var_vec;
    test_conditions(4,:,k)=Charge;
    S1=sim('Variable_PID_KNN_gain_selector_comp.slx');
    error_Ipv=squeeze(S1.e_Ipv.Data);
    error_Vrl=squeeze(S1.e_Vbus.Data);
    Comparison(1,1,k)=sum(error_Ipv.^2);
    Comparison(2,1,k)=sum(error_Vrl.^2);
    Comparison(3,1,k)=mean(Charge);
    S2=sim('Variable_PID_Interpolated_gains_comp.slx');
    error_Ipv=squeeze(S2.e_Ipvv.Data);
    error_Vrl=squeeze(S2.e_Vbusv.Data);
    Comparison(1,2,k)=sum(error_Ipv.^2);
    Comparison(2,2,k)=sum(error_Vrl.^2);
    Comparison(3,2,k)=mean(Charge);
    S3=sim('Variable_PID_ANN_gain_selector_comp.slx');
    error_Ipv=squeeze(S3.e_Ipva.Data);
    error_Vrl=squeeze(S3.e_Vbusa.Data);
    Comparison(1,3,k)=sum(error_Ipv.^2);
    Comparison(2,3,k)=sum(error_Vrl.^2);
    Comparison(3,3,k)=mean(Charge);
    disp("Advance:"+k*100/ntest+"%")
end
disp('Done')
%%
Ji_knn=zeros(1,ntest);
Jv_knn=zeros(1,ntest);
ch_knn=zeros(1,ntest);   
Ji_inter=zeros(1,ntest);
Jv_inter=zeros(1,ntest);
ch_inter=zeros(1,ntest);   
Ji_ann=zeros(1,ntest);
Jv_ann=zeros(1,ntest);
ch_ann=zeros(1,ntest);

for k=1:ntest
    Ji_knn(k)=Comparison(1,1,k);
    Jv_knn(k)=Comparison(2,1,k);
    ch_knn(k)=Comparison(3,1,k);
    
    Ji_inter(k)=Comparison(1,2,k);
    Jv_inter(k)=Comparison(2,2,k);
    ch_inter(k)=Comparison(3,2,k);
    
    Ji_ann(k)=Comparison(1,3,k);
    Jv_ann(k)=Comparison(2,3,k);
    ch_ann(k)=Comparison(3,3,k);
end
%% Graph

y=[Jv_knn' Jv_inter' Jv_ann'];
b = bar(y,'FaceColor','flat');
xlabel('Simulation number');
ylabel('Cost function');
textL={'KNN','Interpolated','ANN'};
legend(textL,'Location','northwest');
for k = 1:size(y,2)
    b(k).CData = k;
end

%% box plot

figure('Units','inches','Position',[0 0 3.5 3],'PaperPositionMode','auto')
boxplot([Jv_knn',Jv_inter',Jv_ann'],'Labels',{'KNN','Interpolation','ANN'})

grid on
set(gca,'Units','normalized','Position',[.15 .2 .75 .7]...
    ,'FontUnits','points','FontWeight','normal','FontSize',9,'FontName','SansSerif')
ylabel({'Accumulated Voltage cost function [$V^2$]'},'FontUnits','points','interpreter','latex','FontSize',9,'FontName','Times')


%% s
disp("knn mean: " +mean(Jv_knn)+ " knn std: " + std(Jv_knn))
disp("int mean: " +mean(Jv_inter)+ " int std: " + std(Jv_inter))
disp("ann mean: " +mean(Jv_ann)+ " ann std: " + std(Jv_ann))
