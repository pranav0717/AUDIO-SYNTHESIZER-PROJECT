module Game_State_Machine (
	input Clk, Reset,
	input Press_Start,
	input [12:0] deltatime,
	output Game_Start,
	output Game_Reset
);

logic [1:0] State, Next_State;
initial begin
	State = 2'b00;
end

always_comb begin: ASSIGN_OUTPUT_BITS
	unique case (State)
	2'b00:;	
		
	2'b01:begin	//call score loader
			end	
	2'b10:;		//game start
	2'b11:;		//game end
	endcase
	
end

always_comb begin: STATE_UPDATE_LOGIC

	unique case (State)
				//TWEAK THESE LATER ON!!!!!!!!!!!!!!!
		2'b00: Next_State = 2'b01;
		2'b01: if(Press_Start) Next_State = 2'b10;
					 else Next_State = 2'b01;
		2'b10: if(deltatime == 13'h1fff) Next_State = 2'b11;
					 else Next_State = 2'b10;
		2'b11: Next_State = 2'b11;
	endcase
end

always_ff @ (posedge Clk) begin
	if (Reset) State <= 2'b00;
	else State <= Next_State;
end

endmodule
