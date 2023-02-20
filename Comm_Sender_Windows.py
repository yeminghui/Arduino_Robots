import numpy as np

import time
import math
traj = np.loadtxt("aa.txt")


# coding:utf-8

import serial.tools.list_ports
import time
plist = list(serial.tools.list_ports.comports())

if len(plist) <= 0:
        print("没有发现端口!")
else:
    plist_0 = list(plist[0])
    serialName = plist_0[0]
    serialFd = serial.Serial(serialName, 9600, timeout=60)
    print("可用端口名>>>", serialFd.name)



    a = 8
    b = 12

    for i in range(int(traj.shape[0])):
    # for i in range(30):
    #     sstr = input("请输入：")
        time.sleep(1)
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

        print("基体角度为：", real_base_angle)
        print("左臂角度为：", real_left_angle)
        print("右臂角度为：", real_right_angle)
        print('\n')
        serialFd.write(str.encode(message))
        if i==0:
            time.sleep(5)
        if i==1:
            time.sleep(3)
        # response = ser.readall()
        # print(response)