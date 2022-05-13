unit uhaikuvector;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  LazUTF8, Clipbrd, Windows;

type

  sa = array of string;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private

  public

  end;

CONST
  MM_MAX_NUMAXES =  16;
  FR_PRIVATE     = $10;
  FR_NOT_ENUM    = $20;

 TYPE
  PDesignVector = ^TDesignVector;
  TDesignVector = Packed Record
   dvReserved: DWORD;
   dvNumAxes : DWORD;
   dvValues  : Array[0..MM_MAX_NUMAXES-1] Of LongInt;
  End;

var
  Form1: TForm1;
  vowels:string ='ауоыиэяюёєїеaeiou';
  lw:integer=0;
  tmp,n,v,p,a,m,s:array of string;
  f:textfile;
  line:array[0..2]of string;
  fntf:string='japanesebrushrusbyme.otf';
  fntn:string='Japanese Brush [Rus by me]';


  //
  Function AddFontResourceEx    (Dir : PAnsiChar;
                                Flag: Cardinal;
                                PDV : PDesignVector): Int64; StdCall;
                                External 'GDI32.dll' Name 'AddFontResourceExA';

  Function RemoveFontResourceEx (Dir : PAnsiChar;
                                Flag: Cardinal;
                                PDV : PDesignVector): Int64; StdCall;
                                External 'GDI32.dll' Name 'RemoveFontResourceExA';

implementation

{$R *.lfm}

{ TForm1 }

procedure loadconfig;
var t,fn:string;
begin
  fn:=extractfiledir(application.exename)+'\';
  assignfile(f,fn+'config.txt');

  reset(f);

  readln(f,fntf);
  readln(f,fntn);

  CloseFile(f);
end;


function loadtoarray(fn,fa:string):sa;
var t:string;
    arr:array of string;
begin
  assignfile(f,fn+fa);
  setlength(arr,0);
  reset(f);
  while not eof(f) do
  begin
    readln(f,t);
    setlength(arr,length(arr)+1);
    arr[high(arr)]:=t;
  end;
  closefile(f);

  result:=arr;
end;

procedure loaddata;
var t,fn:string;
begin
  fn:=extractfiledir(application.exename)+'\vocabulary\';

  tmp:=loadtoarray(fn,'templates.txt');
  n:=loadtoarray(fn,'n.txt');
  v:=loadtoarray(fn,'v.txt');
  p:=loadtoarray(fn,'p.txt');
  a:=loadtoarray(fn,'a.txt');
  s:=loadtoarray(fn,'s.txt');
  m:=loadtoarray(fn,'m.txt');

  {assignfile(f,fn+'templates.txt');
  reset(f);
  while not eof(f) do begin readln(f,t); setlength(tmp,length(tmp)+1); tmp[high(tmp)]:=t; end;
  closefile(f);

  assignfile(f,fn+'n.txt');
  reset(f);
  while not eof(f) do begin readln(f,t); setlength(n,length(n)+1); n[high(n)]:=t; end;
  closefile(f);

  assignfile(f,fn+'v.txt');
  reset(f);
  while not eof(f) do begin readln(f,t); setlength(v,length(v)+1); v[high(v)]:=t; end;
  closefile(f);

  assignfile(f,fn+'p.txt');
  reset(f);
  while not eof(f) do begin readln(f,t); setlength(p,length(p)+1); p[high(p)]:=t; end;
  closefile(f);

  assignfile(f,fn+'a.txt');
  reset(f);
  while not eof(f) do begin readln(f,t); setlength(a,length(a)+1); a[high(a)]:=t; end;
  closefile(f);

  assignfile(f,fn+'m.txt');
  reset(f);
  while not eof(f) do begin readln(f,t); setlength(m,length(m)+1); m[high(m)]:=t; end;
  closefile(f);

  assignfile(f,fn+'s.txt');
  reset(f);
  while not eof(f) do begin readln(f,t); setlength(s,length(s)+1); s[high(s)]:=t; end;
  closefile(f);  }

end;

procedure makehaiku;
var t:string;
    i,k:integer;
begin
  t:=tmp[random(length(tmp))];
  line[0]:=''; line[1]:=''; line[2]:='';
  k:=0;
  for i:=1 to length(t) do
  begin
    case t[i] of
    'n':line[k]:=line[k]+n[random(length(n))]+' ';
    'v':line[k]:=line[k]+v[random(length(v))]+' ';
    'p':line[k]:=line[k]+p[random(length(p))]+' ';
    'a':line[k]:=line[k]+a[random(length(a))]+' ';
    'm':line[k]:=line[k]+m[random(length(m))]+' ';
    's':line[k]:=line[k]+s[random(length(s))]+' ';
    '/':begin inc(k); if(k>2) then break; end;
    end;
  end;
  form1.edit1.text:=line[0];
  form1.edit2.text:=line[1];
  form1.edit3.text:=line[2];
