module bitmask_rom (
	input logic clock,
	input logic [7:0] address,
	output logic [0:0] q
);

logic [0:0] memory [0:191] /* synthesis ram_init_file = "./Modules/ROMs/bitmask/bitmask.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
