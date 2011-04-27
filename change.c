#include <stdio.h>

// Initialize all the values
int amt = 80,
    onhand[] = {3, 3, 0, 0}, 
    denoms[] = {25, 10, 5, 1}, 
    ndenoms  = 4,
    thechange[] = {0, 0, 0, 0};

int main()
{
  makechange( amt, onhand, denoms, ndenoms, thechange );
  int i;
  for( i = 0; i < ndenoms; i++ )
    printf("%d\n", thechange[i]);

  return 0;
}
