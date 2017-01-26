/*
 * headers.h
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include <fstream>
#include <algorithm>
#include <utility>
#include <vector>

#include <iostream>
#include <string>

//using namespace __gnu_cxx;
using namespace std;

#include "BasicDefinitions.h"
#include "Random.h"
#include "MinHashTools.h"
#include "minHash.h"
#include "cublasLSH.h"
//#include "C2LSH.h"

///** On OS X malloc definitions reside in stdlib.h */
//#ifdef DEBUG_MEM
//#ifndef __APPLE__
//#include <malloc.h>
//#endif
//#endif
//
#ifdef DEBUG_TIMINGS
#include <sys/time.h>
#endif
