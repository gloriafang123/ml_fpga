import numpy as np
import mnist
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.utils import to_categorical

np.random.seed(0)
tf.random.set_seed(0)

train_images = mnist.train_images()
train_labels = mnist.train_labels()
test_images = mnist.test_images()
test_labels = mnist.test_labels()

# Normalize the images.
train_images = (train_images / 255) - 0.5
test_images = (test_images / 255) - 0.5

import cv2

ds_size = 10
downsampled_train_images = np.zeros((train_images.shape[0], ds_size, ds_size))
for i in range(train_images.shape[0]):
    train_image = train_images[i]
    res = cv2.resize(train_image, dsize=(ds_size, ds_size), interpolation=cv2.INTER_CUBIC)
    downsampled_train_images[i] = res

downsampled_test_images = np.zeros((test_images.shape[0], ds_size, ds_size))
for i in range(test_images.shape[0]):
    test_image = test_images[i]
    res = cv2.resize(test_image, dsize=(ds_size, ds_size), interpolation=cv2.INTER_CUBIC)
    downsampled_test_images[i] = res

train_images = downsampled_train_images.reshape((-1, ds_size*ds_size))
test_images = downsampled_test_images.reshape((-1, ds_size*ds_size))

# Build the model.
model = Sequential([
  Dense(7, activation='relu', input_shape=(ds_size*ds_size,)),
  Dense(10, activation='relu'),
  Dense(10, activation='softmax'),
])

# Compile the model.
model.compile(
  optimizer='adam',
  loss='categorical_crossentropy',
  metrics=['accuracy'],
)

# Train the model.
model.fit(
  train_images,
  to_categorical(train_labels),
  epochs=300,
  batch_size=128,
)

model.evaluate(
  test_images,
  to_categorical(test_labels)
)

model.save_weights('model.h5')
