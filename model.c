// CNN Accelerator Model
// Loads an input image and applies DEPTH coefficients to it to generate accumulator sums
// Image and coefficients are stored in BMP format. 
//
// By: Paul Mobbs
//

#include "stdio.h" 
#include "stdlib.h"
#include "string.h"
#include "math.h"

#define WIDTH 28
#define HEIGHT 28
#define DEPTH 4

#pragma pack(push,1)
typedef struct
{
    unsigned char type[2] ;  
    unsigned int fileSize;
    unsigned short reserved1;
    unsigned short reserved2;
    unsigned int offset;
}BmpHeader;

typedef struct
{
    unsigned int headerSize;
    unsigned int width;
    unsigned int height;
    unsigned short planeCount;
    unsigned short bitDepth;
    unsigned int compression;
    unsigned int compressedImageSize;
    unsigned int horizontalResolution;
    unsigned int verticalResolution;
    unsigned int numColors;
    unsigned int importantColors;

}BmpImageInfo;

typedef struct
{
    unsigned char blue;
    unsigned char green;
    unsigned char red;
    //unsigned char reserved;
}Rgb;

typedef struct
{
    BmpHeader header;
    BmpImageInfo info;
    Rgb colors[256];
    unsigned short image[1];
}BmpFile;
#pragma pack(pop)

Rgb* read_image (char* name) { 
    FILE *inFile, *outFile;
    BmpHeader header;
    BmpImageInfo info;
    Rgb *palette, *p;
    int i = 0;


    inFile = fopen(name, "rb");
    if( !inFile )
        return NULL;

    if( fread(&header, sizeof(BmpHeader), 1, inFile) != 1 )
        return NULL; // Manage error and close file


    if( fread(&info, sizeof(BmpImageInfo), 1, inFile) != 1 )
        return NULL; // Manage error and close file
    
    //printf(" %s RGB values %d %d %d \n", name, info.compressedImageSize, info.width,info.height);

    palette = (Rgb*)malloc(sizeof(Rgb) * info.width * info.height);
    fread(palette, sizeof(Rgb), info.width * info.height, inFile);  

    

    fclose(inFile);
    // int ii,jj;
    // int rgb[WIDTH*HEIGHT-1]; 

    // for( i=0; i<(WIDTH*HEIGHT-1); ++i ) { 
    //     p = &palette[i];
    //     rgb[i] = palette[i].red   + palette[i].green*256 + palette[i].blue*65536  ; 
    //     *(int *) svGetArrElemPtr(h,i) = rgb[i]; 
    // }

    return palette;
}

void write_image(Rgb* imgOut) { 
  int i,j,x,y; 
  FILE *f; 
  int w = WIDTH; 
  int h = HEIGHT; 
  unsigned char *img = NULL;
  int filesize = 54 + 3*w*h;  //w is your image width, h is image height, both int
  if( img )
    free( img );
  img = (unsigned char *)malloc(3*w*h);
  memset(img,0,3*w*h);
  int ii,jj;
   int rgb[WIDTH*HEIGHT]; 
   for (ii=0;ii<WIDTH*HEIGHT;ii++) 
      rgb[ii] = imgOut[ii].red   + imgOut[ii].green*256 + imgOut[ii].blue*65536 ; 
  
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

  f = fopen("model.bmp","wb");
  fwrite(bmpfileheader,1,14,f);
  fwrite(bmpinfoheader,1,40,f);
  for(i=0; i<h; i++) {
    fwrite(img+(w*(h-i-1)*3),3,w,f);
    fwrite(bmppad,1,(4-(w*3)%4)%4,f);
  }
  fclose(f);
}

int main(int argc, char *argv[] )  {

    Rgb *img_in, *coeff_in; 
    Rgb img_out[WIDTH*HEIGHT];
    char *coeffs[DEPTH] = {"coeff0.bmp", "coeff1.bmp", "coeff2.bmp", "coeff3.bmp"};
    int accum[DEPTH];
    char *infile;

    if( argc == 2 ) {
       printf("Input image filename provided: %s\n", argv[1]);
       infile = argv[1];
    }
    else {
       infile = "pict.bmp";
       printf("Using default filename: %s\n", infile);
    }

    img_in = read_image(infile);

    for (int j = 0; j < DEPTH; j++) {
        coeff_in = read_image(coeffs[j]);
	accum[j] = 0;

        for(int i = 0; i < WIDTH*HEIGHT; i++) {
            accum[j] += (img_in[i].red * coeff_in[i].red) >> 8 ;
        }
    	printf("%s result: %d\n", coeffs[j], accum[j]);
    }

    return 0;
}

