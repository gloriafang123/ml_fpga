import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim

hidden_size_1 = 3
hidden_size_2 = 3

global max_value
max_value = 0
class Net(nn.Module):
	def __init__(self):
		super(Net, self).__init__()
		self.fc1 = nn.Linear(1, hidden_size_1)
		self.fc2 = nn.Linear(hidden_size_1, hidden_size_2)
		self.fc3 = nn.Linear(hidden_size_2, 1)

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
optimizer = optim.SGD(net.parameters(), lr=0.003)

print("-- Let's trainnnn uwu -- ")
for i in range(1000):
	loss = 0
	for j in range(100):
		x = torch.randn(1)
		y = x
		output = net(x)
		criterion = nn.MSELoss()
		loss += criterion(output, y) / 10
	optimizer.zero_grad() 
	loss.backward()
	# for i in net.parameters():
	# 	print(i.grad)
	optimizer.step()
	if i % 10 == 0:
		print("Epoch {}, Loss: {}".format(i, loss))
	# print(x, y, output, loss)

for i in net.parameters():
	print(i)

# print("-- hah testing time -- ")
# loss = 0
# for i in range(100):
# 	x = torch.randn(1)
# 	y = net(x)
# 	print(x, y)
# 	loss += nn.MSELoss()(x, y)
# print("Average Evaluation Loss: ", loss/100)

# print("Max Value: ", max_value)

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
pickle.dump((weights_flat, biases_flat), open("identity_weights.pkl", "wb"))

# to load things from pickle
# weights_flat, biases_flat = pickle.load(open("identity_weights.pkl", "rb"))
