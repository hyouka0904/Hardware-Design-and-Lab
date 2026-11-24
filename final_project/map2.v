module map2(
    input clk, 
    input rst, 
    input en,
    input paused,
    input invincible,
    input wire [9:0] vga_h, 
    input wire [9:0] vga_v,  
    input [3:0] player_state, player2_state,
    input [1:0] player_jump, player2_jump,
    output wire [16:0] addr, 
    output wire clear,
    output wire fail,
    output wire p1_collision, p2_collision,
    output wire p1_land, p2_land,
    output wire should_down, should_down2,
    output wire button1_tounch
);
    parameter stactic = 4'd6, right = 4'd7, left = 4'd8, up = 4'd9;
    wire collision_with_player1, collision_with_player2;
    //wire p1_collision;
    //reg [1:0] player_jump;
    //reg [3:0] player_state;
    reg [29:0] cnt_player_jump = 0;

    wire [9:0] h, v;
    assign h = vga_h >> 1;
    assign v = vga_v >> 1;

    wire dimond1_touch, button2_tounch, dimond2_touch;
    wire p1_on_mech1;
    reg dimond1_flag = 1, botton1_flag = 1, botton2_flag = 1, dimond2_flag = 1;
    wire [9:0] player_horizontal_displacement, player_vertical_displacement;
    wire [9:0] player2_h_dis, player2_v_dis;
    reg [9:0] mech_1_v_displacement = 0, mech_2_h_displacement = 0;
    reg [24:0] mech_cnt_v = 25'b0, mech_2_cnt_h = 0;

    assign clear = (player_state == stactic && (13+player_horizontal_displacement)>=250 && (28+player_horizontal_displacement) <273 && (230-player_vertical_displacement) == 48) &&
    (player2_state == stactic && (13+player2_h_dis)>=280 && (27+player2_h_dis) <301 && (230-player2_v_dis) == 48);

    assign p1_on_mech1 = ((25+player_horizontal_displacement) < 50 && (230-player_vertical_displacement)==(139+mech_1_v_displacement));

    /*assign dimond1_touch = (dimond1_flag) ? (
        (22+player_horizontal_displacement == 197 && player_state == right && player_vertical_displacement >= 0 && player_vertical_displacement < 3) ? 1 : 0
    ) : (
        1
    );

    assign dimond2_touch = (dimond2_flag) ? (
        (10+player2_h_dis <= 32 && player2_state == left && (230-player2_v_dis) >= 65 && (230-player2_v_dis) <= 72) ? 1 : 0
    ) : (
        1
    );*/

    assign fail = !invincible && (
            (player_horizontal_displacement >= 201 && player_horizontal_displacement <=208 && (230-player_vertical_displacement)==230) ||
            (player2_h_dis >= 140 && player2_h_dis <= 143 && (230-player2_v_dis) == 230) ||
            (player_horizontal_displacement >= 28 && player_horizontal_displacement <=49 && (230-player_vertical_displacement)==182) ||
            (player2_h_dis >= 28 && player2_h_dis <= 49 && (230-player2_v_dis) == 182)
    );
    


    wire p1_wall, p2_wall;
    campaign_contacts player1_contacts(
        .x(player_horizontal_displacement), .height(player_vertical_displacement),
        .state(player_state), .jump(player_jump),
        .button1(button1_tounch), .button2(button2_tounch),
        .hit_wall(p1_wall), .hit_ceiling(p1_collision),
        .landed(p1_land), .should_drop(should_down)
    );
    campaign_contacts player2_contacts(
        .x(player2_h_dis), .height(player2_v_dis),
        .state(player2_state), .jump(player2_jump),
        .button1(button1_tounch), .button2(button2_tounch),
        .hit_wall(p2_wall), .hit_ceiling(p2_collision),
        .landed(p2_land), .should_drop(should_down2)
    );

    assign button1_tounch = (botton1_flag) ? (
        (((22+player_horizontal_displacement) >=100 && (8+player_horizontal_displacement) < 105 && (230-player_vertical_displacement) <= 182 && (230-player_vertical_displacement) >=180 ) ||
    ((30+player2_h_dis) >= 100 && (10+player2_h_dis) < 105 && (230-player2_v_dis) <= 182 && (230-player2_v_dis) >= 180)) ? 1 : 0
    ) : (
        1
    ) ;

    assign button2_tounch = (botton2_flag) ? (
        (((22+player_horizontal_displacement) >= 244 && (8+player_horizontal_displacement) <250 && (200-player_vertical_displacement) >= 104 && (200-player_vertical_displacement) <= 106) || 
        ((30+player2_h_dis) >= 244 && (10+player2_h_dis) < 250 && (200-player2_v_dis) >= 104 && (200-player2_v_dis) <= 106)) ? 1 : 0
    ) : (
        1
    );

    assign addr = (h>=0 && h <320 && v>=0 && v < 10) ? (   // ceiling
        h+(v+220)*320
    ) : (
        (h >= 164 && h < 176 && v >= 230 && v < 236) ? (   //red river
            19521
        ) : (
            (h >= 224 && h < 236 && v >= 230 && v < 236) ? (  // blue river
                22470
            ) : (
                (h >= 50 && h < 70 && v >= 182 && v < 188) ? (  // green river
                    60910
                ) : (
                    (h >=0 && h < 320 && v >= 230 && v < 240) ? (   // floor
                        h + (v-230+220)*320
                    ) : (
                        (h >=0 && h<10 && v>=10 && v<230) ? (    // left boundary
                            (h+305) + v*320
                        ) : (
                            (h>=310 && h<320 && v>=10 && v<230) ? (  // right boundary
                                (h-310+305) + v*320
                            ) : (
                                (h>=10 && h<240 && v >=182 && v<190) ? (    // wall 1
                                    (h-10+50) + (v-182+215)*320
                                ) : (
                                    (h>=90 && h<310 && v>=139 && v<147) ? (   // wall 2
                                        (h-90) + (v-139+220)*320
                                    ) : (
                                        (h>=85 && h < 270 && v >= 96 && v<104) ? (  // wall 3
                                            (h-85) + (v-96+220)*320
                                        ) : (
                                                (h>=110 && h<310 && v>=48 && v<56) ? (  // wall 6
                                                    (h-110) + (v-48+220)*320
                                                ) : (
                                                    (h>=250 && h<273 && v>=19 && v<48) ? (   // red door
                                                        (h-250) + (v-19+89)*320
                                                    ) : (
                                                        (h>=280 && h<301 && v>=19 && v<48) ? (  // blue door
                                                            (h-280+32) + (v-19+89)*320
                                                        ) : (
                                                            (h >= 275 && h < 310 && v >= 210 && v < 230) ? (  // wall 7
                                                                (h-290) + (v-215+218)*320
                                                            ) : (
                                                                (h>=0 && h<65 && v>=71 && v<81) ? (    // wall 8
                                                                    (h+160)+(v+158)*320
                                                                ) : (
                                                                            (h>=100 && h<105 && v>=177 && v<182) ? (     //button 1
                                                                                (button1_tounch) ? (
                                                                                    60800
                                                                                ) : (
                                                                                    540
                                                                                )
                                                                            ) : (
                                                                                (h>=10 && h<40 && v>=(139+mech_1_v_displacement) && v<(147+mech_1_v_displacement)) ? (   //mech 1
                                                                                    h + (v+88-mech_1_v_displacement)*320
                                                                                ) : (
                                                                                    (h>=244 && h<250 && v>=104 && v<=110) ? (
                                                                                        (button2_tounch) ? 60800 : 540
                                                                                    ) : (
                                                                                        (h>=(310-mech_2_h_displacement) && h<(325-mech_2_h_displacement) && v>=124 && v<139) ? (
                                                                                            (button2_tounch) ? (
                                                                                                (310-mech_2_h_displacement) + (v+100)*320
                                                                                            ) : (
                                                                                                12900
                                                                                            )
                                                                                        ) : (
                                                                                            (player_state == right) ? (
                                                                                                ((h >= (8+player_horizontal_displacement)) && (h < (22+player_horizontal_displacement)) && (v >= (200-player_vertical_displacement)) && (v < (230-player_vertical_displacement))) ? (
                                                                                                    (h+63-player_horizontal_displacement) + (v+player_vertical_displacement-200) * 320
                                                                                                ) : (
                                                                                                    (player2_state == stactic) ? (
                                                                                                        (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                            (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                        ) : (
                                                                                                            12900
                                                                                                        )
                                                                                                    ) : (
                                                                                                        (player2_state == left) ? (
                                                                                                            (h>=(10+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                (h+151-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                            ) : (
                                                                                                                12900
                                                                                                            )
                                                                                                        ) : (
                                                                                                            (player2_state == right) ? (
                                                                                                                (h>=(1+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                    (h+175-player2_h_dis) + (v+player2_v_dis-142) * 320
                                                                                                                ) : (
                                                                                                                    12900
                                                                                                                )
                                                                                                            ) : (
                                                                                                                (player2_state == up) ? (
                                                                                                                    (player2_jump == 1) ? (
                                                                                                                        (h>=(9+player2_h_dis) && h<(25+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                            (h+175-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                        ) : (
                                                                                                                            12900
                                                                                                                        )
                                                                                                                    ) : (
                                                                                                                        (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                            (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                        ) : (
                                                                                                                            12900
                                                                                                                        )                                                                                                  
                                                                                                                    )
                                                                                                                ) : (
                                                                                                                    12900
                                                                                                                )
                                                                                                            )
                                                                                                        )
                                                                                                    )
                                                                                                )
                                                                                            ) : (
                                                                                                (player_state == stactic) ? (
                                                                                                    ((h >= (13+player_horizontal_displacement)) && (h < (28+player_horizontal_displacement)) && (v >= (200-player_vertical_displacement)) && (v < (230-player_vertical_displacement))) ? (
                                                                                                        (h+40-player_horizontal_displacement) + (v+player_vertical_displacement-200) * 320
                                                                                                    ) : (
                                                                                                        (player2_state == stactic) ? (
                                                                                                            (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                            ) : (
                                                                                                                12900
                                                                                                            )
                                                                                                        ) : (
                                                                                                            (player2_state == left) ? (
                                                                                                                (h>=(10+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                    (h+151-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                ) : (
                                                                                                                    12900
                                                                                                                )
                                                                                                            ) : (
                                                                                                                (player2_state == right) ? (
                                                                                                                    (h>=(1+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                        (h+175-player2_h_dis) + (v+player2_v_dis-142) * 320
                                                                                                                    ) : (
                                                                                                                        12900
                                                                                                                    )
                                                                                                                ) : (
                                                                                                                    (player2_state == up) ? (
                                                                                                                        (player2_jump == 1) ? (
                                                                                                                            (h>=(9+player2_h_dis) && h<(25+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                                (h+175-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                            ) : (
                                                                                                                                12900
                                                                                                                            )
                                                                                                                        ) : (
                                                                                                                            (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                                (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                            ) : (
                                                                                                                                12900
                                                                                                                            )                                                                                                  
                                                                                                                        )
                                                                                                                    ) : (
                                                                                                                        12900
                                                                                                                    )
                                                                                                                )
                                                                                                            )
                                                                                                        )
                                                                                                    )
                                                                                                ) : (
                                                                                                    (player_state == left) ? (
                                                                                                        ((h >= (8+player_horizontal_displacement)) && (h < (22+player_horizontal_displacement)) && (v >= (200-player_vertical_displacement)) && (v < (230-player_vertical_displacement))) ? (
                                                                                                            (h+78-player_horizontal_displacement) + (v+player_vertical_displacement-200) * 320
                                                                                                        ) : (
                                                                                                            (player2_state == stactic) ? (
                                                                                                                (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                    (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                ) : (
                                                                                                                    12900
                                                                                                                )
                                                                                                            ) : (
                                                                                                                (player2_state == left) ? (
                                                                                                                    (h>=(10+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                        (h+151-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                    ) : (
                                                                                                                        12900
                                                                                                                    )
                                                                                                                ) : (
                                                                                                                    (player2_state == right) ? (
                                                                                                                        (h>=(1+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                            (h+175-player2_h_dis) + (v+player2_v_dis-142) * 320
                                                                                                                        ) : (
                                                                                                                            12900
                                                                                                                        )
                                                                                                                    ) : (
                                                                                                                        (player2_state == up) ? (
                                                                                                                            (player2_jump == 1) ? (
                                                                                                                                (h>=(9+player2_h_dis) && h<(25+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                                    (h+175-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                                ) : (
                                                                                                                                    12900
                                                                                                                                )
                                                                                                                            ) : (
                                                                                                                                (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                                    (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                                ) : (
                                                                                                                                    12900
                                                                                                                                )                                                                                                  
                                                                                                                            )
                                                                                                                        ) : (
                                                                                                                            12900
                                                                                                                        )
                                                                                                                    )
                                                                                                                )
                                                                                                            )
                                                                                                        )
                                                                                                    ) : (
                                                                                                        (player_state == up) ? (
                                                                                                            (player_jump == 1) ? (
                                                                                                                ((h >= (10+player_horizontal_displacement)) && (h < (25+player_horizontal_displacement)) && (v >= (199-player_vertical_displacement)) && (v < (227-player_vertical_displacement))) ? (
                                                                                                                    (h+43-player_horizontal_displacement) + (v+player_vertical_displacement-169) * 320
                                                                                                                ) : (   
                                                                                                                    (player2_state == stactic) ? (
                                                                                                                        (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                            (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                        ) : (
                                                                                                                            12900
                                                                                                                        )
                                                                                                                    ) : (
                                                                                                                        (player2_state == left) ? (
                                                                                                                            (h>=(10+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                                (h+151-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                            ) : (
                                                                                                                                12900
                                                                                                                            )
                                                                                                                        ) : (
                                                                                                                            (player2_state == right) ? (
                                                                                                                                (h>=(1+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                                    (h+175-player2_h_dis) + (v+player2_v_dis-142) * 320
                                                                                                                                ) : (
                                                                                                                                    12900
                                                                                                                                )
                                                                                                                            ) : (
                                                                                                                                (player2_state == up) ? (
                                                                                                                                    (player2_jump == 1) ? (
                                                                                                                                        (h>=(9+player2_h_dis) && h<(25+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                                            (h+175-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                                        ) : (
                                                                                                                                            12900
                                                                                                                                        )
                                                                                                                                    ) : (
                                                                                                                                        (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                                            (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                                        ) : (
                                                                                                                                            12900
                                                                                                                                        )                                                                                                  
                                                                                                                                    )
                                                                                                                                ) : (
                                                                                                                                    12900
                                                                                                                                )
                                                                                                                            )
                                                                                                                        )
                                                                                                                    )
                                                                                                                )
                                                                                                            ) : (
                                                                                                                ((h >= (10+player_horizontal_displacement)) && (h < (25+player_horizontal_displacement)) && (v >= (200-player_vertical_displacement)) && (v < (230-player_vertical_displacement))) ? (
                                                                                                                    (h+43-player_horizontal_displacement) + (v+player_vertical_displacement-200) * 320
                                                                                                                ) : (   
                                                                                                                    (player2_state == stactic) ? (
                                                                                                                        (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                            (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                        ) : (
                                                                                                                            12900
                                                                                                                        )
                                                                                                                    ) : (
                                                                                                                        (player2_state == left) ? (
                                                                                                                            (h>=(10+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                                (h+151-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                            ) : (
                                                                                                                                12900
                                                                                                                            )
                                                                                                                        ) : (
                                                                                                                            (player2_state == right) ? (
                                                                                                                                (h>=(1+player2_h_dis) && h<(33+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                                    (h+175-player2_h_dis) + (v+player2_v_dis-142) * 320
                                                                                                                                ) : (
                                                                                                                                    12900
                                                                                                                                )
                                                                                                                            ) : (
                                                                                                                                (player2_state == up) ? (
                                                                                                                                    (player2_jump == 1) ? (
                                                                                                                                        (h>=(9+player2_h_dis) && h<(25+player2_h_dis) && v>=(200-player2_v_dis) && v<(229-player2_v_dis)) ? (
                                                                                                                                            (h+175-player2_h_dis) + (v+player2_v_dis-110) * 320
                                                                                                                                        ) : (
                                                                                                                                            12900
                                                                                                                                        )
                                                                                                                                    ) : (
                                                                                                                                        (h>=(13+player2_h_dis) && h<(27+player2_h_dis) && v>=(200-player2_v_dis) && v<(230-player2_v_dis)) ? (
                                                                                                                                            (h+148-player2_h_dis) + (v+player2_v_dis-141) * 320
                                                                                                                                        ) : (
                                                                                                                                            12900
                                                                                                                                        )                                                                                                  
                                                                                                                                    )
                                                                                                                                ) : (
                                                                                                                                    12900
                                                                                                                                )
                                                                                                                            )
                                                                                                                        )
                                                                                                                    )
                                                                                                                )
                                                                                                            )
                                                                                                        ) : (
                                                                                                            12900
                                                                                                        )
                                                                                                    )
                                                                                                )
                                                                                            )        
                                                                                        )
                                                                                    )                                                                          
                                                                                )
                                                                            )
                                                                        
                                                                    
                                                                )                                               
                                                            )
                                                        )
                                                    )
                                                )
                                            
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    );

    always @(posedge clk) begin
        if(rst || !en) begin
            dimond1_flag <= 1;
        end else if (!paused) begin
            if(dimond1_flag && dimond1_touch) dimond1_flag <= 0;
            else dimond1_flag <= dimond1_flag;
        end
    end

    always @(posedge clk) begin
        if(rst || !en) begin
            dimond2_flag <= 1;
        end else if (!paused) begin
            if(dimond2_flag && dimond2_touch) dimond2_flag <= 0;
            else dimond2_flag <= dimond2_flag;
        end
    end

    always @(posedge clk) begin
        if(rst || !en) begin
            botton1_flag <= 1;
        end else if (!paused) begin
            if(botton1_flag && button1_tounch) botton1_flag <= 0;
            else botton1_flag <= botton1_flag;
        end
    end

    always @(posedge clk) begin
        if(rst || !en) begin
            botton2_flag <= 1;
        end else if (!paused) begin
            if(botton2_flag && button2_tounch) botton2_flag <= 0;
            else botton2_flag <= botton2_flag;
        end
    end

    always @(posedge clk) begin
        if(rst || !en) begin
            mech_1_v_displacement <= 0;
            mech_cnt_v <= 0;
        end else if (!paused) begin
            if(button1_tounch) begin
                if(mech_cnt_v < 25'd2000000) begin
                    mech_cnt_v <= mech_cnt_v + 1;
                    mech_1_v_displacement <= mech_1_v_displacement;
                end
                else begin
                    if(mech_1_v_displacement < 22) mech_1_v_displacement <= mech_1_v_displacement + 1;
                    else mech_1_v_displacement <= mech_1_v_displacement;
                    mech_cnt_v <= 0;
                end
            end else begin
                    mech_1_v_displacement <= mech_1_v_displacement;
                    mech_cnt_v <= 0;         
            end
        end
    end

    always @(posedge clk) begin
        if(rst || !en) begin
            mech_2_h_displacement <= 0;
            mech_2_cnt_h <= 0;
        end else if (!paused) begin
            if(button2_tounch) begin
                if(mech_2_cnt_h < 25'd2000000) begin
                    mech_2_cnt_h <= mech_2_cnt_h + 1;
                    mech_2_h_displacement <= mech_2_h_displacement;
                end
                else begin
                    if(mech_2_h_displacement < 15) mech_2_h_displacement <= mech_2_h_displacement + 1;
                    else mech_2_h_displacement <= mech_2_h_displacement;
                    mech_2_cnt_h <= 0;
                end
            end else begin
                    mech_2_h_displacement <= mech_2_h_displacement;
                    mech_2_cnt_h <= 0;         
            end
        end
    end

    player_position player1_position(
        .clk(clk), .reset_position(rst || !en), .paused(paused),
        .state(player_state), .jump(player_jump), .collision(p1_wall),
        .horizontal(player_horizontal_displacement), .vertical(player_vertical_displacement)
    );

    player_position player2_position(
        .clk(clk), .reset_position(rst || !en), .paused(paused),
        .state(player2_state), .jump(player2_jump), .collision(p2_wall),
        .horizontal(player2_h_dis), .vertical(player2_v_dis)
    );
endmodule
