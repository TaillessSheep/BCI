Version A: 	The .mat file contains a 'check' variable (True if its write is by Python but not read by MATLAB; Faluse if writen by MATLAB but not read by python)
		Since this version consist of file writing at MATLAB side (which is far slower that Python writing) and reading at Python side (which is ok)

Version B:	Got ride of the 'check' variable. Without the writing at MATLAB side and reading at Python side, this should make the whole programe run faster.

Version C:	Base of version A, a change is made for the 'check' variable (0: if the data has been read by MATLAB; any other numbers: mean how many new data in the file that are not read by MATLAB)
