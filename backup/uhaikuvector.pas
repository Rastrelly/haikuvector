unit uhaikuvector;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  LazUTF8, Clipbrd;

type

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
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  vowels:string ='ауоыиэяюёеaeiou';
  lw:integer=0;
  tmp,n,v,p,a,s:array of string;
  f:textfile;
  line:array[0..2]of string;

implementation

{$R *.lfm}

{ TForm1 }

procedure loaddata;
var t,fn:string;
begin
  fn:=extractfiledir(application.exename)+'\vocabulary\';

  assignfile(f,fn+'templates.txt');
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

  assignfile(f,fn+'s.txt');
  reset(f);
  while not eof(f) do begin readln(f,t); setlength(s,length(s)+1); s[high(s)]:=t; end;
  closefile(f);

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
begin
  randomize;
  lw:=UTF8Length (vowels);
  loaddata;
end;

procedure TForm1.Edit1Change(Sender: TObject);
var cnv:integer;
begin
  cnv:=calcvowels(edit1.text);
  if (cnv=0) or (cnv>7) then Label1.Font.Color:=clRed else Label1.Font.Color:=clGreen;
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
  if (cnv=0) or (cnv>10) then Label2.Font.Color:=clRed else Label2.Font.Color:=clGreen;
  Label2.Caption:=inttostr(cnv);
end;

procedure TForm1.Edit3Change(Sender: TObject);
var cnv:integer;
begin
  cnv:=calcvowels(edit3.text);
  if (cnv=0) or (cnv>7) then Label3.Font.Color:=clRed else Label3.Font.Color:=clGreen;
  Label3.Caption:=inttostr(cnv);
end;

end.

