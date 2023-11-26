module Phase_OSC(
	input MasterCLK,						// Only fed into ROM
	input FSCLK,							// Sampling rate			// Write Phase and Clear Offset
	input [23:0] FreqRegInputVal,			//target value written into Freq Reg
	input [1:0] WTSelect,				//we're gonna have a bunch of wavetables to be selected from
	input [6:0] Velocity,
	output [31:0] WTOUT					//wavetable entry output
);

	
logic [23:0] PhaseReg, FreqReg;	//registers 
logic [22:0] WTBuffer;				//Buffer the ROM entry
logic [15:0] WTTemp;
//need a rom block for wavetable here

WavetableRAM OSCRAM (.Clk(MasterCLK), .Addr(PhaseReg[23:12]), .BankSelect(WTSelect), .DataOut(WTTemp));


	//Reg Init
initial begin

	FreqReg <= 24'b000000101000110111011111; 	// initialize to standard frequency 440hz
									//leftmost 1 modified for debugging
								  //40.86712 entries per sampling interval
	PhaseReg <= 24'h000000;							// set phase offset to 0
	
end

//registers logic:
always_ff @ (posedge FSCLK) begin

	//cond: writing freq reg, clearing phase reg		
		FreqReg <= FreqRegInputVal;
		PhaseReg <= PhaseReg + FreqReg;
	
end



//wavetable lookup logic
assign WTBuffer = WTTemp * Velocity;

always_ff @ (posedge FSCLK) begin
	//sign extension: WT value is signed and can be negative
	WTOUT <= {4'h0,WTBuffer,5'h00};
//	WTOUT <= {8'h0,WTBuffer};
	end


endmodule
