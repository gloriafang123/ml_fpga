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


#when we use actual weights, we need replace with 8 bit, 2-complement
    # so multiply by 2**3, and convert to 2 complement

# send format:
# weight, bias, or inputs (00, 01, 11)
# number of bytes 

# use switches to change the precision case

def byte_complement_numerical(a, decimal_bits, total_bits=8):
    if (a>=0):
        return round(a*2**decimal_bits)
    else:
        return 2**total_bits + round(a*2**decimal_bits)

def convert_data_to_bytes(data_list_raw, dec_bits, total_bits=8):
     return [byte_complement_numerical(data, dec_bits, total_bits) for data in data_list_raw]


# first call convert_data_to_bytes(raw_list, dec_bits=5, total_bits=16)

# data list already all converted to positive values
def send_data(data_type, data_list, num_bytes_each=1):
    try:
        print("Writing", data_type)

        # overhead
        # type of data, number of data, number bytes each
        type_byte = {"weights": 1, "biases": 3, "x": 0}
        num_data = len(data_list)

        assert data_type in type_byte

        ser.write((type_byte[data_type]).to_bytes(1, 'little'))
        #ser.write((num_data).to_bytes(2, 'little')) # problem - need 2 byte for this
        #ser.write((num_bytes_each).to_bytes(2, 'little')) # need 2 byte for this too

        # realised that i never use the overhead metadata anyway
        
        
        # send rest of data
        # lowest bytes, then higher bytes... etc
        for i in range(len(data_list)):
            ser.write(data_list[i].to_bytes(num_bytes_each, 'little'))
           # print("i", i, "ok")
           # print(ser.read())
            # make sure it delays >2ms between these somehow
        print("Done sending", data_type)

        # useful when test only arduino connect rx to pin 2
        for i in range(len(data_list)*num_bytes_each + 3):
            print(ser.read())
    except Exception as e:
        print(e)
