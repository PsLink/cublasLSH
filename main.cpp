#include "header.h"

clock_t start, end;

void initDataSet(int numOfPoint, int dim, vector<vector<int> > &DataSet, char* filename) {
	FILE *fin = fopen(filename, "r");

	int tmp;
	vector<int> tmpPoint;

	start = clock();

	for (int i = 0; i < numOfPoint; i++) {
		tmpPoint.clear();
		tmpPoint.resize(dim);
		for (int j = 0; j < dim; j++) {
			fscanf(fin, "%d", &tmp);
			tmpPoint[j] = tmp;
		}
		DataSet.push_back(tmpPoint);
	}
	end = clock();

	printf("running time for reading data: %.2f\n", (double)(end - start) / CLOCKS_PER_SEC);
	fclose(fin);
}

void initBucket(int numOfPoint, int numOfHash, int radius,
                vector<vector<int> > &Bucket,
                vector<vector<int> > &DataSet) {

	vector<vector<vector<int> > > hashTable; // <hashTable<bucket<points in bucket> > >
	int bucketID;
	int MAXHASHVALUE = 5000;

	hashTable.resize(numOfHash);
	for (int i = 0; i < numOfHash; i++)
		hashTable[i].resize(MAXHASHVALUE);

	if (DataSet.empty()) {
		FILE *hashResult;
		hashResult = fopen("data_lsh.txt", "r");
		for (int pointID = 0; pointID < numOfPoint; pointID++)
			for (int hashID = 0; hashID < numOfHash; hashID++) {
				fscanf(hashResult, "%d", &bucketID);
				hashTable[hashID][bucketID].push_back(pointID);
			}
		fclose(hashResult);
	} else {
		start = clock();
		//printf("blablabka %d\n", DataSet[0].size());
		excuteLSH(numOfPoint, numOfHash, radius, Bucket, DataSet, hashTable, MAXHASHVALUE);
		end = clock();
		printf("running time for LSH on data: %.2f\n", (double)(end - start) / CLOCKS_PER_SEC);
	}

	for (int i = 0; i < numOfHash; i++)
		for (int j = 0; j < hashTable[i].size(); j++)
			if (hashTable[i][j].size() > 100)
				Bucket.push_back(hashTable[i][j]);

	printf("The number of buckets are %d\n", Bucket.size());
}

int main() {
	vector<vector<int> > DataSet;
	vector<vector<int> > Bucket;

	int numOfPoint = 1000, numOfHash = 100, dim = 128, radius = 200;
	char inputFile[100] = "data.txt";

	initDataSet(numOfPoint, dim, DataSet, inputFile);

	// for (int i=0; i<numOfPoint; i++)
	// 	printf("%d \n", DataSet[i].size());

	initBucket(numOfPoint, numOfHash, radius, Bucket, DataSet);


	for (int i = 0; i < Bucket.size(); i++)
		sort(Bucket[i].begin(), Bucket[i].end());

	for (vector<vector<int> >::iterator bucketID = Bucket.begin(); bucketID != Bucket.end(); ++bucketID) {
		for (vector<int>::iterator item = (*bucketID).begin();  item != (*bucketID).end(); ++item)
			printf("%d ", *item);
		printf("\n");
	}

	return 0;
}
