import usb
import sys

print(sys.version)

print("looking for devices...")
for dev in usb.core.find(find_all=True):
    print(dev)

dev = usb.core.find(idVendor=0x0483)
if dev is None:
    raise ValueError('Our device is not connected')
print(dev)

print("Done")