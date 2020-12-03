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


#when we use actual weights, we need replace with 8 bit, 2-complement
    # so multiply by 2**3, and convert to 2 complement

def byte_complement_numerical(a, decimal_bits):
    if (a>=0):
        return round(a*2**decimal_bits)
    else:
        return 2**8 + round(a*2**decimal_bits)

weights_flat = [-0.3883357048034668,
    0.3158431053161621,
    -0.23743802309036255,
    -0.016122400760650635,
    0.4024184048175812,
    0.8359229564666748,
    -1.022859811782837,
    -0.8266417384147644,
    -0.2919713258743286,
    -0.38196253776550293,
    -0.3783053159713745,
    0.2355988621711731,
    0.4635140895843506,
    1.526415467262268,
    0.29619747400283813,
    -0.31882014870643616,
    -0.5412128567695618,
    -0.37132933735847473,
    0.37394243478775024,
    0.27433112263679504,
    0.5508195161819458,
    1.1307785511016846,
    -1.9099769592285156,
    0.2830394506454468,
    -0.6758014559745789,
    0.45171502232551575,
    0.2815351188182831,
    -0.5238226056098938,
    0.3112277686595917,
    -0.3196379244327545]
biases_flat = [0.21176540851593018,
    0.4078308343887329,
    -0.08169472217559814,
    -0.056860074400901794,
    1.8681126832962036,
    9.374431829201058e-05,
    -0.8045271039009094,
    0.8039725422859192,
    0.3733140826225281]

test_weights = [] # weights and biases

for w in weights_flat:
    test_weights.append(byte_complement_numerical(w, 3)) # decimal bits for now
for b in biases_flat:
    test_weights.append(byte_complement_numerical(b, 3))

# print(test_weights)

# error with int too big
for i in range(len(test_weights)):
    if test_weights[i] >= 256:
        test_weights[i] = 255

try:
    print("Writing...")
    counter = 0
    total_bytes = 0
    i = 0
    while True:
        
        try:
            x = ser.read() #reads 1 byte
            
            if len(x)!=0:
              #print("read x", x)
              print(int.from_bytes(x, byteorder='little', signed=True))
        except Exception as e:
            print(e)

# sends the weights
        if i < len(test_weights):
            current_weight = test_weights[i]
            bytes_written = ser.write(current_weight.to_bytes(1, 'little'))
            bytes_written = ser.write(current_weight.to_bytes(1, 'little'))
            bytes_written = ser.write(current_weight.to_bytes(1, 'little'))
        #bytes_written = ser.write(str(counter).encode('ascii'))

        total_bytes += bytes_written*2
        i += 1

        if i>len(test_weights):
            print("done sending weights")

# do something similar for sending biases
      
except Exception as e:
    print(e)