end;

function isvowel(l:string):boolean;
var i:integer;
    res:boolean;
begin
  res:=false;
  for i:=1 to lw do
  begin
    if l=UTF8Copy(vowels, i, 1) then
    begin
      form1.memo1.lines.add(l + ' == ' + UTF8Copy(vowels, i, 1));
      res:=true;
    end;
  end;
  result:=res;
end;

function calcvowels(txt:string ):integer;
var i,tl,nv,res:integer;
begin
  tl:=UTF8Length (txt);
  if tl>0 then
  begin
    res:=1;
    nv:=0;
    for i:=1 to tl do
    begin
      if isvowel(UTF8Copy(txt, i, 1)) then inc(nv);
    end;
    if (nv>0) then res:=nv;
  end
  else
  begin
    res:=0;
  end;

  result:=res;

end;

procedure TForm1.Image1Click(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
Var
   i:integer;
   strAppPath: String;
   fffff:array of integer;
begin
  //font loading from: https://forum.lazarus.freepascal.org/index.php/topic,21032.0.html

  loadconfig;

  randomize;
  lw:=UTF8Length (vowels);
  loaddata;

  strAppPath:= ExtractFileDir(Application.ExeName);
  If FileExists(strAppPath+'\'+fntf) Then
  begin
    If AddFontResourceEx(PAnsiChar(strAppPath+'\'+fntf), FR_Private, Nil) <> 0 Then
    begin

      edit1.Font.Name:=fntn;
      edit2.Font.Name:=fntn;
      edit3.Font.Name:=fntn;
      label1.Font.Name:=fntn;
      label2.Font.Name:=fntn;
      label3.Font.Name:=fntn;
      button1.Font.Name:=fntn;
      button2.Font.Name:=fntn;
      SendMessage(Form1.Handle, WM_FONTCHANGE, 0, 0);

    end
    else
    begin
      ShowMessage('Font add failed.');
    end;
  end
  else ShowMessage('File not found: '+strAppPath+'\'+fntf);

end;

procedure TForm1.FormShow(Sender: TObject);
var Image:TJPEGImage;
    bmpi:Graphics.TBitmap;
    mr1,mr2:TRect;
begin
  Image := TJPEGImage.Create;
  Image.LoadFromFile(ExtractFileDir(Application.ExeName)+'\bg.jpg');
  bmpi:=Graphics.TBitmap.Create;
  bmpi.Width:=image.Width;
  bmpi.Height:=image.Height;
  bmpi.Assign(image);
  Image1.Picture.Bitmap.Width:=Image1.Width;
  Image1.Picture.Bitmap.Height:=Image1.Height;
  mr1.Create(0,0,bmpi.Width,bmpi.Height);
  mr2.Create(0,0,image1.Width,image1.Height);
  Image1.Canvas.CopyRect(mr2,bmpi.Canvas,mr1);
  Image.Destroy;
  bmpi.Destroy;
end;

procedure TForm1.Edit1Change(Sender: TObject);
var cnv:integer;
begin
  cnv:=calcvowels(edit1.text);
  if (cnv<3) or (cnv>7) then Label1.Font.Color:=clRed else Label1.Font.Color:=clGreen;
  Label1.Caption:=inttostr(cnv);;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  makehaiku;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Clipboard.AsText := line[0]+#13#10+line[1]+#13#10+line[2];
end;

procedure TForm1.Edit2Change(Sender: TObject);
var cnv:integer;
begin
  cnv:=calcvowels(edit2.text);
  if (cnv<5) or (cnv>10) then Label2.Font.Color:=clRed else Label2.Font.Color:=clGreen;
  Label2.Caption:=inttostr(cnv);
end;

procedure TForm1.Edit3Change(Sender: TObject);
var cnv:integer;
begin
  cnv:=calcvowels(edit3.text);
  if (cnv<3) or (cnv>7) then Label3.Font.Color:=clRed else Label3.Font.Color:=clGreen;
  Label3.Caption:=inttostr(cnv);
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
Var
  AppPath: String;
Begin
  AppPath:= ExtractFileDir(Application.ExeName);

  If FileExists(AppPath+'\'+fntf)
  Then
   If RemoveFontResourceEx(PAnsiChar(AppPath+'\'+fntf), FR_Private, Nil) <> 0
   Then SendMessage(Form1.Handle, WM_FONTCHANGE, 0, 0);
End;

end.

