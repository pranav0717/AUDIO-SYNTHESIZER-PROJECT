module piano_rom (
	input logic clock,
	input logic [15:0] address,
	output logic [0:0] q
);

logic [0:0] memory [0:57599] /* synthesis ram_init_file = "./Modules/ROMs/piano/piano.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
