import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from sklearn.model_selection import train_test_split
from sklearn.utils import shuffle

import numpy as np

from sklearn.preprocessing import OneHotEncoder

f = open('iris.data', 'r')
lines = f.readlines()[:-1]
x_raw = []
y_raw = []
for l in lines:
    line = l.strip().split(',')
    x_raw.append(list(map(lambda x:float(x), line[:-1])))
    y_raw.append(line[-1])

x_np = np.asarray(x_raw, dtype=np.float32)
enc = OneHotEncoder(handle_unknown='ignore')
enc.fit(np.array(y_raw).reshape(-1, 1))
y_onehot = enc.transform(np.array(y_raw).reshape(-1, 1)).toarray()
y_np = np.argmax(y_onehot, axis=1)

x_np, y_np = shuffle(x_np, y_np)

x_tr, x_te, y_tr, y_te = train_test_split(x_np, y_np, test_size=0.8)

x = torch.Tensor(x_tr)
y = torch.Tensor(y_tr).type(torch.LongTensor)
x_test = torch.Tensor(x_te)
y_test = torch.Tensor(y_te)

hidden_size_1 = 3
hidden_size_2 = 3

global max_value
max_value = 0
class Net(nn.Module):
	def __init__(self):
		super(Net, self).__init__()
		self.fc1 = nn.Linear(4, hidden_size_1)
		self.fc2 = nn.Linear(hidden_size_1, hidden_size_2)
		self.fc3 = nn.Linear(hidden_size_2, 3)

	def forward(self, x):
		global max_value
		max_value = max(max_value, torch.max(x))
		x = F.relu(self.fc1(x))
		max_value = max(max_value, torch.max(x))
		x = F.relu(self.fc2(x))
		max_value = max(max_value, torch.max(x))
		x = self.fc3(x)
		max_value = max(max_value, torch.max(x))
		return x

torch.manual_seed(100)

net = Net()
optimizer = optim.SGD(net.parameters(), lr=0.01)

print("-- Let's trainnnn uwu -- ")
for i in range(10000):
    loss = 0
    output = net(x)
    criterion = nn.CrossEntropyLoss()

    loss += criterion(output, y)
    optimizer.zero_grad() 
    loss.backward()

    optimizer.step()
    if i % 1000 == 0:
        print("Epoch {}, Loss: {}".format(i, loss))
	# print(x, y, output, loss)

y_pred = np.argmax(net(x_test).detach().numpy(), axis=1)
print(np.sum(y_pred == y_test.numpy()) / y_pred.shape[0])

# Extract weights

for param_tensor in net.state_dict():
    print(param_tensor, "\t", net.state_dict()[param_tensor])

weights = []
biases = []
d = net.state_dict()
keys = list(d)
for param_name in keys:
	if 'weight' in param_name:
		weights.append(d[param_name].numpy().flatten().tolist())
	elif 'bias' in param_name:
		biases.append(d[param_name].numpy().flatten().tolist())

def flatten(l):
	l_flat = []
	for i in l:
		l_flat += i
	return l_flat 

weights_flat = flatten(weights)
biases_flat = flatten(biases)

# pickle everything
import pickle
pickle.dump((weights_flat, biases_flat), open("iris_weights.pkl", "wb"))
