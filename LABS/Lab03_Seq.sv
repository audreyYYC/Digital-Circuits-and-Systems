module Seq(
	// Input signals
	clk,
	rst_n,
	in_valid,
	card,
	// Output signals
	win,
	lose,
	sum
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [3:0] card;
output logic win, lose;
output logic [4:0] sum;

//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION                         
//---------------------------------------------------------------------

//---------------------------------------------------------------------
//   YOUR DESIGN                        
//---------------------------------------------------------------------
logic [4:0] current_sum;
logic [3:0] card_value;                   
logic next_win, next_lose;

always_comb begin
    if (card < 4'd10)
        card_value = card;
    else if(card < 4'he)
        card_value = 4'd10;
    else
        card_value = 4'b0;
end

always_comb begin
    next_win = 1'b0;
    next_lose = 1'b0; 

    if(!in_valid || win || lose)
        current_sum = 0;
    else
     	current_sum = sum + card_value;

    if((current_sum > 5'd16) && (current_sum < 5'd22))
        next_win = 1'b1;

    if(current_sum > 5'd21)
        next_lose = 1'b1;
end

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        win <= 1'b0;
        lose <= 1'b0;
        sum <= 5'b0;
    end
    else begin
		sum <= current_sum;
        win <= next_win;
        lose <= next_lose;
    end
end

endmodule