`define silence   32'd50000000
`define low_low_do   32'd66
`define low_low_re   32'd74
`define low_low_mi   32'd83
`define low_low_fa   32'd87
`define low_low_so   32'd98
`define low_low_la   32'd110
`define low_low_si   32'd124
`define low_do   32'd131
`define low_re   32'd147
`define low_mi   32'd165
`define low_fa   32'd174
`define low_so   32'd196
`define low_la   32'd220
`define low_si   32'd247
`define do   32'd262   
`define re   32'd294
`define mi   32'd330
`define fa   32'd349
`define so   32'd392   
`define la   32'd440
`define si   32'd494   
`define high_do  32'd524   
`define high_re  32'd588   
`define high_mi  32'd660   
`define high_fa  32'd698   
`define high_so  32'd784   
`define high_la  32'd880
`define high_si  32'd988
module Jingle_Bells (
	input [11:0] ibeatNum,
	input en,
	output reg [31:0] toneL,
    output reg [31:0] toneR
);
    always @* begin
        if(en == 1) begin
            case(ibeatNum)
                12'd0: toneR = `high_mi;      12'd1: toneR = `high_mi;      12'd2: toneR = `high_mi;      12'd3: toneR = `high_mi;      
                12'd4: toneR = `high_mi;      12'd5: toneR = `high_mi;      12'd6: toneR = `high_mi;      12'd7: toneR = `silence;
                12'd8: toneR = `high_mi;      12'd9: toneR = `high_mi;      12'd10: toneR = `high_mi;      12'd11: toneR = `high_mi;
                12'd12: toneR = `high_mi;      12'd13: toneR = `high_mi;      12'd14: toneR = `high_mi;      12'd15: toneR = `silence;
                12'd16: toneR = `high_mi;      12'd17: toneR = `high_mi;      12'd18: toneR = `high_mi;      12'd19: toneR = `high_mi;
                12'd20: toneR = `high_mi;      12'd21: toneR = `high_mi;      12'd22: toneR = `high_mi;      12'd23: toneR = `high_mi;
                12'd24: toneR = `high_mi;      12'd25: toneR = `high_mi;      12'd26: toneR = `high_mi;      12'd27: toneR = `high_mi;      
                12'd28: toneR = `high_mi;      12'd29: toneR = `high_mi;      12'd30: toneR = `high_mi;      12'd31: toneR = `silence;
                12'd32: toneR = `high_mi;      12'd33: toneR = `high_mi;      12'd34: toneR = `high_mi;      12'd35: toneR = `high_mi;
                12'd36: toneR = `high_mi;      12'd37: toneR = `high_mi;      12'd38: toneR = `high_mi;      12'd39: toneR = `silence;
                12'd40: toneR = `high_mi;      12'd41: toneR = `high_mi;      12'd42: toneR = `high_mi;      12'd43: toneR = `high_mi;
                12'd44: toneR = `high_mi;      12'd45: toneR = `high_mi;      12'd46: toneR = `high_mi;      12'd47: toneR = `silence;      
                12'd48: toneR = `high_mi;      12'd49: toneR = `high_mi;      12'd50: toneR = `high_mi;      12'd51: toneR = `high_mi;
                12'd52: toneR = `high_mi;      12'd53: toneR = `high_mi;      12'd54: toneR = `high_mi;      12'd55: toneR = `high_mi;
                12'd56: toneR = `high_mi;      12'd57: toneR = `high_mi;      12'd58: toneR = `high_mi;      12'd59: toneR = `high_mi;
                12'd60: toneR = `high_mi;      12'd61: toneR = `high_mi;      12'd62: toneR = `high_mi;      12'd63: toneR = `silence;      
                12'd64: toneR = `high_mi;      12'd65: toneR = `high_mi;      12'd66: toneR = `high_mi;      12'd67: toneR = `high_mi;
                12'd68: toneR = `high_mi;      12'd69: toneR = `high_mi;      12'd70: toneR = `high_mi;      12'd71: toneR = `high_mi;
                12'd72: toneR = `high_so;      12'd73: toneR = `high_so;      12'd74: toneR = `high_so;      12'd75: toneR = `high_so;
                12'd76: toneR = `high_so;      12'd77: toneR = `high_so;      12'd78: toneR = `high_so;      12'd79: toneR = `high_so;      
                12'd80: toneR = `high_do;      12'd81: toneR = `high_do;      12'd82: toneR = `high_do;      12'd83: toneR = `high_do;
                12'd84: toneR = `high_do;      12'd85: toneR = `high_do;      12'd86: toneR = `high_do;      12'd87: toneR = `high_do;
                12'd88: toneR = `high_re;      12'd89: toneR = `high_re;      12'd90: toneR = `high_re;      12'd91: toneR = `high_re;
                12'd92: toneR = `high_re;      12'd93: toneR = `high_re;      12'd94: toneR = `high_re;      12'd95: toneR = `high_re;      
                12'd96: toneR = `high_mi;      12'd97: toneR = `high_mi;      12'd98: toneR = `high_mi;      12'd99: toneR = `high_mi;
                12'd100: toneR = `high_mi;      12'd101: toneR = `high_mi;      12'd102: toneR = `high_mi;      12'd103: toneR = `high_mi;
                12'd104: toneR = `high_mi;      12'd105: toneR = `high_mi;      12'd106: toneR = `high_mi;      12'd107: toneR = `high_mi;
                12'd108: toneR = `high_mi;      12'd109: toneR = `high_mi;      12'd110: toneR = `high_mi;      12'd111: toneR = `high_mi;
                12'd112: toneR = `high_mi;      12'd113: toneR = `high_mi;      12'd114: toneR = `high_mi;      12'd115: toneR = `high_mi;
                12'd116: toneR = `high_mi;      12'd117: toneR = `high_mi;      12'd118: toneR = `high_mi;      12'd119: toneR = `high_mi;      
                12'd120: toneR = `high_mi;      12'd121: toneR = `high_mi;      12'd122: toneR = `high_mi;      12'd123: toneR = `high_mi;
                12'd124: toneR = `high_mi;      12'd125: toneR = `high_mi;      12'd126: toneR = `high_mi;      12'd127: toneR = `high_mi;
                12'd128: toneR = `high_fa;      12'd129: toneR = `high_fa;      12'd130: toneR = `high_fa;      12'd131: toneR = `high_fa;
                12'd132: toneR = `high_fa;      12'd133: toneR = `high_fa;      12'd134: toneR = `high_fa;      12'd135: toneR = `silence;
                12'd136: toneR = `high_fa;      12'd137: toneR = `high_fa;      12'd138: toneR = `high_fa;      12'd139: toneR = `high_fa;      
                12'd140: toneR = `high_fa;      12'd141: toneR = `high_fa;      12'd142: toneR = `high_fa;      12'd143: toneR = `silence;
                12'd144: toneR = `high_fa;      12'd145: toneR = `high_fa;      12'd146: toneR = `high_fa;      12'd147: toneR = `high_fa;
                12'd148: toneR = `high_fa;      12'd149: toneR = `high_fa;      12'd150: toneR = `high_fa;      12'd151: toneR = `high_fa;
                12'd152: toneR = `high_fa;      12'd153: toneR = `high_fa;      12'd154: toneR = `high_fa;      12'd155: toneR = `silence;      
                12'd156: toneR = `high_fa;      12'd157: toneR = `high_fa;      12'd158: toneR = `high_fa;      12'd159: toneR = `silence;
                12'd160: toneR = `high_fa;      12'd161: toneR = `high_fa;      12'd162: toneR = `high_fa;      12'd163: toneR = `high_fa;
                12'd164: toneR = `high_fa;      12'd165: toneR = `high_fa;      12'd166: toneR = `high_fa;      12'd167: toneR = `high_fa;
                12'd168: toneR = `high_mi;      12'd169: toneR = `high_mi;      12'd170: toneR = `high_mi;      12'd171: toneR = `high_mi;      
                12'd172: toneR = `high_mi;      12'd173: toneR = `high_mi;      12'd174: toneR = `high_mi;      12'd175: toneR = `silence;
                12'd176: toneR = `high_mi;      12'd177: toneR = `high_mi;      12'd178: toneR = `high_mi;      12'd179: toneR = `high_mi;
                12'd180: toneR = `high_mi;      12'd181: toneR = `high_mi;      12'd182: toneR = `high_mi;      12'd183: toneR = `high_mi;
                12'd184: toneR = `high_mi;      12'd185: toneR = `high_mi;      12'd186: toneR = `high_mi;      12'd187: toneR = `silence;      
                12'd188: toneR = `high_mi;      12'd189: toneR = `high_mi;      12'd190: toneR = `high_mi;      12'd191: toneR = `silence;
                12'd192: toneR = `high_mi;      12'd193: toneR = `high_mi;      12'd194: toneR = `high_mi;      12'd195: toneR = `high_mi;
                12'd196: toneR = `high_mi;      12'd197: toneR = `high_mi;      12'd198: toneR = `high_mi;      12'd199: toneR = `high_mi;
                12'd200: toneR = `high_re;      12'd201: toneR = `high_re;      12'd202: toneR = `high_re;      12'd203: toneR = `high_re;
                12'd204: toneR = `high_re;      12'd205: toneR = `high_re;      12'd206: toneR = `high_re;      12'd207: toneR = `silence;      
                12'd208: toneR = `high_re;      12'd209: toneR = `high_re;      12'd210: toneR = `high_re;      12'd211: toneR = `high_re;
                12'd212: toneR = `high_re;      12'd213: toneR = `high_re;      12'd214: toneR = `high_re;      12'd215: toneR = `high_re;
                12'd216: toneR = `high_mi;      12'd217: toneR = `high_mi;      12'd218: toneR = `high_mi;      12'd219: toneR = `high_mi;
                12'd220: toneR = `high_mi;      12'd221: toneR = `high_mi;      12'd222: toneR = `high_mi;      12'd223: toneR = `high_mi;
                12'd224: toneR = `high_re;      12'd225: toneR = `high_re;      12'd226: toneR = `high_re;      12'd227: toneR = `high_re;      
                12'd228: toneR = `high_re;      12'd229: toneR = `high_re;      12'd230: toneR = `high_re;      12'd231: toneR = `high_re;
                12'd232: toneR = `high_re;      12'd233: toneR = `high_re;      12'd234: toneR = `high_re;      12'd235: toneR = `high_re;
                12'd236: toneR = `high_re;      12'd237: toneR = `high_re;      12'd238: toneR = `high_re;      12'd239: toneR = `high_re;
                12'd240: toneR = `high_so;      12'd241: toneR = `high_so;      12'd242: toneR = `high_so;      12'd243: toneR = `high_so;
                12'd244: toneR = `high_so;      12'd245: toneR = `high_so;      12'd246: toneR = `high_so;      12'd247: toneR = `high_so;      
                12'd248: toneR = `high_so;      12'd249: toneR = `high_so;      12'd250: toneR = `high_so;      12'd251: toneR = `high_so;
                12'd252: toneR = `high_so;      12'd253: toneR = `high_so;      12'd254: toneR = `high_so;      12'd255: toneR = `high_so;
                12'd256: toneR = `high_mi;      12'd257: toneR = `high_mi;      12'd258: toneR = `high_mi;      12'd259: toneR = `high_mi;
                12'd260: toneR = `high_mi;      12'd261: toneR = `high_mi;      12'd262: toneR = `high_mi;      12'd263: toneR = `silence;      
                12'd264: toneR = `high_mi;      12'd265: toneR = `high_mi;      12'd266: toneR = `high_mi;      12'd267: toneR = `high_mi;
                12'd268: toneR = `high_mi;      12'd269: toneR = `high_mi;      12'd270: toneR = `high_mi;      12'd271: toneR = `silence;
                12'd272: toneR = `high_mi;      12'd273: toneR = `high_mi;      12'd274: toneR = `high_mi;      12'd275: toneR = `high_mi;
                12'd276: toneR = `high_mi;      12'd277: toneR = `high_mi;      12'd278: toneR = `high_mi;      12'd279: toneR = `high_mi;      
                12'd280: toneR = `high_mi;      12'd281: toneR = `high_mi;      12'd282: toneR = `high_mi;      12'd283: toneR = `high_mi;
                12'd284: toneR = `high_mi;      12'd285: toneR = `high_mi;      12'd286: toneR = `high_mi;      12'd287: toneR = `silence;
                12'd288: toneR = `high_mi;      12'd289: toneR = `high_mi;      12'd290: toneR = `high_mi;      12'd291: toneR = `high_mi;
                12'd292: toneR = `high_mi;      12'd293: toneR = `high_mi;      12'd294: toneR = `high_mi;      12'd295: toneR = `silence;      
                12'd296: toneR = `high_mi;      12'd297: toneR = `high_mi;      12'd298: toneR = `high_mi;      12'd299: toneR = `high_mi;
                12'd300: toneR = `high_mi;      12'd301: toneR = `high_mi;      12'd302: toneR = `high_mi;      12'd303: toneR = `silence;
                12'd304: toneR = `high_mi;      12'd305: toneR = `high_mi;      12'd306: toneR = `high_mi;      12'd307: toneR = `high_mi;
                12'd308: toneR = `high_mi;      12'd309: toneR = `high_mi;      12'd310: toneR = `high_mi;      12'd311: toneR = `high_mi;      
                12'd312: toneR = `high_mi;      12'd313: toneR = `high_mi;      12'd314: toneR = `high_mi;      12'd315: toneR = `high_mi;
                12'd316: toneR = `high_mi;      12'd317: toneR = `high_mi;      12'd318: toneR = `high_mi;      12'd319: toneR = `silence;
                12'd320: toneR = `high_mi;      12'd321: toneR = `high_mi;      12'd322: toneR = `high_mi;      12'd323: toneR = `high_mi;      
                12'd324: toneR = `high_mi;      12'd325: toneR = `high_mi;      12'd326: toneR = `high_mi;      12'd327: toneR = `high_mi;
                12'd328: toneR = `high_so;      12'd329: toneR = `high_so;      12'd330: toneR = `high_so;      12'd331: toneR = `high_so;
                12'd332: toneR = `high_so;      12'd333: toneR = `high_so;      12'd334: toneR = `high_so;      12'd335: toneR = `high_so;
                12'd336: toneR = `high_do;      12'd337: toneR = `high_do;      12'd338: toneR = `high_do;      12'd339: toneR = `high_do;      
                12'd340: toneR = `high_do;      12'd341: toneR = `high_do;      12'd342: toneR = `high_do;      12'd343: toneR = `high_do;
                12'd344: toneR = `high_re;      12'd345: toneR = `high_re;      12'd346: toneR = `high_re;      12'd347: toneR = `high_re;
                12'd348: toneR = `high_re;      12'd349: toneR = `high_re;      12'd350: toneR = `high_re;      12'd351: toneR = `high_re;
                12'd352: toneR = `high_mi;      12'd353: toneR = `high_mi;      12'd354: toneR = `high_mi;      12'd355: toneR = `high_mi;
                12'd356: toneR = `high_mi;      12'd357: toneR = `high_mi;      12'd358: toneR = `high_mi;      12'd359: toneR = `high_mi;      
                12'd360: toneR = `high_mi;      12'd361: toneR = `high_mi;      12'd362: toneR = `high_mi;      12'd363: toneR = `high_mi;
                12'd364: toneR = `high_mi;      12'd365: toneR = `high_mi;      12'd366: toneR = `high_mi;      12'd367: toneR = `high_mi;
                12'd368: toneR = `high_mi;      12'd369: toneR = `high_mi;      12'd370: toneR = `high_mi;      12'd371: toneR = `high_mi;
                12'd372: toneR = `high_mi;      12'd373: toneR = `high_mi;      12'd374: toneR = `high_mi;      12'd375: toneR = `high_mi;      
                12'd376: toneR = `high_mi;      12'd377: toneR = `high_mi;      12'd378: toneR = `high_mi;      12'd379: toneR = `high_mi;
                12'd380: toneR = `high_mi;      12'd381: toneR = `high_mi;      12'd382: toneR = `high_mi;      12'd383: toneR = `high_mi;
                12'd384: toneR = `high_fa;      12'd385: toneR = `high_fa;      12'd386: toneR = `high_fa;      12'd387: toneR = `high_fa;
                12'd388: toneR = `high_fa;      12'd389: toneR = `high_fa;      12'd390: toneR = `high_fa;      12'd391: toneR = `silence;      
                12'd392: toneR = `high_fa;      12'd393: toneR = `high_fa;      12'd394: toneR = `high_fa;      12'd395: toneR = `high_fa;
                12'd396: toneR = `high_fa;      12'd397: toneR = `high_fa;      12'd398: toneR = `high_fa;      12'd399: toneR = `silence;
                12'd400: toneR = `high_fa;      12'd401: toneR = `high_fa;      12'd402: toneR = `high_fa;      12'd403: toneR = `high_fa;
                12'd404: toneR = `high_fa;      12'd405: toneR = `high_fa;      12'd406: toneR = `high_fa;      12'd407: toneR = `high_fa;      
                12'd408: toneR = `high_fa;      12'd409: toneR = `high_fa;      12'd410: toneR = `high_fa;      12'd411: toneR = `silence;
                12'd412: toneR = `high_fa;      12'd413: toneR = `high_fa;      12'd414: toneR = `high_fa;      12'd415: toneR = `silence;
                12'd416: toneR = `high_fa;      12'd417: toneR = `high_fa;      12'd418: toneR = `high_fa;      12'd419: toneR = `high_fa;
                12'd420: toneR = `high_fa;      12'd421: toneR = `high_fa;      12'd422: toneR = `high_fa;      12'd423: toneR = `high_fa;
                12'd424: toneR = `high_mi;      12'd425: toneR = `high_mi;      12'd426: toneR = `high_mi;      12'd427: toneR = `high_mi;
                12'd428: toneR = `high_mi;      12'd429: toneR = `high_mi;      12'd430: toneR = `high_mi;      12'd431: toneR = `silence;      
                12'd432: toneR = `high_mi;      12'd433: toneR = `high_mi;      12'd434: toneR = `high_mi;      12'd435: toneR = `high_mi;
                12'd436: toneR = `high_mi;      12'd437: toneR = `high_mi;      12'd438: toneR = `high_mi;      12'd439: toneR = `high_mi;
                12'd440: toneR = `high_mi;      12'd441: toneR = `high_mi;      12'd442: toneR = `high_mi;      12'd443: toneR = `silence;
                12'd444: toneR = `high_mi;      12'd445: toneR = `high_mi;      12'd446: toneR = `high_mi;      12'd447: toneR = `high_mi;      
                12'd448: toneR = `high_so;      12'd449: toneR = `high_so;      12'd450: toneR = `high_so;      12'd451: toneR = `high_so;
                12'd452: toneR = `high_so;      12'd453: toneR = `high_so;      12'd454: toneR = `high_so;      12'd455: toneR = `silence;
                12'd456: toneR = `high_so;      12'd457: toneR = `high_so;      12'd458: toneR = `high_so;      12'd459: toneR = `high_so;
                12'd460: toneR = `high_so;      12'd461: toneR = `high_so;      12'd462: toneR = `high_so;      12'd463: toneR = `high_so;      
                12'd464: toneR = `high_fa;      12'd465: toneR = `high_fa;      12'd466: toneR = `high_fa;      12'd467: toneR = `high_fa;
                12'd468: toneR = `high_fa;      12'd469: toneR = `high_fa;      12'd470: toneR = `high_fa;      12'd471: toneR = `high_fa;
                12'd472: toneR = `high_re;      12'd473: toneR = `high_re;      12'd474: toneR = `high_re;      12'd475: toneR = `high_re;
                12'd476: toneR = `high_re;      12'd477: toneR = `high_re;      12'd478: toneR = `high_re;      12'd479: toneR = `high_re;      
                12'd480: toneR = `high_do;      12'd481: toneR = `high_do;      12'd482: toneR = `high_do;      12'd483: toneR = `high_do;
                12'd484: toneR = `high_do;      12'd485: toneR = `high_do;      12'd486: toneR = `high_do;      12'd487: toneR = `high_do;
                12'd488: toneR = `high_do;      12'd489: toneR = `high_do;      12'd490: toneR = `high_do;      12'd491: toneR = `high_do;
                12'd492: toneR = `high_do;      12'd493: toneR = `high_do;      12'd494: toneR = `high_do;      12'd495: toneR = `high_do;      
                12'd496: toneR = `high_do;      12'd497: toneR = `high_do;      12'd498: toneR = `high_do;      12'd499: toneR = `high_do;
                12'd500: toneR = `high_do;      12'd501: toneR = `high_do;      12'd502: toneR = `high_do;      12'd503: toneR = `high_do;
                12'd504: toneR = `high_do;      12'd505: toneR = `high_do;      12'd506: toneR = `high_do;      12'd507: toneR = `high_do;      
                12'd508: toneR = `high_do;      12'd509: toneR = `high_do;      12'd510: toneR = `high_do;      12'd511: toneR = `high_do;
                default: toneR = `silence;
            endcase
        end else begin
            toneR = `silence;
        end
    end

    always @* begin
        if(en == 1) begin
            case (ibeatNum)
                12'd0: toneL = `high_do;      12'd1: toneL = `high_do;      12'd2: toneL = `high_do;      12'd3: toneL = `high_do;      
                12'd4: toneL = `high_do;      12'd5: toneL = `high_do;      12'd6: toneL = `high_do;      12'd7: toneL = `high_do;
                12'd8: toneL = `high_do;      12'd9: toneL = `high_do;      12'd10: toneL = `high_do;      12'd11: toneL = `high_do;
                12'd12: toneL = `high_do;      12'd13: toneL = `high_do;      12'd14: toneL = `high_do;      12'd15: toneL = `high_do;
                12'd16: toneL = `so;      12'd17: toneL = `so;      12'd18: toneL = `so;      12'd19: toneL = `so;
                12'd20: toneL = `so;      12'd21: toneL = `so;      12'd22: toneL = `so;      12'd23: toneL = `so;
                12'd24: toneL = `so;      12'd25: toneL = `so;      12'd26: toneL = `so;      12'd27: toneL = `so;
                12'd28: toneL = `so;      12'd29: toneL = `so;      12'd30: toneL = `so;      12'd31: toneL = `so;
                12'd32: toneL = `high_do;      12'd33: toneL = `high_do;      12'd34: toneL = `high_do;      12'd35: toneL = `high_do;
                12'd36: toneL = `high_do;      12'd37: toneL = `high_do;      12'd38: toneL = `high_do;      12'd39: toneL = `high_do;
                12'd40: toneL = `high_do;      12'd41: toneL = `high_do;      12'd42: toneL = `high_do;      12'd43: toneL = `high_do;      
                12'd44: toneL = `high_do;      12'd45: toneL = `high_do;      12'd46: toneL = `high_do;      12'd47: toneL = `high_do;
                12'd48: toneL = `so;      12'd49: toneL = `so;      12'd50: toneL = `so;      12'd51: toneL = `so;
                12'd52: toneL = `so;      12'd53: toneL = `so;      12'd54: toneL = `so;      12'd55: toneL = `so;
                12'd56: toneL = `so;      12'd57: toneL = `so;      12'd58: toneL = `so;      12'd59: toneL = `so;
                12'd60: toneL = `so;      12'd61: toneL = `so;      12'd62: toneL = `so;      12'd63: toneL = `so;      
                12'd64: toneL = `high_do;      12'd65: toneL = `high_do;      12'd66: toneL = `high_do;      12'd67: toneL = `high_do;
                12'd68: toneL = `high_do;      12'd69: toneL = `high_do;      12'd70: toneL = `high_do;      12'd71: toneL = `high_do;      
                12'd72: toneL = `high_do;      12'd73: toneL = `high_do;      12'd74: toneL = `high_do;      12'd75: toneL = `high_do;
                12'd76: toneL = `high_do;      12'd77: toneL = `high_do;      12'd78: toneL = `high_do;      12'd79: toneL = `high_do;      
                12'd80: toneL = `so;      12'd81: toneL = `so;      12'd82: toneL = `so;      12'd83: toneL = `so;      
                12'd84: toneL = `so;      12'd85: toneL = `so;      12'd86: toneL = `so;      12'd87: toneL = `so;      
                12'd88: toneL = `so;      12'd89: toneL = `so;      12'd90: toneL = `so;      12'd91: toneL = `so;
                12'd92: toneL = `so;      12'd93: toneL = `so;      12'd94: toneL = `so;      12'd95: toneL = `so;
                12'd96: toneL = `high_do;      12'd97: toneL = `high_do;      12'd98: toneL = `high_do;      12'd99: toneL = `high_do;      
                12'd100: toneL = `high_do;      12'd101: toneL = `high_do;      12'd102: toneL = `high_do;      12'd103: toneL = `high_do;
                12'd104: toneL = `so;      12'd105: toneL = `so;      12'd106: toneL = `so;      12'd107: toneL = `so;
                12'd108: toneL = `so;      12'd109: toneL = `so;      12'd110: toneL = `so;      12'd111: toneL = `so;      
                12'd112: toneL = `la;      12'd113: toneL = `la;      12'd114: toneL = `la;      12'd115: toneL = `la;
                12'd116: toneL = `la;      12'd117: toneL = `la;      12'd118: toneL = `la;      12'd119: toneL = `la;
                12'd120: toneL = `si;      12'd121: toneL = `si;      12'd122: toneL = `si;      12'd123: toneL = `si;      
                12'd124: toneL = `si;      12'd125: toneL = `si;      12'd126: toneL = `si;      12'd127: toneL = `si;
                12'd128: toneL = `high_re;      12'd129: toneL = `high_re;      12'd130: toneL = `high_re;      12'd131: toneL = `high_re;
                12'd132: toneL = `high_re;      12'd133: toneL = `high_re;      12'd134: toneL = `high_re;      12'd135: toneL = `high_re;
                12'd136: toneL = `high_re;      12'd137: toneL = `high_re;      12'd138: toneL = `high_re;      12'd139: toneL = `high_re;      
                12'd140: toneL = `high_re;      12'd141: toneL = `high_re;      12'd142: toneL = `high_re;      12'd143: toneL = `high_re;
                12'd144: toneL = `fa;      12'd145: toneL = `fa;      12'd146: toneL = `fa;      12'd147: toneL = `fa;
                12'd148: toneL = `fa;      12'd149: toneL = `fa;      12'd150: toneL = `fa;      12'd151: toneL = `fa;      
                12'd152: toneL = `fa;      12'd153: toneL = `fa;      12'd154: toneL = `fa;      12'd155: toneL = `fa;
                12'd156: toneL = `fa;      12'd157: toneL = `fa;      12'd158: toneL = `fa;      12'd159: toneL = `fa;
                12'd160: toneL = `high_do;      12'd161: toneL = `high_do;      12'd162: toneL = `high_do;      12'd163: toneL = `high_do;
                12'd164: toneL = `high_do;      12'd165: toneL = `high_do;      12'd166: toneL = `high_do;      12'd167: toneL = `high_do;      
                12'd168: toneL = `high_do;      12'd169: toneL = `high_do;      12'd170: toneL = `high_do;      12'd171: toneL = `high_do;
                12'd172: toneL = `high_do;      12'd173: toneL = `high_do;      12'd174: toneL = `high_do;      12'd175: toneL = `high_do;
                12'd176: toneL = `mi;      12'd177: toneL = `mi;      12'd178: toneL = `mi;      12'd179: toneL = `mi;
                12'd180: toneL = `mi;      12'd181: toneL = `mi;      12'd182: toneL = `mi;      12'd183: toneL = `mi;
                12'd184: toneL = `mi;      12'd185: toneL = `mi;      12'd186: toneL = `mi;      12'd187: toneL = `mi;      
                12'd188: toneL = `mi;      12'd189: toneL = `mi;      12'd190: toneL = `mi;      12'd191: toneL = `mi;
                12'd192: toneL = `so;      12'd193: toneL = `so;      12'd194: toneL = `so;      12'd195: toneL = `so;
                12'd196: toneL = `so;      12'd197: toneL = `so;      12'd198: toneL = `so;      12'd199: toneL = `so;
                12'd200: toneL = `so;      12'd201: toneL = `so;      12'd202: toneL = `so;      12'd203: toneL = `so;      
                12'd204: toneL = `so;      12'd205: toneL = `so;      12'd206: toneL = `so;      12'd207: toneL = `so;
                12'd208: toneL = `fa;      12'd209: toneL = `fa;      12'd210: toneL = `fa;      12'd211: toneL = `fa;
                12'd212: toneL = `fa;      12'd213: toneL = `fa;      12'd214: toneL = `fa;      12'd215: toneL = `fa;
                12'd216: toneL = `fa;      12'd217: toneL = `fa;      12'd218: toneL = `fa;      12'd219: toneL = `fa;
                12'd220: toneL = `fa;      12'd221: toneL = `fa;      12'd222: toneL = `fa;      12'd223: toneL = `fa;      
                12'd224: toneL = `re;      12'd225: toneL = `re;      12'd226: toneL = `re;      12'd227: toneL = `re;
                12'd228: toneL = `re;      12'd229: toneL = `re;      12'd230: toneL = `re;      12'd231: toneL = `re;
                12'd232: toneL = `re;      12'd233: toneL = `re;      12'd234: toneL = `re;      12'd235: toneL = `re;
                12'd236: toneL = `re;      12'd237: toneL = `re;      12'd238: toneL = `re;      12'd239: toneL = `re;      
                12'd240: toneL = `si;      12'd241: toneL = `si;      12'd242: toneL = `si;      12'd243: toneL = `si;
                12'd244: toneL = `si;      12'd245: toneL = `si;      12'd246: toneL = `si;      12'd247: toneL = `si;
                12'd248: toneL = `si;      12'd249: toneL = `si;      12'd250: toneL = `si;      12'd251: toneL = `si;
                12'd252: toneL = `si;      12'd253: toneL = `si;      12'd254: toneL = `si;      12'd255: toneL = `si;
                12'd256: toneL = `high_do;      12'd257: toneL = `high_do;      12'd258: toneL = `high_do;      12'd259: toneL = `high_do;      
                12'd260: toneL = `high_do;      12'd261: toneL = `high_do;      12'd262: toneL = `high_do;      12'd263: toneL = `high_do;
                12'd264: toneL = `high_do;      12'd265: toneL = `high_do;      12'd266: toneL = `high_do;      12'd267: toneL = `high_do;
                12'd268: toneL = `high_do;      12'd269: toneL = `high_do;      12'd270: toneL = `high_do;      12'd271: toneL = `high_do;
                12'd272: toneL = `so;      12'd273: toneL = `so;      12'd274: toneL = `so;      12'd275: toneL = `so;      
                12'd276: toneL = `so;      12'd277: toneL = `so;      12'd278: toneL = `so;      12'd279: toneL = `so;
                12'd280: toneL = `so;      12'd281: toneL = `so;      12'd282: toneL = `so;      12'd283: toneL = `so;
                12'd284: toneL = `so;      12'd285: toneL = `so;      12'd286: toneL = `so;      12'd287: toneL = `so;
                12'd288: toneL = `high_do;      12'd289: toneL = `high_do;      12'd290: toneL = `high_do;      12'd291: toneL = `high_do;      
                12'd292: toneL = `high_do;      12'd293: toneL = `high_do;      12'd294: toneL = `high_do;      12'd295: toneL = `high_do;
                12'd296: toneL = `high_do;      12'd297: toneL = `high_do;      12'd298: toneL = `high_do;      12'd299: toneL = `high_do;
                12'd300: toneL = `high_do;      12'd301: toneL = `high_do;      12'd302: toneL = `high_do;      12'd303: toneL = `high_do;
                12'd304: toneL = `so;      12'd305: toneL = `so;      12'd306: toneL = `so;      12'd307: toneL = `so;      
                12'd308: toneL = `so;      12'd309: toneL = `so;      12'd310: toneL = `so;      12'd311: toneL = `so;
                12'd312: toneL = `so;      12'd313: toneL = `so;      12'd314: toneL = `so;      12'd315: toneL = `so;
                12'd316: toneL = `so;      12'd317: toneL = `so;      12'd318: toneL = `so;      12'd319: toneL = `so;
                12'd320: toneL = `high_do;      12'd321: toneL = `high_do;      12'd322: toneL = `high_do;      12'd323: toneL = `high_do;      
                12'd324: toneL = `high_do;      12'd325: toneL = `high_do;      12'd326: toneL = `high_do;      12'd327: toneL = `high_do;
                12'd328: toneL = `high_do;      12'd329: toneL = `high_do;      12'd330: toneL = `high_do;      12'd331: toneL = `high_do;
                12'd332: toneL = `high_do;      12'd333: toneL = `high_do;      12'd334: toneL = `high_do;      12'd335: toneL = `high_do;
                12'd336: toneL = `so;      12'd337: toneL = `so;      12'd338: toneL = `so;      12'd339: toneL = `so;
                12'd340: toneL = `so;      12'd341: toneL = `so;      12'd342: toneL = `so;      12'd343: toneL = `so;      
                12'd344: toneL = `so;      12'd345: toneL = `so;      12'd346: toneL = `so;      12'd347: toneL = `so;
                12'd348: toneL = `so;      12'd349: toneL = `so;      12'd350: toneL = `so;      12'd351: toneL = `so;
                12'd352: toneL = `high_do;      12'd353: toneL = `high_do;      12'd354: toneL = `high_do;      12'd355: toneL = `high_do;      
                12'd356: toneL = `high_do;      12'd357: toneL = `high_do;      12'd358: toneL = `high_do;      12'd359: toneL = `high_do;
                12'd360: toneL = `so;      12'd361: toneL = `so;      12'd362: toneL = `so;      12'd363: toneL = `so;
                12'd364: toneL = `so;      12'd365: toneL = `so;      12'd366: toneL = `so;      12'd367: toneL = `so;
                12'd368: toneL = `la;      12'd369: toneL = `la;      12'd370: toneL = `la;      12'd371: toneL = `la;      
                12'd372: toneL = `la;      12'd373: toneL = `la;      12'd374: toneL = `la;      12'd375: toneL = `la;      
                12'd376: toneL = `si;      12'd377: toneL = `si;      12'd378: toneL = `si;      12'd379: toneL = `si;
                12'd380: toneL = `si;      12'd381: toneL = `si;      12'd382: toneL = `si;      12'd383: toneL = `si;      
                12'd384: toneL = `high_re;      12'd385: toneL = `high_re;      12'd386: toneL = `high_re;      12'd387: toneL = `high_re;
                12'd388: toneL = `high_re;      12'd389: toneL = `high_re;      12'd390: toneL = `high_re;      12'd391: toneL = `high_re;
                12'd392: toneL = `high_re;      12'd393: toneL = `high_re;      12'd394: toneL = `high_re;      12'd395: toneL = `high_re;
                12'd396: toneL = `high_re;      12'd397: toneL = `high_re;      12'd398: toneL = `high_re;      12'd399: toneL = `high_re;      
                12'd400: toneL = `fa;      12'd401: toneL = `fa;      12'd402: toneL = `fa;      12'd403: toneL = `fa;
                12'd404: toneL = `fa;      12'd405: toneL = `fa;      12'd406: toneL = `fa;      12'd407: toneL = `fa;
                12'd408: toneL = `fa;      12'd409: toneL = `fa;      12'd410: toneL = `fa;      12'd411: toneL = `fa;      
                12'd412: toneL = `fa;      12'd413: toneL = `fa;      12'd414: toneL = `fa;      12'd415: toneL = `fa;
                12'd416: toneL = `high_do;      12'd417: toneL = `high_do;      12'd418: toneL = `high_do;      12'd419: toneL = `high_do;
                12'd420: toneL = `high_do;      12'd421: toneL = `high_do;      12'd422: toneL = `high_do;      12'd423: toneL = `high_do;      
                12'd424: toneL = `high_do;      12'd425: toneL = `high_do;      12'd426: toneL = `high_do;      12'd427: toneL = `high_do;
                12'd428: toneL = `high_do;      12'd429: toneL = `high_do;      12'd430: toneL = `high_do;      12'd431: toneL = `high_do;
                12'd432: toneL = `mi;      12'd433: toneL = `mi;      12'd434: toneL = `mi;      12'd435: toneL = `mi;
                12'd436: toneL = `mi;      12'd437: toneL = `mi;      12'd438: toneL = `mi;      12'd439: toneL = `mi;      
                12'd440: toneL = `mi;      12'd441: toneL = `mi;      12'd442: toneL = `mi;      12'd443: toneL = `mi;
                12'd444: toneL = `mi;      12'd445: toneL = `mi;      12'd446: toneL = `mi;      12'd447: toneL = `mi;
                12'd448: toneL = `high_do;      12'd449: toneL = `high_do;      12'd450: toneL = `high_do;      12'd451: toneL = `high_do;      
                12'd452: toneL = `high_do;      12'd453: toneL = `high_do;      12'd454: toneL = `high_do;      12'd455: toneL = `high_do;
                12'd456: toneL = `high_do;      12'd457: toneL = `high_do;      12'd458: toneL = `high_do;      12'd459: toneL = `high_do;
                12'd460: toneL = `high_do;      12'd461: toneL = `high_do;      12'd462: toneL = `high_do;      12'd463: toneL = `high_do;
                12'd464: toneL = `so;      12'd465: toneL = `so;      12'd466: toneL = `so;      12'd467: toneL = `so;      
                12'd468: toneL = `so;      12'd469: toneL = `so;      12'd470: toneL = `so;      12'd471: toneL = `so;
                12'd472: toneL = `so;      12'd473: toneL = `so;      12'd474: toneL = `so;      12'd475: toneL = `so;
                12'd476: toneL = `so;      12'd477: toneL = `so;      12'd478: toneL = `so;      12'd479: toneL = `so;      
                12'd480: toneL = `do;      12'd481: toneL = `do;      12'd482: toneL = `do;      12'd483: toneL = `do;
                12'd484: toneL = `do;      12'd485: toneL = `do;      12'd486: toneL = `do;      12'd487: toneL = `do;
                12'd488: toneL = `do;      12'd489: toneL = `do;      12'd490: toneL = `do;      12'd491: toneL = `do;      
                12'd492: toneL = `do;      12'd493: toneL = `do;      12'd494: toneL = `do;      12'd495: toneL = `do;
                12'd496: toneL = `silence;      12'd497: toneL = `silence;      12'd498: toneL = `silence;      12'd499: toneL = `silence;
                12'd500: toneL = `silence;      12'd501: toneL = `silence;      12'd502: toneL = `silence;      12'd503: toneL = `silence;
                12'd504: toneL = `silence;      12'd505: toneL = `silence;      12'd506: toneL = `silence;      12'd507: toneL = `silence;      
                12'd508: toneL = `silence;      12'd509: toneL = `silence;      12'd510: toneL = `silence;      12'd511: toneL = `silence;
                default : toneL = `silence;
            endcase
        end else begin
            toneL = `silence;
        end
    end

endmodule
