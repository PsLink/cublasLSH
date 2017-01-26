# minHashCluster1: main.cpp minHash.cu MinHashTools.cpp Random.cpp C2LSH.cpp
# 	nvcc -o minHashCluster main.cpp minHash.cu MinHashTools.cpp Random.cpp C2LSH.cpp

minHashCluster2: main.cpp Random.cpp cublasLSH.cu
	nvcc -lcublas -o LSH main.cpp Random.cpp cublasLSH.cu
