let data = new Uint8Array(8);
let device = null;

async function getEndpointNumber() {
  for (const config of device.configurations) {
    for (const interface of config.interfaces) {
      if (!interface.claimed) {
        continue;
      }
      for (const alt of interface.alternates) {
        // Identify the interface implementing the USB CDC class.
        const USB_CDC_CLASS = 10;
        if (alt.interfaceClass != USB_CDC_CLASS) {
          continue;
        }

        for (const endpoint of alt.endpoints) {
          if (endpoint.type != 'bulk') {
            continue;
          }
          if (endpoint.direction == 'out') {
            return endpoint.endpointNumber;
          }
        }
      }
    }
  }
  return null;
}

async function createUSBConnection() {
  await navigator.usb.requestDevice({ filters: [{}] });
  const devices = await navigator.usb.getDevices();
  console.log('Total devices: ' + devices.length);
  device = devices[0];
  await device.open();
  await device.selectConfiguration(1);
  await device.claimInterface(1);
  await device.controlTransferOut({
    requestType: 'class',
    recipient: 'device',
    request: 0x22,
    value: 0x01,
    index: 0x01,
  });
  console.log(
    'Connected to ' +
      device.productName +
      ', serial number ' +
      device.serialNumber
  );
}

function installSliderListener() {
  const slider = document.getElementById('fan-range');
  slider.addEventListener('input', async (e) => {
    if (device != null) {
      data[0] = Math.floor((Number(e.target.value) / 100) * 255);
      endpointNumber = await getEndpointNumber();
      device.transferOut(endpointNumber, data);
    }
  });
}

function installConnectListener() {
  const button = document.getElementById('connect-button');
  button.addEventListener('click', createUSBConnection);
}

function main() {
  installSliderListener();
  installConnectListener();
}

document.addEventListener('DOMContentLoaded', main);
