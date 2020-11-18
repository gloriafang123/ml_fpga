'''Automatically find USB Serial Port (jodalyst 8/2019)
'''
import serial.tools.list_ports
from time import sleep

# convert (8 bit) data with decimals decimal bits to 2s complement
def convert(data, decimals, total_bits):
    if data >= 2**(total_bits-1):
        data = data - 2*2**(total_bits-1)
    data = data/(2**decimals)
    return data

def get_usb_port():
    usb_port = list(serial.tools.list_ports.grep("Leon"))
    if len(usb_port) == 1:
        print("Automatically found USB-Serial Controller: {}".format(usb_port[0].description))
        return usb_port[0].device
    else:
        ports = list(serial.tools.list_ports.comports())
        port_dict = {i:[ports[i],ports[i].vid] for i in range(len(ports))}
        usb_id=None
        for p in port_dict:
            #print("{}:   {} (Vendor ID: {})".format(p,port_dict[p][0],port_dict[p][1]))
            #print(port_dict[p][0],"UART")
            print("UART" in str(port_dict[p][0]))
            if port_dict[p][1]==9025: #for arduino/arduion/clone
                usb_id = p
        if usb_id== None:
            return False
        else:
            print("Found it")
            print("USB-Serial Controller: Device {}".format(p))
            return port_dict[usb_id][0].device

s = get_usb_port()  #grab a port
print("USB Port: "+str(s)) #print it if you got
if s:
    ser = serial.Serial(port = s,
        baudrate=9600,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,    # NOTE this is set at totally 8 bits - max in pyserial
        timeout=0.1) #auto-connects already?
    print("Serial Connected!")
    if ser.isOpen():
         print(ser.name + ' is open...')
else:
    print("No Serial Device :/ Check USB cable connections/device!")
    exit()

try:
    print("Writing...")
    counter = 0
    total_bytes = 0
    while True:
        try:
            x = ser.read() #reads 1 byte
            if len(x)!=0:
              print(int.from_bytes(x, byteorder='little', signed=True))
        except Exception as e:
            print(e)
       # ser.flush()
        bytes_written = ser.write(counter.to_bytes(1, 'little'))
        bytes_written = ser.write(counter.to_bytes(1, 'little'))
        #bytes_written = ser.write(str(counter).encode('ascii'))
        #note need to write it as 8 bit output?
        counter += 1
        counter = counter%10
        total_bytes += bytes_written
        # print (counter, bytes_written, total_bytes)
# this version currently works

##    count = 0
##    while True:
##        try:
##            ser.write(str(count).encode('ascii'))
##            print("it's writing now! counter:", count)
##        except Exception as e:
##            print("failing on write")
##            ser.close()
##            serial_connected = False
##        count = count+1
##    
except Exception as e:
    print(e)


