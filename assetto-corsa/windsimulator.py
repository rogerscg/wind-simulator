import platform

import sys
import ac
import acsys
import os
import platform
import struct
import traceback

if platform.architecture()[0] == "64bit":
    dllfolder = "stdlib64"
else:
    dllfolder = "stdlib"

cwd = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, os.path.join(cwd, dllfolder))

import usb

dev = None
ep = None


def find_endpoint(e):
    return usb.util.endpoint_direction(e.bEndpointAddress) == usb.util.ENDPOINT_OUT


def acMain(ac_version):
    global dev, ep
    appWindow = ac.newApp("windsimulator")
    ac.setSize(appWindow, 200, 200)
    ac.console("Hello, Assetto Corsa console from windsimulator!")
    ac.console("Wind simulator running with python version" + sys.version)
    try:
        dev = usb.core.find(idVendor=0x0483)
    except Exception as e:
        ac.console(traceback.format_exc())
        ac.console("Device call failed")
        ac.console(str(e))
        return

    if dev is None:
       ac.console("Device not found")
    else:
       ac.console("Device found!")

    # set the active configuration. With no arguments, the first
    # configuration will be the active one
    dev.set_configuration()

    # get an endpoint instance
    cfg = dev.get_active_configuration()
    intf = cfg[(1, 0)]

    ep = usb.util.find_descriptor(intf, custom_match=find_endpoint)
    if ep is None:
        ac.console("Cannot find device endpoint")

    return "windsimulator"


def acUpdate(deltaT):
    global dev, ep
    if dev is None or ep is None:
        return
    speed = ac.getCarState(0, acsys.CS.SpeedMPH)
    # write the data
    if speed < 45:
        data = [0x0]
    elif speed > 100:
        data = [0xFF]
    else:
        fan_diff = 255 - 64
        speed_diff = 120 - 45
        speed_ratio = (speed - 45) / speed_diff
        num = speed_ratio * fan_diff + 64
        data = [int(num)]

    data_str = "".join(chr(n) for n in data)
    ep.write(data_str)