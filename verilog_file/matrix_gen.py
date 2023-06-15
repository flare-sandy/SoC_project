import numpy as np

a = np.array([[1,2,3,4],
              [5,6,7,8],
              [9,10,11,12],
              [13,14,15,16],
              [17,18,19,20],
              [21,22,23,24]],
              dtype=np.int8)

b = np.array([[21,22,23,24],
              [17,18,19,20],
              [13,14,15,16],
              [9,10,11,12],
              [5,6,7,8],
              [1,2,3,4]],
              dtype=np.int8)

def mat_shift(input):
    for col in range(input.shape[1]):
        input[:,col] = np.roll(input[:,col], col)
    return input

def save_mat(path, input):
    fp = open(path,'w')
    fp.write(str(np.size(input,0)))
    fp.write('\n')
    for x in input:
        col_num = np.size(input,1)
        for i in range(0,col_num):
            fp.write('{:08b}'.format(x[col_num-i-1]))
        fp.write('\n')
    return

    

a_s = mat_shift(a)
b_s = mat_shift(b)

save_mat('./a.dat',a_s)