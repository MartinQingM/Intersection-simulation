clear
close all
clc
import traci.constants
%system(['sumo-gui -c ' './intersection.sumocfg &']);%将m文件放至sumocfg文件同文件夹下
system(['sumo -c ' './intersection.sumocfg &']);%命令行界面，自动运行，节约时间

unitchange = @(x) x*3600/1000; %变单位从m/s到km/h
clock = 0;  %计时器
a=0;
traci.init();%初始化接口
Tidb = [];%调试用
s = [];%接受速度的参数
f = [];%接收累加的油耗参数
co2 = [];
c = [];
d = [];%接收距离参数
Ts = [];%调试用
Ns = [];%调试用
while traci.simulation.getMinExpectedNumber()>0 %无车辆时结束
    traci.simulationStep();
    
    ID = traci.vehicle.getIDList();
    if ~isempty(strfind(ID, 'veh0')); %车辆列表中有veh0时开始
        
        Cdistance = traci.vehicle.getDistance('veh0');
%         if idb_arrived >= 400 %调试用
%             a=1;
%             Tidb = clock;
%         end
        fuel = [f,traci.vehicle.getFuelConsumption('veh0')];%把每step油耗加入数组
        f = fuel;
        co2 = [c, traci.vehicle.getCO2Emission('veh0')];
        c = co2;
        Distance = [d,traci.vehicle.getDistance('veh0')];%把每step距离加入数组
        d = Distance;
        current_speed_veh0 = traci.vehicle.getSpeed('veh0');%获得当前车速
        current_speed_veh0 = unitchange(current_speed_veh0);%换算车速为km/h
        Speed = [ s,current_speed_veh0];%把每step速度加入数组
        s = Speed;
        
        Tstate = traci.trafficlights.getPhase ('2'); %here = 2-黄灯 0-红灯 1-绿灯 3-红灯 根据自己的设置顺序
        Ts = [Ts Tstate];  %测试用
        Ctime = traci.simulation.getCurrentTime();  %返回当时时间(ms)
        Nswitch = traci.trafficlights.getNextSwitch('2');  %返回绝对下一信号灯时间，从仿真开始计算(ms)
        CNswitch = (Nswitch-Ctime)/1000;  %计算出目前下一phase时间(s)
        Ns = [Ns CNswitch];    %测试用
        
        if Cdistance == 0 %减速至30km/h
            traci.vehicle.slowDown('veh0',8.33,40000);
        end
        
%         if Cdistance == 0 %减速至40km/h
%             traci.vehicle.slowDown('veh0',11.11,12000);
%         end
        
%         if Cdistance == 0     %尝试用setspeed控制速度，效果没有减速时间控制好
% %             traci.vehicle.slowDown('veh0',8.33,38000);
% %         elseif Ctime == 38000
%             traci.vehicle.setSpeed('veh0',8.33);
% %         elseif Ctime == 
%         end
%         if Cdistance >400
%             traci.vehicle.setSpeed('veh0',13.89);
%         end
        
        leftdistance = 991.75-500-Cdistance;
        
%         if leftdistance >0  %红灯前应用辅助驾驶
%             leftdtime = leftdistance/current_speed_veh0; %计算以当前时间走过剩余距离所需的时间
%             if Tstate == 0 && Tstate ==3 %红灯
%                 if leftdtime<CNswitch
%                     traci.vehicle.slowDown('veh0',8.33,15); %ID, 速度(m/s), 时长
%                 elseif leftdtime>CNswitch+30
%                     traci.vehicle.slowDown('veh0',8.33,15);
%                 elseif CNswitch<leftdtime<CNswitch+30
%                     traci.vehicle.slowDown('veh0',8.33,7);
%                 end
%             elseif Tstate == 1  %绿灯
%                 if leftdtime>CNswitch
%                     traci.vehicle.slowDown('veh0',16,10);
%                 end
% %             elseif Tstate == 2  %黄灯
% %                 if CNswitch<leftdtime
% %                     traci.vehicle.slowDown('veh0',5,2);
% %                 end
%             end
%         end
    end
    clock = clock +1;
end

traci.close()%关闭接口

figure(1);
subplot(4,1,1),plot(Speed,'r','LineWidth',1);ylim([0 60]);grid on;
xlabel('时间(s)');
ylabel('速度(km/h)');
legend('速度');

% figure(2);
subplot(4,1,2),plot(Distance,fuel,'r','LineWidth',1);ylim([0 7]);grid on;
xlabel('距离(m)');
ylabel('瞬时油耗(ml)');
legend('油耗');

% figure(3);
subplot(4,1,3),plot(Distance,Speed,'r','LineWidth',1);ylim([0 60]);grid on;
xlabel('距离(m)');
ylabel('速度(km/h)');
legend('速度');

% figure(4);
subplot(4,1,4),plot(Distance,co2,'r','LineWidth',1);grid on;
xlabel('距离(m)');
ylabel('CO2排放(mg)');
legend('CO2排放');

% Time = 2:clock;
% figure(4);
% plot(Time,Distance,'r','LineWidth',1);ylim([0 100]);grid on;
% xlabel('距离');
% ylabel('速度km/h');
% legend('速度');
Sumco2 = round(sum(co2))
Sumfuel = sum(fuel)
