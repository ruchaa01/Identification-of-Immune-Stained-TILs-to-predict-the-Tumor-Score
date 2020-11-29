import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from sklearn.svm import SVC

biopslides = pd.readcsv(combined.csv)


X_train, X_test, y_train, y_test = train_test_split(biopslides.loc[:, biopslides.columns != 'y'], biopslides['y'], stratify=y['y'], random_state=66)
training_accuracy = []
test_accuracy = []


svc = SVC()
svc.fit(X_train, y_train)
print("Accuracy on training set: {:.2f}".format(svc.score(X_train, y_train)))
print("Accuracy on test set: {:.2f}".format(svc.score(X_test, y_test)))
