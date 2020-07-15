

t = 1280
s = 32

m = "pix_data_up0"
n = "dout_buf_up0"

for i in range(1, 41):
	print("\t\t7'd{: <2d}\t:\t{} <= {}[{: <4d}:{: <4d}];".format(i, m, n, t-(s*(i-1))-1, t-(s*i)))