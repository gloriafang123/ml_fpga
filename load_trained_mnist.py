from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
import numpy as np
import mnist

# Build the model.
model = Sequential([
  Dense(10, activation='relu', input_shape=(784,)),
  Dense(10, activation='relu'),
  Dense(10, activation='softmax'),
])

# Load the model's saved weights.
model.load_weights('model.h5')

w1, b1, w2, b2, w3, b3 = list(map(lambda x:x.numpy(), model.weights))

# test_images = mnist.test_images()
# test_labels = mnist.test_labels()
# test_images = test_images.reshape((-1, 784))
# test_images = test_images / 255 - 0.5

# def relu(x): 
#     return np.maximum(0, x)

# def net(x):
#     return w3.T@relu(w2.T@relu(w1.T@x+b1)+b2)+b3


weights = []
biases = []
for i in [w1, w2, w3]:
  weights.append(i.flatten().tolist())
for i in [b1, b2, b3]:
  biases.append(i.flatten().tolist())

def flatten(l):
	l_flat = []
	for i in l:
		l_flat += i
	return l_flat 

weights_flat = flatten(weights)
biases_flat = flatten(biases)

# pickle everything
import pickle
pickle.dump((weights_flat, biases_flat), open("mnist_weights.pkl", "wb"))

w, b = pickle.load(open('mnist_weights.pkl', 'rb'))