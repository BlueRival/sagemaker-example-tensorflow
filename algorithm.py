# How to use this template
#
# This template provides all the structure to deploy any Python based learning algorithm to SageMaker. You will only
# need to provide this algorithm module with three functions exported in order to operationalize your algorithm.
#
# Read this documentation to understand the semantics of how you can use this template in development and how it is used
# once your algorithm is deployed to production.
#
# Simulating the File Paths in Production SageMaker
#
# In production SageMaker wires up directories and files to S3 bucket storage using Docker volumes. This S3 storage
# will be managed for you in production and you don't have to think about it. In development, the Docker containers you
# work with will also have these mappings built for you. The difference is that in development S3 is not used. In
# development there is a directory in the source code called opt. The scripts in this template will wire up the
# directories/files in the following manner:
#
# path in container : path in source code
#
# /opt/ml/input/data/train : opt/train
# /opt/ml/model : opt/model
# /opt/ml/output/failure : opt/output/failure
#
# Interface
#
# Your algorithm in this file (Python module) must export three functions. You may have other functions in this module
# or in other modules, but the template in this project will ignore all of that. The functions you must export and
# implement are Init(), Train() and Predict(). Here are descriptions of what each function should do.
#
# Init(mode):
#
# Input: Mode is a string either 'train' or 'predict'. This allows you to setup your algorithm. For this example
# algorithm I was able to use a single init that works regardless of train or predict mode. You may need to init your
# module differently depending on the mode of operation. If you can have one init for both modes, like this template,
# simply make Init() an empty function as is shown below.
#
# This function is called once when your code is started. It tells your code whether it is running in training mode or
# in prediction mode.
#
# Train():
#
# Input: None
# Return: None
#
# This function is called when we are training your algorithm. This function should read training data (csv files) from
# /opt/ml/input/data/train, and once training is complete the trained model artifacts should be written to
# /opt/ml/model.
#
# Any errors or failures should be written to a text file /opt/ml/output/failure. This includes any validation tests
# built into the training logic.
#
# This function is called once when your code is started for training. It is called after Init() is called and returns.
#
#
# Predict(features):
#
# Input: Takes a Python Dictionary object of all input features for a single example to classify/predict/etc. Each
# feature on the example will be identified by name.
# Return: A Python Dictionary of all classifications/predictions/etc.
#
# The timing of this function is critical because this is the only function called for your algorithm when processing
# real-time examples. Thus, this module should load your algorithm at the global file level or in the Init() function.
# This method needs to run as fast as possible.
#
# This function is called for every invocation of the prediction EndPoint. However, it will not be called until after
# Init() is called and returns. Make sure Init() does not return until Predict() is ready to be called immediately.
#
#
# Note: For AWS notes on Docker file paths mentioned above, see:
# https://docs.aws.amazon.com/sagemaker/latest/dg/your-algorithms-training-algo.html

from __future__ import absolute_import, division, print_function

import pandas as pd
import tensorflow as tf

# these are the names of each column in the input CSV file
INPUT_COLS = ['input1', 'input2', 'input3', 'xor_', 'add_', 'and_', 'or_']

train_file = "/opt/ml/input/data/train/input.csv"


# utility function for parsing the input file and returning the proper features and label objects
def load_data():
    inputData = pd.read_csv(train_file, names=INPUT_COLS, header=0)

    features = inputData[['input1', 'input2', 'input3']].copy()
    labels = inputData[['xor_', 'add_', 'and_', 'or_']].copy()

    return features, labels  # returns the features and the output classification


# converts the parsed CSV input data into a batch
def get_training_dataset(train_features, train_labels):
    return tf.data.Dataset \
        .from_tensor_slices((dict(train_features), train_labels)) \
        .repeat() \
        .batch(train_features.shape[0])  # use all rows


# just sets logging levels on TensorFlow
tf.logging.set_verbosity(tf.logging.INFO)

# define the shape of the input data nodes for the DNN
my_feature_columns = []
my_feature_columns.append(tf.feature_column.numeric_column(key='input1', dtype=tf.float32))
my_feature_columns.append(tf.feature_column.numeric_column(key='input2', dtype=tf.float32))
my_feature_columns.append(tf.feature_column.numeric_column(key='input3', dtype=tf.float32))

# Build hidden layer DNN with 20, 20 units respectively on each hidden layer.
classifier = tf.estimator.DNNRegressor(
    feature_columns=my_feature_columns,
    label_dimension=4,  # we predict 4 different mathematical operations
    hidden_units=[20, 20, 20, 20],  # Two hidden layers of 20 nodes each.
    model_dir='/opt/ml/model',  # models will get stored here after training, and loaded from here on predict
    activation_fn=tf.nn.relu,  # activation function we are using for each node
    optimizer=tf.train.GradientDescentOptimizer(  # our optimizer for training
        learning_rate=0.001
    )
)


def Init(mode):
    # NO-OP
    return


def Train():
    # get the training data out of the CSV
    train_features, train_labels = load_data()

    # Train the Model.
    classifier.train(input_fn=lambda: get_training_dataset(train_features, train_labels), steps=5000)


def Predict(features):
    # generate an input function based on the value we would like to predict
    def predict_input_fn():
        return tf.data.Dataset \
            .from_tensor_slices(dict({
            'input1': [features['input1']],
            'input2': [features['input2']],
            'input3': [features['input3']]
        })) \
            .batch(1)

    # make the prediction based on input data
    results = classifier.predict(input_fn=predict_input_fn)

    # just get the first result from the iterable returned from prediction
    result = next(results, None)

    # function to cleanup the network output values and clamp to integers
    def normalize_numbers(number):
        # ignore sufficiently small numbers and clamp to zero
        if (abs(number) < 0.01):
            number = 0

        # we know our data set has no valid floating point output
        number = round(number, 0)
        number = int(number)

        return number

    # cleanup the actual result
    predictions = map(normalize_numbers, result['predictions'])

    # convert the result from array of output values to dictionary of labelled output values
    result = dict(zip(['xor_', 'add_', 'and_', 'or_'], predictions))

    return result
