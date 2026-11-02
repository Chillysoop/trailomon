"""Build the 20-second owner trailer from 600 real, isolated Defold captures.
Requires Pillow/numpy and imageio-ffmpeg (or --ffmpeg). No network or paid API.
"""
import argparse, hashlib, json, math, subprocess, sys, wave, zipfile
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFont
ROOT=Path(__file__).resolve().parent.parent
FPS=30; SECONDS=20; W,H=1280,720
INK='#efe7cf'; DARK='#142620'; GOLD='#e1bc70'; MUTED='#adbc9f'
parser=argparse.ArgumentParser();parser.add_argument('--footage',type=Path);parser.add_argument('--ffmpeg');args=parser.parse_args()
footage=args.footage or Path((ROOT/'.tools/latest-trailer-footage.txt').read_text().strip())
out=ROOT/'reviews/evidence/trailer';out.mkdir(parents=True,exist_ok=True)
if args.ffmpeg: ffmpeg=args.ffmpeg
else:
 sys.path.insert(0,str(ROOT/'.tools/trailer-deps'))
 import imageio_ffmpeg
 ffmpeg=imageio_ffmpeg.get_ffmpeg_exe()
fontfile=ROOT/'.tools/trailer-font.ttf'
if not fontfile.exists():
 version=json.loads((ROOT/'tools/defold-version.json').read_text())['version']
 with zipfile.ZipFile(ROOT/f'.tools/bob-{version}.jar') as z: fontfile.write_bytes(z.read('builtins/fonts/vera_mo_bd.ttf'))
fonts={s:ImageFont.truetype(str(fontfile),s) for s in [14,18,20,22,24,28,32,36,42,46,52,64,86]}
sprites={name:Image.open(ROOT/f'assets/sprites/{name}.png').convert('RGBA') for name in ['brindlehorn','reedskipper','loamling','bellmoth','cindercoil','slatewhorl']}
def text(canvas,string,xy,size=42,color=INK,center=False):
 d=ImageDraw.Draw(canvas);f=fonts[size]
 if center: xy=(xy[0]-d.textlength(string,font=f)/2,xy[1])
 d.text(xy,string,font=f,fill=color,stroke_width=0)
