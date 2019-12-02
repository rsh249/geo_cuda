#include <iostream>
#include <math.h>

using namespace std;

void haversine(int n, float *x, float *y)
{

  float R = 6378.137;
  float toRad = 3.14159/180;
  
  for (int i = 1; i < n;i ++) {
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
  
  float *x = new float[N];
  float *y = new float[N];
  
  // initialize x and y arrays on the host
  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }
  
  // Run kernel on the CPU
  haversine(N, x, y);
  
  // Check for errors (all values should be 3.0f)
  float maxError = 0.0f;
  for (int i = 0; i < N; i++)
    maxError = fmax(maxError, fabs(y[i]-3.0f));
  std::cout << "Max error: " << maxError << std::endl;
  
  // Free memory
  delete [] x;
  delete [] y;
  
  return 0;
}