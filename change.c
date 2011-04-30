#include <stdio.h>

// Initialize all the values
int amt = 986,
    onhand[] = {8, 12, 8, 6, 10, 3, 2, 3}, 
    denoms[] = {50, 33, 25, 17, 10, 5, 2, 1}, 
    ndenoms  = 8,
    thechange[] = {0, 0, 0, 0, 0, 0, 0, 0};

int main()
{
  makechange( amt, onhand, denoms, ndenoms, thechange );
  int i;
  for( i = 0; i < ndenoms; i++ )
    printf("%2d: %d\n", denoms[i], thechange[i]);

  return 0;
}
