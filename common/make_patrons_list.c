#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
main (int argc, char **argv)
{
unsigned char byte;
unsigned char temp;
unsigned int total=0;
unsigned char linha=0;

int data_len,nb_byte,first_byte;
char *end_file_name;
FILE *fid_in,*fid_out;

unsigned char buffer[65535];
/*
if (argc != 3)
{
  printf("Syntax : %s file_in file_out\n",argv[0]);
  exit(0);
}
*/

fid_in = fopen("patrons.list","rb");
if (fid_in == NULL)
{
  printf("can't open patrons.list\n");
  exit(0);
}

fid_out = fopen("patrons_list.vhd","wt");
if (fid_out == NULL)
{
  printf("can't open patrons_list.vhd\n");
  fclose(fid_in);
  exit(0);
}


fseek(fid_in,0,SEEK_END);
data_len = ftell(fid_in);
fseek(fid_in,0,SEEK_SET);


fprintf(fid_out,"library ieee;\n");
fprintf(fid_out,"use ieee.std_logic_1164.all,ieee.numeric_std.all;\n\n");
fprintf(fid_out,"entity patrons_list is\n");
fprintf(fid_out,"port (\n");
fprintf(fid_out,"\tclk  : in  std_logic;\n");
fprintf(fid_out,"\taddr : in  std_logic_vector(11 downto 0);\n");
fprintf(fid_out,"\tdata : out std_logic_vector(7 downto 0);\n");
fprintf(fid_out,"\tlines : out std_logic_vector(7 downto 0)\n");
fprintf(fid_out,");\n");
fprintf(fid_out,"end entity;\n\n");
fprintf(fid_out,"architecture prom of patrons_list is\n");




sprintf(buffer,"\tsignal rom_data: rom :=\n");
sprintf(buffer + strlen(buffer),"\t( --   0     1     2     3     4     5     6     7     8     9");
sprintf(buffer + strlen(buffer),"    10    11    12    13    14    15    16    17    18    19");
sprintf(buffer + strlen(buffer),"    20    21    22    23    24    25    26    27    28    29");
sprintf(buffer + strlen(buffer),"    30    31    32    33    34    35    36    37    38    39");
sprintf(buffer + strlen(buffer),"\n\t\t");

nb_byte = 0;
first_byte = 1;
while(fread(&byte,1,1,fid_in)==1)
{
  if (nb_byte==0 && first_byte==0) 
  {
 //   if (first_byte==0) fprintf(fid_out,",");
    sprintf(buffer + strlen(buffer)," -- %d\n\t\t", linha);
	linha++;
  }
//  else
//  { fprintf(fid_out,","); }

  first_byte = 0;

  temp = byte;
  
  if (nb_byte>=29 && byte == 0x2e) temp = 0x20;
  
  if (temp != 0x0d && temp != 0x0a)
  {
	total++;
	sprintf(buffer + strlen(buffer),"X\"%02X\"",temp);
	//if (total <= 1199) 
		sprintf(buffer + strlen(buffer), ",");
  }

  

  nb_byte++;
  if (nb_byte==42) nb_byte=0;
}



fprintf(fid_out,"\ttype rom is array(0 to  %d) of std_logic_vector(7 downto 0);\n",total-1);
fprintf(fid_out,"%.*s",strlen(buffer)-1,buffer);

fprintf(fid_out,"  -- %d\n\t);\n", linha);

fprintf(fid_out,"begin\n");
fprintf(fid_out,"process(clk)\n");
fprintf(fid_out,"begin\n");
fprintf(fid_out,"\tif rising_edge(clk) then\n");
fprintf(fid_out,"\t\tdata <= rom_data(to_integer(unsigned(addr)));\n");
fprintf(fid_out,"\t\tlines <= x\"%x\";\n", linha+1);
fprintf(fid_out,"\tend if;\n");
fprintf(fid_out,"end process;\n");
fprintf(fid_out,"end architecture;\n");

fclose(fid_in);
fclose(fid_out);
}
