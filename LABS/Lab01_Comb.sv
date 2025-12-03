module Comb(
  // Input signals
	in_num0,
	in_num1,
	in_num2,
	in_num3,
  // Output signals
	out_num0,
	out_num1
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [6:0] in_num0, in_num1, in_num2, in_num3;
output logic [7:0] out_num0, out_num1;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [6:0] A, B, C, D;
logic [7:0] F;

//---------------------------------------------------------------------
//   Your DESIGN                        
//---------------------------------------------------------------------
assign A = in_num0 ~^ in_num1;
assign B = in_num1 | in_num3;
assign C = in_num0 & in_num2;
assign D = in_num2 ^ in_num3;
assign out_num0 = ((A > B) ? A : B) + ((C > D) ? C : D);
assign F = ((A < B) ? A : B) + ((C < D) ? C : D);
assign out_num1 = F ^ (F>>1);

endmodule