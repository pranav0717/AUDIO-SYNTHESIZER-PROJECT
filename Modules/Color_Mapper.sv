//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( 	input Clk, blank,
								input score_q,
								input [12:0] deltatime,
								input [4:0] KeyOffset,
								input [9:0] AnchorX, AnchorY, DrawX, DrawY,
                       output logic [7:0]  Red, Green, Blue );

 
//ROM declarations
piano_rom piano(.clock(Clk), .address(piano_address), .q(piano_q));
sine_rom sine(.clock(Clk), .address(sine_address), .q(sine_q));
square_rom square(.clock(Clk), .address(square_address), .q(square_q));
sawtooth_rom saw(.clock(Clk), .address(sawtooth_address), .q(sawtooth_q));
harmony_rom harmony(.clock(Clk), .address(harmony_address), .q(harmony_q));

bitmask_rom bitmask(.clock(Clk), .address(bitmask_address[7:0]), .q(bitmask_q));

Space_rom space_image(.clock(Clk), .address(space_address), .q(space_q));
Space_palette space_palette(.index(space_q), .red(spaceR), .green(spaceG), .blue(spaceB));


//ROM retrieval logic declarations
logic [16:0] piano_address, bitmask_address;
logic [13:0] sine_address, square_address, sawtooth_address, harmony_address;
logic [0:0] piano_q, sine_q, square_q, sawtooth_q, harmony_q, bitmask_q;

//an indicator, telling the bound of the currently played key (rendered in orange):
logic [4:0] score_bound;

logic [17:0]	space_address;
logic [3:0]		spaceR, spaceG, spaceB;
logic [1:0]		space_q;

assign piano_address = (DrawY-360) * 480 + DrawX - 159;
assign sine_address = (DrawY-15) * 120 + DrawX - 20;
assign square_address = (DrawY-135) * 120 + DrawX - 20;
assign sawtooth_address = (DrawY-255) * 120 + DrawX - 20;
assign harmony_address = (DrawY-375) * 120 + DrawX - 20;

assign bitmask_address = (DrawY*24/480) * 8 + (DrawX*8/160);

assign space_address = (DrawY) * 480 + DrawX - 160;

assign score_bound = (DrawX-160)/20;

always_comb begin:RGB_Display
			//feed the blank!
		  if (blank == 0) begin
			Red = 8'h00;
			Green = 8'h00;
			Blue = 8'h00;
		  end
		  
			//cond: drawing the wavetables 
        else begin
				if (DrawX < AnchorX+1) begin
					//cond: within mask
					if(~bitmask_q) begin
						//cond: wavetable foreground
						if ((sine_q && (DrawY < 120)) || (square_q && (DrawY > 120) && (DrawY < 240))|| (sawtooth_q && (DrawY > 240) && (DrawY < 360)) || (harmony_q && (DrawY>360) && (DrawY < 480))) begin
							Red = 8'h00;
							Green = 8'h00;
							Blue = 8'h00;
						end
						//cond: wavetable background
						else begin
							Red = 8'hff;
							Green = 8'hff;
							Blue = 8'hff;
						end;
					end

					//cond: out of mask
					else begin
						Red = {deltatime[5:2], 4'h0};
						Green = 8'hff - {deltatime[6:3], 4'h0};
						Blue = deltatime[7:0];
					end
				end
		  
		  //cond: drawing the piano
				else if (DrawY > AnchorY - 1) begin
					//cond: black pixel
					if (~piano_q) begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = 8'h00;
					end
					//cond: white pixel
					else begin
						Red = 8'hff;
						Green = 8'hff;
						Blue = 8'hff;
					end
				end
		  
		  //cond: drawing the score
				//cond: notes
				else begin
					if(score_q && (DrawX > (score_bound * 20 + 159)) && (score_bound * 20 + 180 > DrawX)) begin
						Red = 8'hff;
						Green = 8'h65;
						Blue = 8'h00;
					end
					//cond: space bg
					else begin
						Red = {spaceR,4'h0};
						Green = {spaceG,4'h0};
						Blue = {spaceB,4'h0};
					end
				end      
		  end
    end 
	 

	
endmodule
