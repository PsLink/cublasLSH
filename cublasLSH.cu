#include "header.h"
#include <iostream>
#include <cstdlib>
#include <ctime>
#include <cublas_v2.h>
#define IDX2C(i,j,ld) (((j)*(ld))+(i))

//Print matrix A(rows_A, cols_A) storage in column-major format
void print_matrix(const double *A, int rows_A, int cols_A) {
    for (int i = 0; i < rows_A; ++i) {
        for (int j = 0; j < cols_A; ++j) {
            std::cout << A[j * rows_A + i] << " ";
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;
}

// Multiply the arrays A and B on GPU and save the result in C
// C(m,n) = A(m,k) * B(k,n)
void gpu_blas_mmul(cublasHandle_t &handle, const double *A, const double *B, double *C, const int m, const int k, const int n) {
    //ld = leading dimension
    int lda = m, ldb = k, ldc = m;
    const double alf = 1;
    const double bet = 0;
    const double *alpha = &alf;
    const double *beta = &bet;

    // Do the actual multiplication
    cublasDgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, m, n, k, alpha, A, lda, B, ldb, beta, C, ldc);
}


void excuteLSH(int numOfPoint, int numOfHash, int radius,
               vector<vector<int> > &Bucket,
               vector<vector<int> > &DataSet,
               vector<vector<vector<int> > > &hashTable,
               int &MAXHASHVALUE) {

    int dim = DataSet[0].size(), batch = 1000;
    srand((unsigned) time(NULL));

    double *hashFunctions, *b;
    hashFunctions = (double *)calloc(numOfHash * dim, sizeof(double));
    b = (double *)calloc(numOfHash, sizeof(double));

    // build lsh, line by line
    for ( int i = 0; i < numOfHash; i++ )
    {
        // generate a hash function
        for (int j = 0; j < dim; j++) {
            hashFunctions[IDX2C(j, i, dim)] = genCauchyRandom() / radius;
        }

        b[i] = genUniformRandom(0, radius) / radius;
    }

    //print_matrix(hashFunctions,dim,numOfHash);

    double *d_hashFunctions, *d_buckeID, *bucketID, *data, *d_data;

    data = (double *)calloc(dim * batch, sizeof(double));
    bucketID = (double *)calloc(numOfHash * batch, sizeof(double));

    cudaMalloc((void**)&d_buckeID, batch * numOfHash * sizeof(double));
    cudaMalloc((void**)&d_data, batch * dim * sizeof(double));
    cudaMalloc((void**)&d_hashFunctions, numOfHash * dim * sizeof(double));

    cudaMemcpy(d_hashFunctions, hashFunctions, numOfHash * dim * sizeof(double), cudaMemcpyDefault);


    vector<vector<int> > allbucketID;
    vector<int> minID;

    allbucketID.resize(numOfPoint);
    for (int i = 0; i < numOfPoint; i++)
        allbucketID[i].resize(numOfHash);

    minID.resize(numOfHash);

    for (int i = 0; i < numOfHash; i++)
        minID[i] = 0;

    int tmp;
    printf("Start LSH\n");

    // Create a handle for CUBLAS
    cublasHandle_t handle;
    cublasCreate(&handle);

    for (int i = 0; i < numOfPoint; i += batch) {

        for (int k = 0; k < batch; k++)
            for (int j = 0; j < dim; j++)
                data[IDX2C(k, j, batch)] = DataSet[k + i][j];

        cudaMemcpy(d_data, data, dim * batch * sizeof(double), cudaMemcpyDefault);

        gpu_blas_mmul(handle, d_data, d_hashFunctions, d_buckeID, batch, dim, numOfHash);

        cudaMemcpy(bucketID, d_buckeID, numOfHash * batch * sizeof(double), cudaMemcpyDeviceToHost);

        for (int k = 0; k < batch; k++) {
            for (int j = 0; j < numOfHash; j++) {
                //tmp = floor(bucketID[k * numOfHash + j]);
                tmp = floor(bucketID[IDX2C(k, j, batch)] + b[j]);

                allbucketID[i + k][j] = tmp;
                if (tmp < minID[j])
                    minID[j] = tmp;
            }
        }
    }

    // Destroy the handle
    cublasDestroy(handle);

    cudaFree(d_hashFunctions);
    cudaFree(d_data);
    cudaFree(d_buckeID);
    free(data);
    free(bucketID);
    free(hashFunctions);
    free(b);

    //freopen("lsh_result.txt", "w", stdout);
    int actualID;
    printf("finish LSH\n");


    for (int i = 0; i < numOfPoint; i++) {
        for (int j = 0; j < numOfHash; j++) {
            actualID = allbucketID[i][j] - minID[j];
            if (actualID > hashTable[j].size()) {
                hashTable[j].resize(actualID + 500);
            }
            hashTable[j][actualID].push_back(i);
        }
    }
}