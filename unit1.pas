unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, mysql55conn, mssqlconn, FileUtil,
  Forms, Controls, Graphics, Dialogs, DbCtrls, StdCtrls, ExtCtrls, unit2, inifiles, windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    brands: TButton;
    pricing: TButton;
    accreditation: TButton;
    colours: TButton;
    style: TButton;
    sizes: TButton;
    runall: TButton;
    rgb: TButton;
    category: TButton;
    supplier: TButton;
    crossref: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Image1: TImage;
    Label1: TLabel;
    Memo1: TMemo;
    SaveDialog1: TSaveDialog;
    procedure pricingClick(Sender: TObject);
    procedure accreditationClick(Sender: TObject);
    procedure brandsClick(Sender: TObject);
    procedure coloursClick(Sender: TObject);
    procedure styleClick(Sender: TObject);
    procedure sizesClick(Sender: TObject);
    procedure runallClick(Sender: TObject);
    procedure rgbClick(Sender: TObject);
    procedure categoryClick(Sender: TObject);
    procedure supplierClick(Sender: TObject);
    procedure crossrefClick(Sender: TObject);
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
  ButtonName: TButton;

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
  final: string = '';
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
  datamodule1.queryMYSQLupdate.SQL.Text := 'replace into ' + params[0] + ' values ';
  while (not select.EOF) do begin
    for i := 0 to columns.Count - 1 do
    begin
      out := out + ',''' +  select.FieldByName(columns[i]).AsString + '''';
    end;
    out := Copy(out,2,length(out));
    if ( select.RecNo = 1 ) OR ( select.RecNo mod 1000 = 0 ) then
       out := '(' + out + ')'
    else
       out := ',(' + out + ')';
    datamodule1.queryMYSQLupdate.SQL.Add(out);
    memo1.Append('updating ' + columns.CommaText + ' with ' + out);
    out:='';
    select.Next;
    if (select.RecNo mod 10 = 0) then application.ProcessMessages;
    if select.RecNo mod 1000 = 0 then
    begin
        datamodule1.queryMYSQLupdate.ExecSQL;
        datamodule1.tranMYSQL.Commit;
        datamodule1.queryMYSQLupdate.SQL.Text := 'replace into ' + params[0] + ' values ';
    end;
  end;
  datamodule1.queryMYSQLupdate.ExecSQL;
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

procedure TForm1.brandsClick(Sender: TObject);
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
  procUpdate(brands, columns, datamodule1.queryBrand, params);
  columns.Free;
  params.Free;
end;

procedure TForm1.coloursClick(Sender: TObject);
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
  procUpdate(colours, columns, datamodule1.queryColours, params);
  columns.Free;
  params.Free;
end;

procedure TForm1.styleClick(Sender: TObject);
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
    Add('D6');
    Add('D7');
    Add('D8');
    Add('D9');
    Add('D10');
    Add('D11');
    Add('D12');
    Add('Price');
    Add('Producer');
    Add('Category');
    Add('Weight');
  end;
  params:=TStringList.Create;
  with params do
  begin
    Add('style');
    Add('(:CODE, :description, :fabric, :d1, :d2, :d3, :d4, :d5, :d6, :d7, :d8, :d9, :d10, :d11, :d12, :price, :producer, :category, :weight)');
  end;
  procUpdate(style, columns, datamodule1.queryStyle, params);
  columns.Free;
  params.Free;
end;

procedure TForm1.sizesClick(Sender: TObject);
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
procUpdate(sizes, columns, datamodule1.querySizes, params);
columns.Free;
params.Free;
end;

procedure TForm1.runallClick(Sender: TObject);
var
  starttime_all, endtime_all: integer;
begin
  starttime:=getTickCount;
  starttime_all:=getTickCount;
  brandsClick(brands);
  coloursClick(colours);
  styleClick(style);
  sizesClick(sizes);
  rgbClick(rgb);
  categoryClick(category);
  supplierClick(supplier);
  crossrefClick(crossref);
  pricingClick(pricing);
  accreditationClick(accreditation);
  endtime_all:=getTickCount-starttime_all;
  memo1.Append(floattostr(int(endtime_all/1000/60)) + ' mins, ' + floattostr((endtime_all mod 60000)/1000) + ' secs');
  memo1.Append(nl + '-----' + nl);
end;

procedure TForm1.rgbClick(Sender: TObject);
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
procUpdate(rgb, columns, datamodule1.queryRGB, params);
end;

procedure TForm1.categoryClick(Sender: TObject);
var
  columns, params: TStringList;
  errors: integer;
begin
  starttime:=getTickCount;
  columns:=TStringList.Create;
  with columns do
  begin
  Add('category');
  Add('catname');
  Add('pic');
  Add('rank');
  end;
  params:=TStringList.Create;
  with params do
  begin
  Add('tmp_cat');
  Add('(:category, :catname, :pic, :rank)');
  end;
procUpdate(category, columns, datamodule1.queryCategory, params);
datamodule1.connMYSQL.ExecuteDirect('truncate table new_cat;');
datamodule1.connMYSQL.ExecuteDirect('insert into new_cat SELECT tc.CATEGORY, tc.CATNAME, tc.PIC, ifnull(c.RANK, 99999) as RANK FROM tmp_cat tc left join category c on tc.category = c.category;');
datamodule1.tranMYSQL.Commit;
datamodule1.queryMYSQLupdate.SQL.Text:='select count(*) as ERRORS from new_cat where rank = 99999;';
datamodule1.queryMYSQLupdate.Open;
datamodule1.queryMYSQLupdate.First;
errors:=datamodule1.queryMYSQLupdate.FieldByName('ERRORS').AsInteger;
if errors > 0 then
begin
memo1.Append('There are ' + inttostr(errors) + ' errors.' + nl);
memo1.Append('Please update 99999s in new_cat to correct rank and write to category table manually.');
end
else
begin
datamodule1.connMYSQL.ExecuteDirect('truncate table category;');
datamodule1.connMYSQL.ExecuteDirect('insert into category select * from new_cat;');
datamodule1.tranMYSQL.Commit;
end;
datamodule1.queryMYSQLupdate.Close;
end;

procedure TForm1.supplierClick(Sender: TObject);
var
  columns, params: TStringList;
begin
  starttime:=getTickCount;
  columns:=TStringList.Create;
  with columns do
  begin
  Add('PRODUCER');
  Add('PRODNAME');
  end;
  params:=TStringList.Create;
  with params do
  begin
  Add('producer');
  Add('(:PRODUCER, :PRODNAME)');
  end;
procUpdate(supplier, columns, datamodule1.querySupplier, params);
columns.Free;
params.Free;
end;

procedure TForm1.crossrefClick(Sender: TObject);
var
  columns, params: TStringList;
begin
  starttime:=getTickCount;
  columns:=TStringList.Create;
  with columns do
  begin
  Add('style');
  Add('catalogue_code');
  end;
  params:=TStringList.Create;
  with params do
  begin
  Add('catalogue_code');
  Add('(:style, :catalogue_code)');
  end;
procUpdate(crossref, columns, datamodule1.queryCross, params);
columns.Free;
params.Free;
end;

procedure TForm1.pricingClick(Sender: TObject);
var
  columns, params: TStringList;
begin
  starttime:=getTickCount;
  columns:=TStringList.Create;
  with columns do
  begin
  Add('Style');
  Add('Size');
  Add('Colour');
  Add('CTN');
  Add('PCK');
  Add('SNG');
  Add('Rank');
  end;
  params:=TStringList.Create;
  with params do
  begin
  Add('pricing');
  Add('(:Style, :Size, :Colour, :CTN, :PCK, :SNG, :Rank)');
  end;
procUpdate(pricing, columns, datamodule1.queryPrice, params);
columns.Free;
params.Free;
end;

procedure TForm1.accreditationClick(Sender: TObject);
var
  columns, params: TStringList;
begin
  starttime:=getTickCount;
  columns:=TStringList.Create;
  with columns do
  begin
  Add('style');
  Add('logo');
  end;
  params:=TStringList.Create;
  with params do
  begin
  Add('accreditation');
  Add('(:style, :logo)');
  end;
procUpdate(accreditation, columns, datamodule1.queryAccreditation, params);
columns.Free;
params.Free;
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

