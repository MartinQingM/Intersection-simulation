clear
close all
clc
import traci.constants
system(['sumo-gui -c ' './intersection.sumocfg &']);%��m�ļ�����sumocfg�ļ�ͬ�ļ�����

unitchange = @(x) x*3600/1000; %�䵥λ��m/s��km/h
clock = 0;  %��ʱ��
a=0;
traci.init();%��ʼ���ӿ�
Tidb = [];
s = [];
f = [];%�����ۼӵ��ͺĲ���
d = [];%���վ������
while traci.simulation.getMinExpectedNumber()>0 %�޳���ʱ����
    traci.simulationStep();
    
    ID = traci.vehicle.getIDList();
    if ~isempty(strfind(ID, 'veh0')); %�����б�����veh0ʱ��ʼ
        
%         idb_arrived = traci.vehicle.getDistance('veh0');
%         if idb_arrived >= 400
%             a=1;
%             Tidb = clock;
%         end
        fuel = [f,traci.vehicle.getFuelConsumption('veh0')];%��ÿstep�ͺļ�������
        f = fuel;
        Distance = [d,traci.vehicle.getDistance('veh0')];%��ÿstep�����������
        d = Distance;
        current_speed_veh0 = traci.vehicle.getSpeed('veh0');
        
        current_speed_veh0 = unitchange(current_speed_veh0);
        Speed = [ s,current_speed_veh0];%��ÿstep�ٶȼ�������
        s = Speed;
    else
    end
    clock = clock +1;
end

traci.close()%�رսӿ�

figure(1);
plot(Speed,'r','LineWidth',1);ylim([0 60]);grid on;
xlabel('ʱ��');
ylabel('�ٶ�km/h');
legend('�ٶ�');

figure(2);
plot(Distance,fuel,'r','LineWidth',1);xlim([0 700]);ylim([0 7]);grid on;
xlabel('����');
ylabel('˲ʱ�ͺ�/ml');
legend('�ͺ�');

figure(3);
plot(Distance,Speed,'r','LineWidth',1);ylim([0 60]);grid on;
xlabel('����');
ylabel('�ٶ�km/h');
legend('�ٶ�');

% Time = 2:clock;
% figure(4);
% plot(Time,Distance,'r','LineWidth',1);ylim([0 100]);grid on;
% xlabel('����');
% ylabel('�ٶ�km/h');
% legend('�ٶ�');

Sumfuel = sum(fuel)
