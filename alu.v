
module alu(SW, KEY, HEX0, HEX2, HEX4, HEX5);
	input[7:0] SW;
	input[2:0] KEY;
	output[6:0] HEX0;
	output[6:0] HEX2;
	output[6:0] HEX4;
	output[6:0] HEX5;

	wire[7:0] Case0;
	wire[7:0] Case1;
	wire[7:0] Case2;
	wire[7:0] Case3;
	wire[7:0] Case4;
	wire[7:0] Case5;

	reg[7:0] ALUout;

	ripple_carry u0 (
		.A(SW[7:4]),
		.B(4'b0001),
		.S(Case0[7:0])
	);

	ripple_carry u1 (
		.A(SW[7:4]),
		.B(SW[3:0]),
		.S(Case1[7:0])
	);

	addition u2 (
		.A(SW[7:4]),
		.B(SW[3:0]),
		.Sum(Case2[7:0])
	);

	x_or u3 (
		.A(SW[7:4]),
		.B(SW[3:0]),
		.Result(Case3[7:0])
	);

	reduction u4 (
		.A(SW[7:4]),
		.B(SW[3:0]),
		.Result(Case4[7:0])
	);

	concat u5 (
		.A(SW[7:4]),
		.B(SW[3:0]),
		.Result(Case5[7:0])
	);

	
	always @(*)
	begin
		case(KEY[2:0])
			3'b000: ALUout = Case0;
			3'b001: ALUout = Case1; 
			3'b010: ALUout = Case2; 
			3'b011: ALUout = Case3; 
			3'b100: ALUout = Case4;
			3'b101: ALUout = Case5; 
			default: ALUout = 8'b00000000; 	
		endcase
	end

	hex_display u6 (
		.Value(SW[3:0]),
		.Display(HEX0[6:0])
	);

	hex_display u7 (
		.Value(SW[7:4]),
		.Display(HEX2[6:0])
	);

	hex_display u8 (
		.Value(ALUout[3:0]),
		.Display(HEX4[6:0])
	);

	hex_display u9 (
		.Value(ALUout[7:4]),
		.Display(HEX5[6:0])
	);

endmodule


module full_adder(S, cout, A, B, cin);
	input A, B, cin;
	output S, cout;
	
	
	assign S = A^B^cin;
	assign cout = (A&B)|(cin&(A^B));
endmodule

module ripple_carry(A, B, S);
	input[3:0] A;
	input[3:0] B;
	output[7:0] S;
	
	wire final; wire w1; wire w2; wire w3;
	
	full_adder a0 (
		.A(A[0]),
		.B(B[0]),
		.S(S[0]),
		.cout(w1),
		.cin(1'b0)
	);

	full_adder a1 (
		.A(A[1]),
		.B(B[1]),
		.S(S[1]),
		.cout(w2),
		.cin(w1)
	);

	full_adder a2 (
		.A(A[2]),
		.B(B[2]),
		.S(S[2]),
		.cout(w3),
		.cin(w2)
	);

	full_adder a3 (
		.A(A[3]),
		.B(B[3]),
		.S(S[3]),
		.cout(final),
		.cin(w3)
	);

	assign S[4] = final;
	
endmodule


module addition(A, B, Sum);
	input[3:0] A;
	input[3:0] B;
	output[7:0] Sum;
	
	assign Sum[3:0] = A + B;
	assign Sum[7:4] = 4'b0000;
endmodule



module reduction(A, B, Result);
	input[3:0] A;
	input[3:0] B;
	output[7:0] Result;
	
	assign Result[0] = | {A, B};
	assign Result[7:1] = 7'b0000000;

endmodule




module x_or(A, B, Result);
	input[3:0] A;
	input[3:0] B;
	output[7:0] Result;

	assign Result[3:0] = A^B;
	assign Result[7:4] = A|B;
endmodule


module concat(A, B, Result);
	input[3:0] A;
	input[3:0] B;
	output[7:0] Result;
	
	assign Result[7:0] = {A, B};

endmodule
module hex_display (Display, Value);
	input[3:0] Value;
	output[6:0] Display;

	assign Display[0] = ~Value[3] & ~Value[2] & ~Value[1] &  Value[0] |
			 ~Value[3] &  Value[2] & ~Value[1] & ~Value[0] |
			  Value[3] &  Value[2] & ~Value[1] &  Value[0] |
			  Value[3] & ~Value[2] &  Value[1] &  Value[0];

	assign Display[1] = ~Value[3] &  Value[2] & ~Value[1] &  Value[0] |
			     Value[3] &  Value[2] & ~Value[1] & ~Value[0] |
			     Value[3] &  Value[1] &  Value[0] |
			     Value[2] &  Value[1] & ~Value[0];

	assign Display[2] =  Value[3] &  Value[2] & ~Value[1] & ~Value[0] |
			    ~Value[3] & ~Value[2] &  Value[1] & ~Value[0] |
			     Value[3] &  Value[2] &  Value[1];


	assign Display[3] = ~Value[3] &  Value[2] & ~Value[1] & ~Value[0] |
			    ~Value[2] & ~Value[1] &  Value[0] |
			    Value[2] &  Value[1] &  Value[0] |
			    Value[3] & ~Value[2] &  Value[1] & ~Value[0];

	assign Display[4] = ~Value[3] & Value[0] |
			 ~Value[3] &  Value[2] & ~Value[1] |
			 ~Value[2] & ~Value[1] &  Value[0];


	assign Display[5] = ~Value[3] & ~Value[2] & Value[0] |
			    ~Value[3] & ~Value[2] & Value[1] |
			    ~Value[3] &  Value[1] & Value[0] |
			     Value[3] &  Value[2] & ~Value[1] & Value[0];

	assign Display[6] = ~Value[3] & ~Value[2] & ~Value[1]|
			    ~Value[3] &  Value[2] &  Value[1] & Value[0] |
			     Value[3] &  Value[2] & ~Value[1] & ~Value[0];

endmodule
