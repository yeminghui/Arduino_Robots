import numpy as np
import scipy.io as scio
import time
import math
traj = scio.loadmat("aa.mat")
traj=traj['expect']
traj[:,2]-=4
base_angle_matrix=[]
left_angle_matrix=[]
right_angle_matrix=[]

# coding:utf-8

# import serial.tools.list_ports
import time




a = 8
b = 12

for i in range(int(traj.shape[0])):
# for i in range(30):
#     sstr = input("请输入：")
    position = traj[i,:]
    target_x = position[0]
    target_y = position[2]
    dist = position[1]
    base_angle = math.atan(-target_x / dist)
    real_base_angle = 90 + base_angle * 180 / math.pi + 15

    t = math.sqrt(dist ** 2 + (-target_x) ** 2)
    sita2 = math.acos((t ** 2 + target_y ** 2 - a ** 2 - b ** 2) / (2 * a * b))
    bta = math.atan(target_y / t)
    fai = math.acos((t ** 2 + target_y ** 2 + a ** 2 - b ** 2) / (2 * a * math.sqrt(t ** 2 + target_y ** 2)))
    sita1 = (bta + fai)

    sita1 = sita1 * 180 / math.pi
    sita2 = sita2 * 180 / math.pi

    real_left_angle = 75 - (sita2 - sita1)
    real_right_angle = 155 - sita1

    message = str(int(real_base_angle)) + ' ' + \
              str(int(real_left_angle)) + ' ' + \
              str(int(real_right_angle))
    # response = ser.readall()
    # print(response)
    base_angle_matrix.append(int(real_base_angle))
    right_angle_matrix.append(int(real_right_angle))
    left_angle_matrix.append(int(real_left_angle))

print(base_angle_matrix)
print(right_angle_matrix)
print(left_angle_matrix)