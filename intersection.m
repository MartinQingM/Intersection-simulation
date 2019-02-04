clear
close all
clc
import traci.constants
system(['sumo-gui -c ' './intersection.sumocfg &']);%将m文件放至sumocfg文件同文件夹下

unitchange = @(x) x*3600/1000; %变单位从m/s到km/h
clock = 0;  %计时器
a=0;
traci.init();%初始化接口
Tidb = [];
s = [];
f = [];%接收累加的油耗参数
d = [];%接收距离参数
while traci.simulation.getMinExpectedNumber()>0 %无车辆时结束
    traci.simulationStep();
    
    ID = traci.vehicle.getIDList();
    if ismember('veh0',ID)； %车辆列表中有veh0时开始
%    if ~isempty(strfind(ID, 'veh0')); 
        
%         idb_arrived = traci.vehicle.getDistance('veh0');
%         if idb_arrived >= 400
%             a=1;
%             Tidb = clock;
%         end
        fuel = [f,traci.vehicle.getFuelConsumption('veh0')];%把每step油耗加入数组
        f = fuel;
        Distance = [d,traci.vehicle.getDistance('veh0')];%把每step距离加入数组
        d = Distance;
        current_speed_veh0 = traci.vehicle.getSpeed('veh0');
        
        current_speed_veh0 = unitchange(current_speed_veh0);
        Speed = [ s,current_speed_veh0];%把每step速度加入数组
        s = Speed;
    else
    end
    clock = clock +1;
end

traci.close()%关闭接口

figure(1);
plot(Speed,'r','LineWidth',1);ylim([0 60]);grid on;
xlabel('时间');
ylabel('速度km/h');
legend('速度');

figure(2);
plot(Distance,fuel,'r','LineWidth',1);xlim([0 700]);ylim([0 7]);grid on;
xlabel('距离');
ylabel('瞬时油耗/ml');
legend('油耗');

figure(3);
plot(Distance,Speed,'r','LineWidth',1);ylim([0 60]);grid on;
xlabel('距离');
ylabel('速度km/h');
legend('速度');

% Time = 2:clock;
% figure(4);
% plot(Time,Distance,'r','LineWidth',1);ylim([0 100]);grid on;
% xlabel('距离');
% ylabel('速度km/h');
% legend('速度');

Sumfuel = sum(fuel)
