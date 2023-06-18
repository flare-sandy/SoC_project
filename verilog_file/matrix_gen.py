import numpy as np

input = np.random.randint(0, 128, (32,96), dtype=np.int32)
wq = np.random.randint(0, 128, (96,96), dtype=np.int32)

# # print(d)

# def mat_shift(input):
#     zero_mat = np.zeros((input.shape[1], input.shape[1]), dtype=np.int32)
#     input = np.append(input, zero_mat, axis=0)
#     for col in range(input.shape[1]):
#         input[:,col] = np.roll(input[:,col], col)
#     return input

def save_mat(path, input, format='b'):
    fp = open(path,'w')
    fp.write(str(np.size(input,0)))
    fp.write('\n')
    for x in input:
        col_num = np.size(input,1)
        for i in range(0,col_num):
            if format == 'b':
                fp.write('{:08b}'.format(x[col_num-i-1]))
            else:
                fp.write('{:d} '.format(x[col_num-i-1]))
        fp.write('\n')
    return

def display_origin_mat(path, input):
    fp = open(path,'w')
    # fp.write(str(np.size(input,0)))
    # fp.write('\n')
    for x in input:
        col_num = np.size(input,1)
        for i in range(0,col_num):
            fp.write('{:d}\t'.format(x[i]))
        fp.write('\n')
    return

# print(input)
input_block = np.split(input, input.shape[0]//8, axis=0)
# print(input_block)
input_rs = np.hstack(input_block)
# print(input_rs)

# print(wq)
wq_block = np.split(wq, wq.shape[0]//8, axis=1)
# print(wq_block)
wq_rs = np.vstack(wq_block)
# print(wq_rs)

display_origin_mat('D:/temp/input10.dat', input)
display_origin_mat('D:/temp/wq10.dat', wq)

save_mat('D:/temp/input.dat', input_rs.T)
save_mat('D:/temp/wq.dat', wq_rs)

res = np.matmul(input, wq)
res_block = np.split(res, res.shape[0]//8, axis=0)
res_rs = np.hstack(res_block)
print(res)

display_origin_mat('D:/temp/res10.dat', res)
save_mat('D:/temp/res.dat', res_rs.T, format='d')

# a_s = mat_shift(a)
# b_s = mat_shift(b)
# c_s = mat_shift(c)
# d_s = mat_shift(d)

