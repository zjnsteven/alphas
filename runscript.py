
#from mpi4py import MPI

import subprocess as sp
import sys
import os


name = MPI.Get_processor_name()
comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

alpha_path = "/sciclone/home00/zjn/wbproj/CTHybrid/alpha.R"

iterations = 572

for c in range(0,size):
	if rank == c:
		for i in range((iterations*rank/size + 1), (iterations*(rank+1)/size+1)):
			try:
				cmd = "Rscript" + " " + alpha_path  + " " + str(i)	
				sts = sp.check_output(cmd, stderr=sp.STDOUT, shell=True)
				print sts
			except sp.CalledProcessError as sts_err:
				print ">> subprocess error code:", sts_err.returncode, '\n', sts_err.output


#qlist = []
#for i in range(1,5):
#	qlist.append(i)

#print "python runs!!!!"
#print "size %d"%size
# while c < len(qlist):
# 	print "Worker - rank %d on %s."%(rank, name) 
# 	print "size %d"%(size)
# 	try:
# 		cmd = "Rscript" + " " + alpha_path  + " " + str(c)
# 	#	# print cmd
# 	#	
# 		sts = sp.check_output(cmd, stderr=sp.STDOUT, shell=True)
# 		print sts
# 	except sp.CalledProcessError as sts_err:                                                                                                   
# 	    print ">> subprocess error code:", sts_err.returncode, '\n', sts_err.output

# 	c += size

#for c in range(0,size):
	#print"c %d"%c
#	if rank == c:
		#print"rank %d"%rank
		#print"length of qlist %d"%len(qlist)
#		for i in range((len(qlist)*rank/size + 1), (len(qlist)*(rank+1)/size+1)):
#			print "Worker - rank %d on %s."%(rank, name) 
#			#print "size %d"%(size)
#			print "i:%d"%(i)
 #           		try:
  #               		cmd = "Rscript" + " " + alpha_path  + " " + str(i)  
   #              		sts = sp.check_output(cmd, stderr=sp.STDOUT, shell=True)
            #     print sts
    #         		except sp.CalledProcessError as sts_err:                                                                                                   
 #                		print ">> subprocess error code:", sts_err.returncode, '\n', sts_err.output
#



# import sys

# st = sys.argv[1]
# ed = sys.argv[2]

# print st
# print ed

# for i in range(int(st),int(ed)):
# 	try:
# 		cmd = "Rscript" + " " + alpha_path  + " " + str(i)	
# 		sts = sp.check_output(cmd, stderr=sp.STDOUT, shell=True)
# 		print sts
# 	except sp.CalledProcessError as sts_err:
# 		print ">> subprocess error code:", sts_err.returncode, '\n', sts_err.output
