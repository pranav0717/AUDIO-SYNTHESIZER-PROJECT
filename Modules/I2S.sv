module I2S(
	input SCLK, LRCLK,
	input [31:0] Din,
	output Dout);
	
	logic [31:0] L;
	logic [31:0] R;
	
always_ff @ (posedge SCLK) begin
	if(LRCLK) begin//cond: right channel
		R <= Din;
//		Dout <= L[31];
		L <= {L[30:0], 1'b0};
	end			
	else begin//cond: left channel
		L <= Din;
//		Dout <= R[31];
		R <= {R[30:0], 1'b0};		
	end
end

always_comb begin
	if(LRCLK) Dout = L[31];
	else Dout = R[31];
end

endmodule
