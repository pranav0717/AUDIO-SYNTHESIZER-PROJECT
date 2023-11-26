module Space_rom (
	input logic clock,
	input logic [17:0] address,
	output logic [1:0] q
);

logic [1:0] memory [0:172799] /* synthesis ram_init_file = "./Modules/ROMs/Space/Space.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
