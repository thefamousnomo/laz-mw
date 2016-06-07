unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, mysql55conn, mssqlconn, FileUtil,
  Forms, Controls, Graphics, Dialogs, DbCtrls, StdCtrls, ExtCtrls, unit2, inifiles, windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Image1: TImage;
    Label1: TLabel;
    Memo1: TMemo;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label1MouseEnter(Sender: TObject);
    procedure Label1MouseLeave(Sender: TObject);
    procedure procUpdate(Sender: TObject; columns: TStringList; select: TSQLQuery; params: TStringList);
    procedure logSQL(Sender: TSQLConnection; EventType: TDBEventType;
      const Msg: String);
    procedure stamp;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  INI: TINIFile;
  starttime: integer;

const
  nl: string = AnsiString(#13#10);


implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.stamp;
var
  st: TDateTime;
begin
  st:=Now;
  memo1.Append(formatdatetime('DD MM YYYY hh:mm:ss', st) + nl + '-----' + nl);
end;

procedure TForm1.procUpdate(Sender: TObject; columns: TStringList; select: TSQLQuery; params: TStringList);
var
  i: integer;
  endtime: integer;
  out: string = '';
  begin
  stamp;
  memo1.Append('updating ' + TButton(sender).Caption + nl);
  if checkbox2.Checked then
  begin
  memo1.Append('truncating ' + params[0]);
  datamodule1.connMYSQL.ExecuteDirect('truncate table ' + params[0] + ';');
  datamodule1.tranMYSQL.CommitRetaining;
  memo1.Append('truncated!' + nl);
  end;
  with datamodule1.connMSSQL do
  begin
    if checkbox1.Checked then
    begin
    OnLog:=@logSQL;
    LogEvents:=LogAllEvents;
    end;
    open;
  end;
  with datamodule1.connMYSQL do
  begin
    if checkbox1.Checked then
    begin
    OnLog:=@logSQL;
    LogEvents:=LogAllEvents;
    end;
    open;
  end;
  select.Open;
  select.First;
  datamodule1.queryMYSQLupdate.SQL.Text:='replace into ' + params[0] + ' values ' + params[1];
  while (not select.EOF) do begin
    for i := 0 to columns.Count - 1 do
    begin
      out := out + ' ' +  select.FieldByName(columns[i]).AsString;
      datamodule1.queryMYSQLupdate.Params.ParamByName(columns[i]).AsString:=select.FieldByName(columns[i]).AsString;
    end;
    memo1.Append('updating ' + columns.CommaText + ' with ' + out);
    out:='';
    datamodule1.queryMYSQLupdate.ExecSQL;
    select.Next;
    if (select.RecNo mod 10 = 0) then application.ProcessMessages;
  end;
  datamodule1.tranMYSQL.Commit;
  memo1.Append(nl + inttostr(select.RecordCount) + ' records updated');
  memo1.Append(nl + '-----');
  select.Close;
  with datamodule1 do
  begin
    queryMYSQLupdate.close;
    connMSSQL.Close;
    connMYSQL.Close;
  end;
  endtime:=getTickCount-starttime;
  memo1.Append(floattostr(int(endtime/1000/60)) + ' mins, ' + floattostr((endtime mod 60000)/1000) + ' secs');
  memo1.Append(nl + '-----' + nl);
end;

procedure TForm1.logSQL(Sender: TSQLConnection; EventType: TDBEventType;
  const Msg: String);
begin
  memo1.Append(msg);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  columns, params: TStringList;
begin
  starttime:=getTickCount;
  columns:=TStringList.Create;
  columns.Add('code');
  columns.Add('brand');
  params:=TStringList.Create;
  params.Add('brands');
  params.Add('(:code, :brand)');
  procUpdate(button1, columns, datamodule1.queryBrand, params);
  columns.Free;
  params.Free;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  columns, params: TStringList;
begin
  starttime:=getTickCount;
  columns:=TStringList.Create;
  columns.Add('CODE');
  columns.Add('COLOURS');
  params:=TStringList.Create;
  params.Add('colours');
  params.Add('(:CODE, :COLOURS)');
  procUpdate(button2, columns, datamodule1.queryColours, params);
  columns.Free;
  params.Free;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  columns, params: TStringList;
begin
  starttime:=getTickCount;
  columns:=TStringList.Create;
  with columns do
  begin
    Add('CODE');
    Add('Description');
    Add('Fabric');
    Add('D1');
    Add('D2');
    Add('D3');
    Add('D4');
    Add('D5');
    Add('Price');
    Add('Producer');
    Add('Category');
  end;
  params:=TStringList.Create;
  with params do
  begin
    Add('style');
    Add('(:CODE, :description, :fabric, :d1, :d2, :d3, :d4, :d5, :price, :producer, :category)');
  end;
  procUpdate(button3, columns, datamodule1.queryStyle, params);
  columns.Free;
  params.Free;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  columns, params: TStringList;
begin
  starttime:=getTickCount;
  columns:=TStringList.Create;
  with columns do
  begin
  Add('CODE');
  Add('SIZE');
  Add('ALTSIZE');
  end;
  params:=TStringList.Create;
  with params do
  begin
  Add('sizes');
  Add('(:CODE, :SIZE, :ALTSIZE)');
  end;
procUpdate(button4, columns, datamodule1.querySizes, params);
columns.Free;
params.Free;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  starttime_all, endtime_all: integer;
begin
  starttime:=getTickCount;
  starttime_all:=getTickCount;
  Button1Click(button1);
  Button2Click(button2);
  Button3Click(button3);
  Button4Click(button4);
  Button6Click(button6);
  endtime_all:=getTickCount-starttime_all;
  memo1.Append(floattostr(int(endtime_all/1000/60)) + ' mins, ' + floattostr((endtime_all mod 60000)/1000) + ' secs');
  memo1.Append(nl + '-----' + nl);
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  columns, params: TStringList;
begin
  starttime:=getTickCount;
  columns:=TStringList.Create;
  with columns do
  begin
  Add('code');
  Add('description');
  Add('rgb');
  end;
  params:=TStringList.Create;
  with params do
  begin
  Add('rgb');
  Add('(:code, :description, :rgb)');
  end;
procUpdate(button6, columns, datamodule1.queryRGB, params);
end;

procedure TForm1.FormShow(Sender: TObject);
var
  ms, my, sms, smy, dms, dmy: string;
begin
  stamp;
  INI := TINIFile.Create('conf.ini');
  ms:=ini.ReadString('DB', 'ms', '');
  my:=ini.ReadString('DB', 'my', '');
  sms:=ini.ReadString('DB', 'sms', '');
  smy:=ini.ReadString('DB', 'smy', '');
  dms:=ini.ReadString('DB', 'dms', '');
  dmy:=ini.ReadString('DB', 'dmy', '');
  with datamodule1.connMSSQL do
  begin
  Password:=ms;
  HostName:=sms;
  DatabaseName:=dms
  end;
  with datamodule1.connMYSQL do
  begin
  Password:=my;
  HostName:=smy;
  DatabaseName:=dmy;
  end;
  ini.Free;
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
  if savedialog1.Execute then
  Memo1.Lines.SaveToFile(savedialog1.FileName);
end;

procedure TForm1.Label1MouseEnter(Sender: TObject);
begin
  screen.Cursor:=crHandPoint;
end;

procedure TForm1.Label1MouseLeave(Sender: TObject);
begin
  screen.Cursor:=crDefault;
end;

end.

