module rhythm_game (
	//Clks & Rsts
	input Master_Clk, Frame_Clk, Game_Reset,
	//USB Shield inputs
	input [19:0] KeyOffsets,
	input Press_Start,
	output [12:0] deltatime
);

logic gameinprogress; 
logic temp_start;

//Game_State_Machine statemachine();


//initialization logic
initial begin
	deltatime = 13'h00000;
	gameinprogress = 1'b0;
	temp_start = 1'b0;
end


//Master_Clk update logic: press_start and game termination
always_ff @ (posedge Master_Clk) begin
	if(Game_Reset) begin
		gameinprogress <= 1'b0;
	end
	else begin
		//Cond: if KEY1 is pressed
		if(Press_Start) temp_start <= 1'b1;
		else if (temp_start && ~Press_Start) begin
			gameinprogress <= 1'b1;
			temp_start <= 1'b0;
		end
		//cond: game ends
		if(deltatime == 13'h1ffff) begin
			gameinprogress <= 1'b0;
		end
	end
end


//deltatime update logic
always_ff @ (posedge Frame_Clk) begin
	if(gameinprogress) begin
		if (deltatime != 13'h1ffff) deltatime <= deltatime + 1'b1;
		else;
	end
	else deltatime <= 13'h00000;

end	

endmodule
