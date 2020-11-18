import numpy as np
import pickle
w, b = pickle.load(open('identity_weights.pkl', 'rb'))

def relu(x):
    return np.maximum(x, 0)

w1 = np.array([w[0:3]])
w2 = np.array(w[3:12]).reshape((3, 3))
w3 = np.array([w[12:15]])
b1 = np.array(b[0:3])
b2 = np.array(b[3:6])
b3 = np.array(b[6])

# print(w1)
# print(w2)
# print(w3)
# print(b1)
# print(b2)
# print(b3)

def f(x):
    x_in = np.array([x])
    return w3@relu(w2@relu(w1.T@x_in+b1)+b2)+b3

def make_plot():
    from matplotlib import pyplot as plt
    xs = np.linspace(-30, 10, 100)
    ys = [f(i) for i in xs]
    plt.plot(xs, ys)
    plt.plot(xs, xs, color='r')
    plt.show()

def int_to_bin(x):
    return '{:08b}'.format(x)

def generate_verilog_testbench_weights():
    l = [249, 5, 252, 254, 252, 253, 0, 252, 7, 5, 255, 3, 253, 248, 250, 255, 2, 8, 4, 7, 2, 16]

    for i in range(15):
        print('weights[{}] = 8\'b{};'.format(i, int_to_bin(l[i])))

    for i in range(7):
        print('biases[{}] = 8\'b{};'.format(i, int_to_bin(l[15+i])))
