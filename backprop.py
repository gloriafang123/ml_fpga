import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim

hidden_size_1 = 5
hidden_size_2 = 5

class Net(nn.Module):
	def __init__(self):
		super(Net, self).__init__()
		self.fc1 = nn.Linear(1, hidden_size_1)
		self.fc2 = nn.Linear(hidden_size_1, hidden_size_2)
		self.fc3 = nn.Linear(hidden_size_2, 1)

	def forward(self, x):
		x = F.relu(self.fc1(x))
		x = F.relu(self.fc2(x))
		x = self.fc3(x)
		return x

# torch.manual_seed(100)

net = Net()
optimizer = optim.SGD(net.parameters(), lr=0.001)

print("-- Let's trainnnn uwu -- ")
for i in range(1000):
	loss = 0
	for j in range(100):
		x = torch.randn(1) * 10
		y = x
		output = net(x)
		criterion = nn.MSELoss()
		loss += criterion(output, y) / 100
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

print("-- hah testing time -- ")
loss = 0
for i in range(100):
	x = torch.randn(1) * 10
	y = net(x)
	print(x, y)
	loss += nn.MSELoss()(x, y)
print("Average Evaluation Loss: ", loss/100)


# dead code
# import torch
# x = torch.ones([1, 1], requires_grad=False)

# # weights[0] and weights[1]
# w1 = torch.ones([2, 1], requires_grad=True)
# b1 = torch.ones([2, 1], requires_grad=True)

# relu = torch.nn.ReLU()

# preact1 = torch.mm(w1, x) + b1
# output1 = relu(preact1)

# w2 = torch.ones([2, 2], requires_grad=True)
# b2 = torch.ones([2, 1], requires_grad=True)

# preact2 = torch.mm(w2, output1) + b2
# output2 = relu(preact2)

# print(output2)
# w3 = torch.ones([1, 2], requires_grad=True)
# output_final = torch.mm(w3, output2)

# loss = (output_final - x) ** 2
# loss.backward()
