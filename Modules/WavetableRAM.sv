module WavetableRAM (
	input Clk,
	input [11:0] Addr,
	input [1:0] BankSelect,
	output [15:0] DataOut
);

	parameter length = 4096;
	parameter bitdepth = 16;
//	logic [13:0] offset;		//offset should be at most 14 bits, due to 4 WTs and 2^12 entries per WT

//always_comb begin
//	//table lookup logic
//	offset = BankSelect * length + Addr;
//
//end

	//Initialize a ROM
logic [bitdepth-1:0] RAM [/* 4* */length];	 
	
initial begin
	//read wavetable contents into ROM
//	$readmemh("Wavetables/sine.txt", RAM, 0, length-1); 
//	$readmemh("Wavetables/square.txt", RAM, length, 2*length-1);
	$readmemh("Wavetables/sawtooth.txt", RAM, 0, length-1);
//	$readmemh("Wavetables/harmony.txt", RAM, 3*length, 4*length-1);
end
	
always_ff @(posedge Clk) begin
	//output update logic
	DataOut <= RAM[/*offset*/Addr];

end
	
endmodule
