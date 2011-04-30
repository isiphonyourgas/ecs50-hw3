#include <stdio.h>

// Initialize all the values
int amt = 70,
    onhand[] = {2, 2, 2, 0, 0}, 
    denoms[] = {25, 15, 10, 5, 1}, 
    ndenoms  = 5,
    thechange[] = {0, 0, 0, 0, 0};

int main()
{
  makechange( amt, onhand, denoms, ndenoms, thechange );
  int i;
  for( i = 0; i < ndenoms; i++ )
    printf("%d\n", thechange[i]);

  return 0;
}
