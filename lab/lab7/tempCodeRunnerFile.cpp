		while(cin >> tmp1){
			if(!tmp1){
				for(int i=0; i<tmp_cnt; i++){
					for(int j=0; j<4*a[i]; j++){
						if(b[i] == b[i+1] && i != tmp_cnt-1 && j == 4*a[i]-1) cout << "12'd" << cnt++ << ": " << "toneR = `silence" << ";" << "      ";
						else cout << "12'd" << cnt++ << ": " << "toneR = `" << b[i] << ";" << "      ";
						if((j + 1) % 4 == 0) cout << endl; 
					}
				}
				break;
			}
			a[tmp_cnt] = tmp1 * 4;
			cin >> tmp2;
			b[tmp_cnt] = tmp2;
			tmp_cnt++;			
		}