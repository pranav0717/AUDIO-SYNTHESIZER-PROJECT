//Functionality:
	//If a note is played, convert the note number to target frequency

module MIDIKeyConverter (
	input [7:0] Pitch,
	output [4:0] Offset
);

logic [7:0] offset_temp;

always_comb begin
	//cond: pitch at lease as high as C4 
	if(Pitch > 47 && Pitch < 72) begin 
		offset_temp = Pitch - 48;
		Offset = offset_temp[4:0];
	end
	//cond: out of range
	else begin
		offset_temp = 8'h00;
		Offset = 5'b11000;
	end
end

endmodule
