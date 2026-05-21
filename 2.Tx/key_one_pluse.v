//================================
//Debounce button for KEY (i_send)
//================================
module key_one_pluse (
	input clk,
	input key_n, //Active LOW
	output pluse
);

	reg key_d;
	
	always@(posedge clk) begin
		key_d <= key_n;
	end
	
	assign pluse = (~key_n) & key_d;
endmodule