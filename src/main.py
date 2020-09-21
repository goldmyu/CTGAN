from timeit import default_timer as timer

from synthesizer import CTGANSynthesizer
import pandas as pd
import torch
from datetime import datetime
# from sdgym import benchmark


# data = pd.read_csv("datasets/events_only_files_extensions.csv")
data = pd.read_csv("../../datasets/events_only_files_extensions.csv")

# ======================================== Hayper-parameters ===========================================================

start_time = timer()
batch_size = 1000
num_of_epochs = 10
number_of_events_in_dataset = len(data.index)
start_datetime = datetime.now().strftime("%d-%m-%Y_%H%M")
weekday_percentage = data['weekday'].value_counts(normalize=True)

discrete_columns = [
    'minute',
    'hour',
    'day',
    'month',
    'year',
    'weekday',
    'user',
    'pc',
    'major_pc',
    'activity'
]

# ======================================================================================================================

print("Hyper-parameters\nbatch_size {}\nnum_of_epochs {}\n discrete_columns {}"
      .format(batch_size, num_of_epochs, discrete_columns))
print("Starting training of CTGAN - datetime is {}".format(start_datetime))
print("Weekdays distribution is {}".format(weekday_percentage))

# remove session_id column from dataset
# data = data.drop(columns=["session_id", "label"])
data = data.drop(columns=["label"])

# from src.models.ctgan.demo import load_demo
# import os
# import sys
#
# dir_path = os.path.dirname(os.path.realpath(__file__))
# parent_dir_path = os.path.abspath(os.path.join(dir_path, os.pardir))
# sys.path.insert(0, parent_dir_path)
# data = load_demo()

# discrete_columns = [
#     'workclass',
#     'education',
#     'marital-status',
#     'occupation',
#     'relationship',
#     'race',
#     'sex',
#     'native-country',
#     'income'
# ]

# create and train model
ctgan_model = CTGANSynthesizer(batch_size=batch_size)
ctgan_model.fit(train_data=data, weekday_percentage=weekday_percentage,
                discrete_columns=discrete_columns, epochs=num_of_epochs)

# Generate samples, save gen data to CSV and save model
generated_data = ctgan_model.sample(number_of_events_in_dataset)
end_datetime = datetime.now().strftime("%H%M")
generated_data.to_csv("generated_files/generated_datasets/Generated_data_"
                      + start_datetime + "-" + end_datetime + ".csv", index=False)
torch.save(ctgan_model, 'generated_files/saved_models/ctgan_trained_model_' + start_datetime + "-" + end_datetime)

end_time = timer()
print(generated_data)
print("Total training time was {}".format(end_time - start_time))
