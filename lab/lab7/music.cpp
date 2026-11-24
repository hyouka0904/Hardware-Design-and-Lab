#include<iostream>
#include<string>
#include<map>
using namespace std;
map<string, int> info = {
	{"high_do", 1}, {"high_re", 2}, {"high_mi", 3}, {"high_fa", 4}, {"high_so", 5}, {"high_la", 6}, {"high_si", 7}
};
int main(){
	int a[100], cnt = 0, tmp_cnt = 0, order = 1, flag = 1, flag_1 = 1;
	int min[100], max[100], store[1000];
	double tmp1;
	string b[100], dir, tmp2;
	cin >> dir;
	if(dir.compare("R") == 0){
		while(cin >> tmp1){
			if(!tmp1){
				for(int i=0; i<tmp_cnt; i++){
					for(int j=0; j<4*a[i]; j++){
						if(b[i] == b[i+1] && i != tmp_cnt-1 && j == 4*a[i]-1){
							store[cnt] = 0;
							cout << "12'd" << cnt++ << ": " << "toneR = `silence" << ";" << "      ";
						}
						else {
							if(b[i] != "s"){
								store[cnt] = info[b[i]];
								cout << "12'd" << cnt++ << ": " << "toneR = `" << b[i] << ";" << "      ";
							}
							else{
								store[cnt] = 0;
								cout << "12'd" << cnt++ << ": " << "toneR = `silence" << ";" << "      ";
							}
						}
						if((j + 1) % 4 == 0) cout << endl; 
					}
				}
				cout << "assign order =  " << endl;
				for(int i=0; i<513; i++){
					int min, max;
					if(store[i] && flag){
						min = i;
						flag = 0;
						flag_1 = 1;
					}
					if((store[i] != store[i+1]) && flag_1){
						flag = 1;
						flag_1 = 0;
						max = i;
						cout << "(ibeatNum >= " << min << " && ibeatNum <= " << max << ") ? " << order++ << " : " << endl;
					}
				}
				break;
			}
			a[tmp_cnt] = tmp1 * 4;
			cin >> tmp2;
			b[tmp_cnt] = tmp2;
			tmp_cnt++;			
		}
	}
	else{
		while(cin >> tmp1){
			if(!tmp1){
				for(int i=0; i<tmp_cnt; i++){
					for(int j=0; j<4*a[i]; j++){
						if(b[i] == b[i+1] && i != tmp_cnt-1 && j == 4*a[i]-1) cout << "12'd" << cnt++ << ": " << "toneL = `silence" << ";" << "      ";
						else {
							if(b[i] != "s")
								cout << "12'd" << cnt++ << ": " << "toneL = `" << b[i] << ";" << "      ";
							else cout << "12'd" << cnt++ << ": " << "toneL = `silence" << ";" << "      ";
						}
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
	}
	return 0;
}