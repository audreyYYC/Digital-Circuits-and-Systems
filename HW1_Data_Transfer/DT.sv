module DT(
    // Input signals
	in_n0,
	in_n1,
	in_n2,
	in_n3,
    // Output signals
    out_n0,
    out_n1,
    out_n2,
    out_n3,
    out_n4,
	ack_n0,
	ack_n1,
	ack_n2,
	ack_n3
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [19:0] in_n0, in_n1, in_n2, in_n3;
output logic [17:0] out_n0, out_n1, out_n2, out_n3, out_n4;
output logic ack_n0, ack_n1, ack_n2, ack_n3;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_comb begin
    {out_n0, out_n1, out_n2, out_n3, out_n4} = '0;
    {ack_n0, ack_n1, ack_n2, ack_n3} = '0;

    //out_n0
    if(in_n0[19] & in_n0[18:16] == 3'b0) begin
        out_n0[15:0] = in_n0[15:0];
        ack_n0 = 1;
        out_n0[16] = 1;
    end
    else if(in_n1[19] & in_n1[18:16] == 3'b0) begin
        out_n0[15:0] = in_n1[15:0];
        ack_n1 = 1;
        out_n0[16] = 1;
    end
    else if(in_n2[19] & in_n2[18:16] == 3'b0)begin
        out_n0[15:0] = in_n2[15:0];
        ack_n2 = 1;
        out_n0[16] = 1;
    end
    else if(in_n3[19] & in_n3[18:16] == 3'b0)begin
        out_n0[15:0] = in_n3[15:0];
        ack_n3 = 1;
        out_n0[16] = 1;
    end
    if( (in_n0[19] & in_n0[18:16] == 3'b0 & in_n1[19] & in_n1[18:16] == 3'b0) | 
        (in_n0[19] & in_n0[18:16] == 3'b0 & in_n2[19] & in_n2[18:16] == 3'b0) |  
        (in_n0[19] & in_n0[18:16] == 3'b0 & in_n3[19] & in_n3[18:16] == 3'b0) | 
        (in_n1[19] & in_n1[18:16] == 3'b0 & in_n2[19] & in_n2[18:16] == 3'b0) | 
        (in_n1[19] & in_n1[18:16] == 3'b0 & in_n3[19] & in_n3[18:16] == 3'b0) | 
        (in_n2[19] & in_n2[18:16] == 3'b0 & in_n3[19] & in_n3[18:16] == 3'b0) )
        out_n0[17:16] = 2'b10;

    //out_n1
    if(in_n0[19] & in_n0[17:16] == 2'b1) begin
        out_n1[15:0] = in_n0[15:0];
        ack_n0 = 1;
        out_n1[16] = 1;
    end
    else if(in_n1[19] & in_n1[17:16] == 2'b1)begin
        out_n1[15:0] = in_n1[15:0];
        ack_n1 = 1;
        out_n1[16] = 1;
    end
    else if(in_n2[19] & in_n2[17:16] == 2'b1)begin
        out_n1[15:0] = in_n2[15:0];
        ack_n2 = 1;
        out_n1[16] = 1;
    end
    else if(in_n3[19] & in_n3[17:16] == 2'b1)begin
        out_n1[15:0] = in_n3[15:0];
        ack_n3 = 1;
        out_n1[16] = 1;
    end
    if( (in_n0[19] & in_n0[17:16] == 2'b1 & in_n1[19] & in_n1[17:16] == 2'b1) | 
        (in_n0[19] & in_n0[17:16] == 2'b1 & in_n2[19] & in_n2[17:16] == 2'b1) |  
        (in_n0[19] & in_n0[17:16] == 2'b1 & in_n3[19] & in_n3[17:16] == 2'b1) | 
        (in_n1[19] & in_n1[17:16] == 2'b1 & in_n2[19] & in_n2[17:16] == 2'b1) | 
        (in_n1[19] & in_n1[17:16] == 2'b1 & in_n3[19] & in_n3[17:16] == 2'b1) | 
        (in_n2[19] & in_n2[17:16] == 2'b1 & in_n3[19] & in_n3[17:16] == 2'b1) )
        out_n1[17:16] = 2'b10;

     //out_n2
    if(in_n0[19] & in_n0[18:16] == 3'd2)begin
        out_n2[15:0] = in_n0[15:0];
        ack_n0 = 1;
        out_n2[16] = 1;
    end
    else if(in_n1[19] & in_n1[18:16] == 3'd2)begin
        out_n2[15:0] = in_n1[15:0];
        ack_n1 = 1;
        out_n2[16] = 1;
    end
    else if(in_n2[19] & in_n2[18:16] == 3'd2)begin
        out_n2[15:0] = in_n2[15:0];
        ack_n2 = 1;
        out_n2[16] = 1;
    end
    else if(in_n3[19] & in_n3[18:16] == 3'd2)begin
        out_n2[15:0] = in_n3[15:0];
        ack_n3 = 1;
        out_n2[16] = 1;
    end
    if( (in_n0[19] & in_n0[18:16] == 3'd2 & in_n1[19] & in_n1[18:16] == 3'd2) | 
        (in_n0[19] & in_n0[18:16] == 3'd2 & in_n2[19] & in_n2[18:16] == 3'd2) |  
        (in_n0[19] & in_n0[18:16] == 3'd2 & in_n3[19] & in_n3[18:16] == 3'd2) | 
        (in_n1[19] & in_n1[18:16] == 3'd2 & in_n2[19] & in_n2[18:16] == 3'd2) | 
        (in_n1[19] & in_n1[18:16] == 3'd2 & in_n3[19] & in_n3[18:16] == 3'd2) | 
        (in_n2[19] & in_n2[18:16] == 3'd2 & in_n3[19] & in_n3[18:16] == 3'd2) )
        out_n2[17:16] = 2'b10;

    //out_n3
    if(in_n0[19] & in_n0[17:16] == 2'b11) begin
        out_n3[15:0] = in_n0[15:0];
        ack_n0 = 1;
        out_n3[16] = 1;
    end
    else if(in_n1[19] & in_n1[17:16] == 2'b11)begin
        out_n3[15:0] = in_n1[15:0];
        ack_n1 = 1;
        out_n3[16] = 1;
    end
    else if(in_n2[19] & in_n2[17:16] == 2'b11)begin
        out_n3[15:0] = in_n2[15:0];
        ack_n2 = 1;
        out_n3[16] = 1;
    end
    else if(in_n3[19] & in_n3[17:16] == 2'b11)begin
        out_n3[15:0] = in_n3[15:0];
        ack_n3 = 1;
        out_n3[16] = 1;
    end
    if( (in_n0[19] & in_n0[17:16] == 2'b11 & in_n1[19] & in_n1[17:16] == 2'b11) | 
        (in_n0[19] & in_n0[17:16] == 2'b11 & in_n2[19] & in_n2[17:16] == 2'b11) |  
        (in_n0[19] & in_n0[17:16] == 2'b11 & in_n3[19] & in_n3[17:16] == 2'b11) | 
        (in_n1[19] & in_n1[17:16] == 2'b11 & in_n2[19] & in_n2[17:16] == 2'b11) | 
        (in_n1[19] & in_n1[17:16] == 2'b11 & in_n3[19] & in_n3[17:16] == 2'b11) | 
        (in_n2[19] & in_n2[17:16] == 2'b11 & in_n3[19] & in_n3[17:16] == 2'b11) )
        out_n3[17:16] = 2'b10;

    //out_n4
    if(in_n0[19] & in_n0[18]) begin
        out_n4[15:0] = in_n0[15:0];
        ack_n0 = 1;
        out_n4[16] = 1;
    end
    else if(in_n1[19] & in_n1[18])begin
        out_n4[15:0] = in_n1[15:0];
        ack_n1 = 1;
        out_n4[16] = 1;
    end
    else if(in_n2[19] & in_n2[18])begin
        out_n4[15:0] = in_n2[15:0];
        ack_n2 = 1;
        out_n4[16] = 1;
    end
    else if(in_n3[19] & in_n3[18])begin
        out_n4[15:0] = in_n3[15:0];
        ack_n3 = 1;
        out_n4[16] = 1;
    end
    if( (in_n0[19] & in_n0[18] & in_n1[19] & in_n1[18]) | 
        (in_n0[19] & in_n0[18] & in_n2[19] & in_n2[18]) |  
        (in_n0[19] & in_n0[18] & in_n3[19] & in_n3[18]) | 
        (in_n1[19] & in_n1[18] & in_n2[19] & in_n2[18]) | 
        (in_n1[19] & in_n1[18] & in_n3[19] & in_n3[18]) | 
        (in_n2[19] & in_n2[18] & in_n3[19] & in_n3[18]) )
        out_n4[17:16] = 2'b10;
end
endmodule