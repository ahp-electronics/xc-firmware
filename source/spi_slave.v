/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

module spi_slave (rstb,ten,tdata,mlb,ss,sck,sdin, sdout,done,rdata);
  input rstb,ss,sck,sdin,ten,mlb;
  input [7:0] tdata;
  output sdout;           //slave out   master in 
  output reg done;
  output reg [7:0] rdata;

  reg [7:0] treg,rreg;
  reg [3:0] nb;
  wire sout;
  
  assign sout=mlb?treg[7]:treg[0];
  assign sdout=( (!ss)&&ten )?sout:1'bz; //if 1=> send data  else TRI-STATE sdout


//read from  sdout
always @(posedge sck or negedge rstb)
  begin
    if (rstb==0)
		begin rreg = 8'h00;  rdata = 8'h00; done = 0; nb = 0; end   //
	else if (!ss) begin 
			if(mlb==0)  //LSB first, in@msb -> right shift
				begin rreg ={sdin,rreg[7:1]}; end
			else     //MSB first, in@lsb -> left shift
				begin rreg ={rreg[6:0],sdin}; end  
		//increment bit count
			nb=nb+1;
			if(nb!=8) done=0;
			else  begin rdata=rreg; done=1; nb=0; end
		end	 //if(!ss)_END  if(nb==8)
  end

//send to  sdout
always @(negedge sck or negedge rstb)
  begin
	if (rstb==0)
		begin treg = 8'hFF; end
	else begin
		if(!ss) begin			
			if(nb==0) treg=tdata;
			else begin
			   if(mlb==0)  //LSB first, out=lsb -> right shift
					begin treg = {1'b1,treg[7:1]}; end
			   else     //MSB first, out=msb -> left shift
					begin treg = {treg[6:0],1'b1}; end			
			end
		end //!ss
	 end //rstb	
  end //always

endmodule
      
/*
			if(mlb==0)  //LSB first, out=lsb -> right shift
					begin treg = {treg[7],treg[7:1]}; end
			else     //MSB first, out=msb -> left shift
					begin treg = {treg[6:0],treg[0]}; end	
*/


/*
force -freeze sim:/SPI_slave/sck 0 0, 1 {25 ns} -r 50 -can 410
run 405ns
noforce sim:/SPI_slave/sck
force -freeze sim:/SPI_slave/sck 1 0
*/
