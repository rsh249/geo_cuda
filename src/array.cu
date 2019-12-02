#include <iostream>
#include <math.h>


// Kernel function to add the elements of two arrays


__global__
void haversine(int n, float *x, float *y)
{


  //int index = threadIdx.x;
  //int stride = blockDim.x;
 // for (int i = index; i < n; i += stride)
  
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  
  float R = 6378.137;
  float toRad = 3.14159/180;
  
  for (int i = index; i < n; i += stride) {
    // y[i] = atan(sqrt(x[i])) * sin(sqrt(y[i])) *4;
    
    float lon1 = x[i];
    float lon2 = x[i];
    float lat1 = y[i];
    float lat2 = y[i];
            
    lon1 = lon1 * toRad;
    lon2 = lon2 * toRad;
    lat1 = lat1 * toRad;
    lat2 = lat2 * toRad;
    float dlon = lon2 - lon1;
    float dlat = lat2 - lat1;
            
    double a = pow(sin(dlat / 2), 2) + (cos(lat1) * cos(lat2) * pow(sin(dlon / 2),2));
    double d = 2 * atan2(sqrt(a), sqrt(1 - a)) * R;
    x[i] = float(d);
    }
}

int main(void)
{
  int N = pow(2,30);
  std::cout << "In: " << N << std::endl;

  float *x, *y;

  // Allocate Unified Memory – accessible from CPU or GPU
  cudaMallocManaged(&x, N*sizeof(float));
  cudaMallocManaged(&y, N*sizeof(float));

  // initialize x and y arrays on the host
  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }

  // Run kernel on 1M elements on the GPU
  // int blockSize = 1024;
  // int numBlocks = (N + blockSize - 1) / blockSize;
  // haversine<<<numBlocks, blockSize>>>(N, x, y);
  //add<<<1,1>>>(N, x, y);
  
  int blockSize = 256;
  int numBlocks = (N + blockSize - 1) / blockSize;
  std::cout << numBlocks << std::endl;
  
  for (int z = 1; z < 1000; z++) { // Run 1000 calls to function to fill GPU for ~1 minute 
    haversine<<<numBlocks, blockSize>>>(N, x, y);
  }
  // Wait for GPU to finish before accessing on host
  cudaDeviceSynchronize();

  std::cout << "First: " << x[0] << std::endl;

  // Free memory
  cudaFree(x);
  cudaFree(y);
  
  return 0;
}