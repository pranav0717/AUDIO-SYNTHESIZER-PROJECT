module RootSquareSumCalculator(
	input [31:0] sample0, sample1, sample2, sample3,
	output [31:0] pythagorean
);

wire [31:0] a = sample0;
wire [31:0] b = sample1;
wire [31:0] c = sample2;
wire [31:0] d = sample3;
logic [63:0] max_val;
logic [63:0] sum_sq;

always_comb begin
	if (a > b && a > c && a > d) max_val = a;
	else if (b > c && b > d) max_val = b;
	else if (c > d) max_val = c;
	else max_val = d;
	
	sum_sq = a*a + b*b + c*c + d*d;
end

always_comb begin
if (max_val == 0) pythagorean = 0;
else pythagorean = ((sum_sq / (max_val * max_val)) + 1) * max_val;
end

endmodule
