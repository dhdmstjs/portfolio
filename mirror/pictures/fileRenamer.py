import os
acc = 1
directory = 'marcus'

for file in os.listdir(directory):
    os.rename(directory + "/" + str(file), directory + "/marcus" + str(acc) + ".jpg")
    acc += 1