def paste_crop(canvas,img,box,rect):
 x,y,ww,hh=rect;cut=img.crop(box);ratio=min(ww/cut.width,hh/cut.height);cut=cut.resize((round(cut.width*ratio),round(cut.height*ratio)),Image.Resampling.NEAREST)
 canvas.paste(cut,(x+(ww-cut.width)//2,y+(hh-cut.height)//2))
def sprite(canvas,name,x,y,size):
 img=sprites[name];box=img.getbbox();img=img.crop(box);ratio=size/max(img.size);img=img.resize((round(img.width*ratio),round(img.height*ratio)),Image.Resampling.NEAREST)
 canvas.paste(img,(round(x-img.width/2),round(y-img.height/2)),img)
def frame(i):
 im=Image.open(footage/f'frame-{i:04d}.png').convert('RGB');c=Image.new('RGB',(W,H),DARK)
 d=ImageDraw.Draw(c)
 if i<75:
  paste_crop(c,im,(28,183,862,413),(0,267,1280,355))
  text(c,'WHAT IF THE OREGON TRAIL',(640,91),36,center=True)
  text(c,'WAS A CREATURE COLLECTOR?',(640,148),46,GOLD,True)
  text(c,'BEFRIEND THE WILD. BRAVE THE TRAIL.',(640,642),24,center=True)
 elif i<150:
  text(c,'FIND YOUR CREW.',(56,42),52)
  sprite(c,'loamling',152,384,230)
  paste_crop(c,im,(28,130,862,580),(305,151,927,500))
  text(c,'SHARE FOOD. MAKE A FRIEND.',(56,657),24,GOLD)
 elif i<210:
  text(c,'BUILD YOUR BATTLE TEAM.',(56,42),52)
  paste_crop(c,im,(20,94,1260,665),(28,126,1224,563))
 elif i<245:
  text(c,'PACK.',(64,199),86)
  text(c,'PUSH ON.',(64,310),64,GOLD)
  text(c,'FOOD. TOOLS. TOUGH CHOICES.',(64,525),24)
  paste_crop(c,im,(890,280,1252,650),(693,116,500,525))
 elif i<285:
  text(c,'MAKE EVERY DAY COUNT.',(56,42),46)
  paste_crop(c,im,(28,110,1252,665),(28,130,1224,555))
 elif i<330:
  text(c,'CHOOSE YOUR CROSSING.',(56,42),46)
  sprite(c,'reedskipper',142,388,235)
  paste_crop(c,im,(28,130,862,620),(280,133,972,555))
 elif i<525:
  text(c,'THEY FIGHT. YOU SURVIVE.',(56,40),46)
  paste_crop(c,im,(20,94,1260,665),(20,119,1240,571))
  text(c,'POSITION. EQUIP. UNLEASH REPEATING ABILITIES.',(56,101),18,GOLD)
 else:
  paste_crop(c,im,(28,183,862,384),(0,175,1280,310))
  text(c,'TRAILOMON',(640,72),86,GOLD,True)
  d=ImageDraw.Draw(c);d.rectangle((0,495,1280,598),fill=DARK)
  text(c,'CREATURE COLLECTING.',(640,510),32,INK,True)
  text(c,'OLD-SCHOOL SURVIVAL.',(640,555),32,INK,True)
  for n,name in enumerate(sprites): sprite(c,name,390+n*100,646,80)
 # A small, constant disclosure; no release date or unimplemented roster claim.
 d=ImageDraw.Draw(c);d.rectangle((0,699,1280,720),fill=DARK)
 text(c,'IN DEVELOPMENT  /  EDITED PROTOTYPE FOOTAGE',(640,702),14,MUTED,True)
 # Short opening/closing fades, with crisp cuts on musical beats in between.
 gain=min(1,(i+1)/8,(600-i)/8)
 if gain<1: c=Image.blend(Image.new('RGB',c.size,DARK),c,gain)
 return c

def soundtrack():
 sr=48000;buf=np.zeros((sr*SECONDS,2),dtype=np.float64);rng=np.random.default_rng(1848)
 def note(at,midi,dur,amp,pan=0,kind='pluck'):
  n=int(sr*dur);t=np.arange(n)/sr;freq=440*2**((midi-69)/12)
  if kind=='bass': sig=(np.sin(2*np.pi*freq*t)+.18*np.sin(4*np.pi*freq*t))*np.exp(-t*5)
  else:
   sig=sum((1/h**1.35)*np.sin(2*np.pi*freq*h*t)*np.exp(-t*(3+h*1.4)) for h in range(1,7))
  env=np.minimum(1,t/.004)*np.minimum(1,(dur-t)/.03);sig*=env*amp
  a=int(at*sr);b=min(len(buf),a+n);sig=sig[:b-a]
  if a>=len(buf):return
  buf[a:b,0]+=sig*math.sqrt((1-pan)/2);buf[a:b,1]+=sig*math.sqrt((1+pan)/2)
 # Original E-minor trail motif, ten two-second bars. More motion for the combat cut.
 chords=[(52,55,59),(48,52,55),(55,59,62),(50,54,57),(52,55,59),(48,52,55),(55,59,62),(50,54,57),(52,55,59),(52,55,59)]
 melody=[76,79,81,83,81,79,76,74, 76,79,81,79,74,76,79,83,
         83,81,79,76,79,81,83,86, 83,81,79,76,74,76,79,76]
 for bar,chord in enumerate(chords):
  start=bar*2
  for beat in range(4):
   note(start+beat*.5,chord[0]-12,.44,.17,0,'bass')
   note(start+beat*.5+.25,chord[beat%3]+12,.6,.12,(-.35 if beat%2 else .35))
  for beat in range(4): note(start+beat*.5,melody[(bar*4+beat)%len(melody)],.7,.14,-.15)
  if bar>=6 and bar<9:
   for beat in range(8): note(start+beat*.25,chord[beat%3]+24,.28,.045,.5)
 # Warm kick, dry woodblock snare and soft shaker, all synthesized here.
 for beat in range(39):
  at=beat*.5;n=int(sr*.17);t=np.arange(n)/sr
  if beat%2==0: sig=np.sin(2*np.pi*(52*t+24*.025*(1-np.exp(-t/.025))))*np.exp(-t*28)*.24
  else: sig=(rng.standard_normal(n)*.09+np.sin(2*np.pi*820*t)*.06)*np.exp(-t*48)
  a=int(at*sr);buf[a:a+n]+=sig[:,None]
  for offset in [.25]:
   n=int(sr*.06);noise=rng.standard_normal(n);noise=np.concatenate(([0],np.diff(noise)))*np.exp(-np.arange(n)/sr*70)*.024
   a=int((at+offset)*sr);buf[a:a+n]+=noise[:,None]*np.array([.65,.85])
 # Resolve on the logo, then leave a deliberate tail instead of an abrupt stop.
 for n in [52,59,64,67,71,76]:note(18,n,1.95,.08,(n%3-1)*.3)
 fade=np.minimum(1,np.arange(len(buf))/2400)*np.minimum(1,(len(buf)-np.arange(len(buf)))/12000)
 buf*=fade[:,None];buf=np.tanh(buf*1.25);buf*=.82/max(.82,float(np.max(np.abs(buf))))
 audio=ROOT/'.tools/trailer-score.wav'
 with wave.open(str(audio),'wb') as f:f.setnchannels(2);f.setsampwidth(2);f.setframerate(sr);f.writeframes((buf*32767).astype('<i2').tobytes())
 return audio,{'sample_rate':sr,'samples':len(buf),'peak_dbfs':round(20*np.log10(np.max(np.abs(buf))),2),'rms_dbfs':round(20*np.log10(np.sqrt(np.mean(buf**2))),2)}

if __name__=='__main__':
 assert len(list(footage.glob('frame-*.png')))==600,'Expected exactly 20s at30fps'
 for i in [45,90,135,180,230,270,310,405,555]:frame(i).save(out/f'preview-{i:03d}.png')
 frame(555).save(out/'poster.jpg',quality=92)
 contact=Image.new('RGB',(960,540),DARK)
 for j,i in enumerate([45,90,135,180,230,270,310,405,555]):contact.paste(frame(i).resize((320,180)),((j%3)*320,(j//3)*180))
 contact.save(ROOT/'.tools/trailer-contact.png')
 audio,stats=soundtrack();mp4=out/'Trailomon-20s.mp4'
 command=[ffmpeg,'-y','-loglevel','warning','-f','rawvideo','-pix_fmt','rgb24','-s','1280x720','-r','30','-i','pipe:0','-i',str(audio),'-t','20','-c:v','libx264','-preset','fast','-crf','19','-pix_fmt','yuv420p','-c:a','aac','-b:a','192k','-ar','48000','-af','loudnorm=I=-16:TP=-1.5:LRA=9','-movflags','+faststart',str(mp4)]
 proc=subprocess.Popen(command,stdin=subprocess.PIPE,stderr=subprocess.PIPE)
 for i in range(600):proc.stdin.write(frame(i).tobytes())
 proc.stdin.close();errors=proc.stderr.read().decode();assert proc.wait()==0,errors
 source=json.loads((footage/'source.json').read_text())
 manifest={'duration_seconds':20,'fps':30,'frames':600,'resolution':[1280,720],'source_commit':source['source_commit'],'capture_inputs_sha256':source['inputs_sha256'],'capture_script_sha256':hashlib.sha256((ROOT/'tools/trailer_capture.gui_script').read_text(encoding='utf-8').encode('utf-8')).hexdigest(),'video_sha256':hashlib.sha256(mp4.read_bytes()).hexdigest(),'audio':stats,'music':'Original synthesized E-minor trail motif; no third-party recording','note':'Edited prototype fixtures. Real S30 expedition encounters, actual crew and carried gear; automatic combat shown at 2x. No reference-game art or footage.'}
 (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 print(json.dumps({'video':str(mp4),'megabytes':round(mp4.stat().st_size/1048576,2),'audio':stats}))
