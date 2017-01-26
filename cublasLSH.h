#ifndef GPU_LSH_H
#define GPU_LSH_H

void excuteLSH(int numOfPoint, int numOfHash, int radius, 
               vector<vector<int> > &Bucket, 
               vector<vector<int> > &DataSet, 
               vector<vector<vector<int> > > &hashTable,
               int &MAXHASHVALUE);

#endif
