
clear all;
clc;
close all;

%       theta    d           a        alpha     offset
SL1=Link([0       0          0     -pi/2        0     ],'standard'); 
SL2=Link([0       0          8     0           0     ],'standard');
SL3=Link([0       0          12    -pi/2        0     ],'standard');

robot=SerialLink([SL1 SL2 SL3],'name','robot');

[nIterations,sizePath,path,run_time]=RRTconnect3D(3,5,0,1);
s=size(path);
control_points=path(:,1:3)./10;

knots=linspace(0,1,s(1)).';
spy =spapi(5,control_points(:,1),control_points(:,2));
spz =spapi(5,control_points(:,1),control_points(:,3));

dx=0.5:0.03:9.5;
y=fnval(spy,dx);
z=fnval(spz,dx);

path=[dx;y;z].';


point=path.*1.5;
x=point(:,1);
x=x-5;
y=point(:,2);
z=point(:,3);
% ÄæÔË¶¯Ñ§
for i=1:length(x)
    if x(i)>=0
        sita(i)=atan(y(i)/x(i));
    elseif x(i)<0
        sita(i)=pi+atan(y(i)/x(i));
    end
    
end
sita=sita.';
bita2=atan(z./sqrt(x.^2+y.^2));
fai=acos(((x.^2+y.^2+z.^2)+8^2-12^2)./(2*8*sqrt(x.^2+y.^2+z.^2)));
bita=-(bita2+fai);
gama=(acos((x.^2+y.^2+z.^2-8^2-12^2)/(2*8*12)));
% bita=-bita*180/3.14;
% gama=-gama*180/3.14;
% fprintf('%d,%d,%d',sita*180/3.14,bita*180/3.14,gama*180/3.14);
q=[sita bita gama];
expect=[x y z];
% figure();
% plot2([x y z],'r.')
% robot.plot(q);


disp=[];

figure();
plot2(expect(1:end-1,:),'r.');
robot.plot(q);






