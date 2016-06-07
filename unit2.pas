unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, mysql55conn, FileUtil;

type

  { TDataModule1 }

  TDataModule1 = class(TDataModule)
    connMSSQL: TSQLConnector;
    connMYSQL: TMySQL55Connection;
    queryBrand: TSQLQuery;
    queryColours: TSQLQuery;
    queryRGB: TSQLQuery;
    queryStyle: TSQLQuery;
    queryMYSQLupdate: TSQLQuery;
    querySizes: TSQLQuery;
    tranMYSQL: TSQLTransaction;
    tranMSSQL: TSQLTransaction;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  DataModule1: TDataModule1;

implementation

{$R *.lfm}

end.

