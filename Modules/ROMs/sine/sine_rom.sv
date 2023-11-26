module sine_rom (
	input logic clock,
	input logic [13:0] address,
	output logic [0:0] q
);

logic [0:0] memory [0:10799] /* synthesis ram_init_file = "./Modules/ROMs/sine/sine.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
