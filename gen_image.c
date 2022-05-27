#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "svdpi.h"

#define HEIGHT 28
#define WIDTH 28

void gen_image(const svOpenArrayHandle hh ) { 
  int i,j,x,y; 
  FILE *f; 
  int w = WIDTH; 
  int h = HEIGHT; 
  unsigned char *img = NULL;
  int filesize = 54 + 3*w*h;  //w is your image width, h is image height, both int
  if( img )
    free( img );
  img = (unsigned char *)malloc(3*w*h);
  memset(img,0,sizeof(img));
  int ii,jj;
   int rgb[WIDTH*HEIGHT]; 
   for (ii=0;ii<WIDTH*HEIGHT;ii++) 
      rgb[ii] = *(int *) svGetArrElemPtr(hh,ii); 
  
  for(i=0; i<w; i++) {
    for(j=0; j<h; j++) {
        img[(i+(h-1-j)*w)*3+2] =   rgb[(i) +(j)*w] & 0xff;
        img[(i+(h-1-j)*w)*3+1] = (rgb[(i) +(j)*w] & 0xff00) >> 8; 
        img[(i+(h-1-j)*w)*3+0] = (rgb[(i) +(j)*w] & 0xff0000) >> 16; 
    }
  }


  unsigned char bmpfileheader[14] = {'B','M', 0,0,0,0, 0,0, 0,0, 54,0,0,0};
  unsigned char bmpinfoheader[40] = {40,0,0,0, 0,0,0,0, 0,0,0,0, 1,0, 24,0};
  unsigned char bmppad[3] = {0,0,0};

  bmpfileheader[ 2] = (unsigned char)(filesize    );
  bmpfileheader[ 3] = (unsigned char)(filesize>> 8);
  bmpfileheader[ 4] = (unsigned char)(filesize>>16);
  bmpfileheader[ 5] = (unsigned char)(filesize>>24);
  bmpinfoheader[ 4] = (unsigned char)(       w    );
  bmpinfoheader[ 5] = (unsigned char)(       w>> 8);
  bmpinfoheader[ 6] = (unsigned char)(       w>>16);
  bmpinfoheader[ 7] = (unsigned char)(       w>>24);
  bmpinfoheader[ 8] = (unsigned char)(       h    );
  bmpinfoheader[ 9] = (unsigned char)(       h>> 8);
  bmpinfoheader[10] = (unsigned char)(       h>>16);
  bmpinfoheader[11] = (unsigned char)(       h>>24);

  f = fopen("test.bmp","wb");
  fwrite(bmpfileheader,1,14,f);
  fwrite(bmpinfoheader,1,40,f);
  for(i=0; i<h; i++) {
    fwrite(img+(w*(h-i-1)*3),3,w,f);
    fwrite(bmppad,1,(4-(w*3)%4)%4,f);
  }
  fclose(f);
  //system ("gwenview test.bmp & "); 
  //system ("gthumb test.bmp  > /dev/null & "); 
}

