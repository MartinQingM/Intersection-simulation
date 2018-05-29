clear
close all
clc
import traci.constants
%system(['sumo-gui -c ' './intersection.sumocfg &']);%��m�ļ�����sumocfg�ļ�ͬ�ļ�����
system(['sumo -c ' './intersection.sumocfg &']);%�����н��棬�Զ����У���Լʱ��

unitchange = @(x) x*3600/1000; %�䵥λ��m/s��km/h
clock = 0;  %��ʱ��
a=0;
traci.init();%��ʼ���ӿ�
Tidb = [];%������
s = [];%�����ٶȵĲ���
f = [];%�����ۼӵ��ͺĲ���
co2 = [];
c = [];
d = [];%���վ������
Ts = [];%������
Ns = [];%������
while traci.simulation.getMinExpectedNumber()>0 %�޳���ʱ����
    traci.simulationStep();
    
    ID = traci.vehicle.getIDList();
    if ~isempty(strfind(ID, 'veh0')); %�����б�����veh0ʱ��ʼ
        
        Cdistance = traci.vehicle.getDistance('veh0');
%         if idb_arrived >= 400 %������
%             a=1;
%             Tidb = clock;
%         end
        fuel = [f,traci.vehicle.getFuelConsumption('veh0')];%��ÿstep�ͺļ�������
        f = fuel;
        co2 = [c, traci.vehicle.getCO2Emission('veh0')];
        c = co2;
        Distance = [d,traci.vehicle.getDistance('veh0')];%��ÿstep�����������
        d = Distance;
        current_speed_veh0 = traci.vehicle.getSpeed('veh0');%��õ�ǰ����
        current_speed_veh0 = unitchange(current_speed_veh0);%���㳵��Ϊkm/h
        Speed = [ s,current_speed_veh0];%��ÿstep�ٶȼ�������
        s = Speed;
        
        Tstate = traci.trafficlights.getPhase ('2'); %here = 2-�Ƶ� 0-��� 1-�̵� 3-��� �����Լ�������˳��
        Ts = [Ts Tstate];  %������
        Ctime = traci.simulation.getCurrentTime();  %���ص�ʱʱ��(ms)
        Nswitch = traci.trafficlights.getNextSwitch('2');  %���ؾ�����һ�źŵ�ʱ�䣬�ӷ��濪ʼ����(ms)
        CNswitch = (Nswitch-Ctime)/1000;  %�����Ŀǰ��һphaseʱ��(s)
        Ns = [Ns CNswitch];    %������
        
        if Cdistance == 0 %������30km/h
            traci.vehicle.slowDown('veh0',8.33,40000);
        end
        
%         if Cdistance == 0 %������40km/h
%             traci.vehicle.slowDown('veh0',11.11,12000);
%         end
        
%         if Cdistance == 0     %������setspeed�����ٶȣ�Ч��û�м���ʱ����ƺ�
% %             traci.vehicle.slowDown('veh0',8.33,38000);
% %         elseif Ctime == 38000
%             traci.vehicle.setSpeed('veh0',8.33);
% %         elseif Ctime == 
%         end
%         if Cdistance >400
%             traci.vehicle.setSpeed('veh0',13.89);
%         end
        
        leftdistance = 991.75-500-Cdistance;
        
%         if leftdistance >0  %���ǰӦ�ø�����ʻ
%             leftdtime = leftdistance/current_speed_veh0; %�����Ե�ǰʱ���߹�ʣ����������ʱ��
%             if Tstate == 0 && Tstate ==3 %���
%                 if leftdtime<CNswitch
%                     traci.vehicle.slowDown('veh0',8.33,15); %ID, �ٶ�(m/s), ʱ��
%                 elseif leftdtime>CNswitch+30
%                     traci.vehicle.slowDown('veh0',8.33,15);
%                 elseif CNswitch<leftdtime<CNswitch+30
%                     traci.vehicle.slowDown('veh0',8.33,7);
%                 end
%             elseif Tstate == 1  %�̵�
%                 if leftdtime>CNswitch
%                     traci.vehicle.slowDown('veh0',16,10);
%                 end
% %             elseif Tstate == 2  %�Ƶ�
% %                 if CNswitch<leftdtime
% %                     traci.vehicle.slowDown('veh0',5,2);
% %                 end
%             end
%         end
    end
    clock = clock +1;
end

traci.close()%�رսӿ�

figure(1);
subplot(4,1,1),plot(Speed,'r','LineWidth',1);ylim([0 60]);grid on;
xlabel('ʱ��(s)');
ylabel('�ٶ�(km/h)');
legend('�ٶ�');

% figure(2);
subplot(4,1,2),plot(Distance,fuel,'r','LineWidth',1);ylim([0 7]);grid on;
xlabel('����(m)');
ylabel('˲ʱ�ͺ�(ml)');
legend('�ͺ�');

% figure(3);
subplot(4,1,3),plot(Distance,Speed,'r','LineWidth',1);ylim([0 60]);grid on;
xlabel('����(m)');
ylabel('�ٶ�(km/h)');
legend('�ٶ�');

% figure(4);
subplot(4,1,4),plot(Distance,co2,'r','LineWidth',1);grid on;
xlabel('����(m)');
ylabel('CO2�ŷ�(mg)');
legend('CO2�ŷ�');

% Time = 2:clock;
% figure(4);
% plot(Time,Distance,'r','LineWidth',1);ylim([0 100]);grid on;
% xlabel('����');
% ylabel('�ٶ�km/h');
% legend('�ٶ�');
Sumco2 = round(sum(co2))
Sumfuel = sum(fuel)
