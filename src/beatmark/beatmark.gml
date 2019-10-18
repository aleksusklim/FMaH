#define beatmark_load
// count=beatmark_load(song.log,adjust)

beatmark_cnt=0;
beatmark_arr[beatmark_cnt,0]=0;
beatmark_arr[beatmark_cnt,1]=0;

argument10=file_text_open_read(argument0);
while not file_text_eof(argument10){
beatmark_arr[beatmark_cnt,0]=file_text_read_real(argument10)+argument1;file_text_readln(argument10);
beatmark_arr[beatmark_cnt,1]=file_text_read_real(argument10);file_text_readln(argument10);
beatmark_cnt+=1;
}
file_text_close(argument10);

return beatmark_cnt;


#define beatmark_near
// beatmark_near(sample,mask,leftright)

argument9=beatmark_cnt;
if argument9<=0 return -1;

argument10=0;
argument11=argument9-1;

if argument0<=beatmark_arr[argument10,0] {
argument15=argument10;
}else if argument0>=beatmark_arr[argument11,0] {
argument15=argument11;
}else while argument9<>0 {

if argument11-argument10<2 {
if argument2>0 then argument15=argument11
else if argument2<0 then argument15=argument10
else {
if argument0<(beatmark_arr[argument11,0]+beatmark_arr[argument10,0])/2
then argument15=argument10 else argument15=argument11;
}
break;
}

argument12=(argument11+argument10) div 2;
argument13=beatmark_arr[argument12,0];

if argument0=argument13 {
argument15=argument12;
break;
}
if argument0>argument13 then argument10=argument12 else argument11=argument12;

argument9-=1;
}
if argument9=0 return show_error('',false);

if argument1=0 return argument15;
if beatmark_arr[argument15,1]&argument1<>0 return argument15;

argument10=argument15-1;
argument11=argument15+1;

if argument2>0 then argument10=-1
else if argument2<0 then argument11=beatmark_cnt;

while true {

if argument10>=0 {
if (argument11<beatmark_cnt)
then argument9=(beatmark_arr[argument11,0]-argument0)<(argument0-beatmark_arr[argument10,0])
else argument9=false;
}else{
if (argument11<beatmark_cnt)
then argument9=true
else return -1;
}

if argument9 {
if beatmark_arr[argument11,1]&argument1<>0 return argument11;
argument11+=1;
}else{
if beatmark_arr[argument10,1]&argument1<>0 return argument10;
argument10-=1;
}

}









#define beatmark_sample
// beatmark_sample(index)

return beatmark_arr[argument0,0];


#define beatmark_color
// beatmark_color(index)

return beatmark_arr[argument0,1];


