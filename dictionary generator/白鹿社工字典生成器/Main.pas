unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  Vcl.ComCtrls, Vcl.Mask;

type
  TForm1 = class(TForm)
    grp_A: TGroupBox;
    mmo_A: TMemo;
    grp_B: TGroupBox;
    mmo_B: TMemo;
    rb_B1: TRadioButton;
    rb_B2: TRadioButton;
    grp_C: TGroupBox;
    mmo_C: TMemo;
    rb_C1: TRadioButton;
    rb_C2: TRadioButton;
    chk_A: TCheckBox;
    btn_Run: TButton;
    mmo_Combination: TMemo;
    lbl1: TLabel;
    lbl2: TLabel;
    mmo_Add: TMemo;
    chk_Add1: TCheckBox;
    chk_Add2: TCheckBox;
    chk_Dir_Re: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btn_RunClick(Sender: TObject);
    procedure rb_B1Click(Sender: TObject);
    procedure rb_B2Click(Sender: TObject);
    procedure rb_C1Click(Sender: TObject);
    procedure rb_C2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

  MULTI_FILE_SWITCH: Boolean;  //是否输出多文件开关
  TXT_0X00_SWITCH: Boolean;  //勾选0x00.txt开关
  TXT_0X01_SWITCH: Boolean;  //勾选0x01.txt开关
  TXT_EDIT_SWITCH: Boolean;  //自定义追加是否有内容

  MMO_ADD_TEXT: string;
  RES_PATH: string;  //字典生成目录


implementation

{$R *.dfm}


//追加写文件,将file_1（包含文件名的完整路径）的文本内容追加到file_2之后
Procedure add_File(file_1,file_2: string);
var
  tmpTStr: Tstringlist;
  s:string;
begin
  tmpTStr := TStringList.Create;
  tmpTStr.LoadFromFile(file_1);
  s := tmpTStr.Text;
  tmpTStr.LoadFromFile(file_2);
  s := tmpTStr.Text + s;
  tmpTStr.Text := s;
  tmpTStr.SaveToFile(file_2);
  tmpTStr.Free;
end;


//追加字符串到path文件之后
Procedure strAdd_File(str,path: string);
var
  tmpTStr: Tstringlist;
begin
  tmpTStr := TStringList.Create;
  tmpTStr.LoadFromFile(path);
  tmpTStr.Text := tmpTStr.Text + str;
  tmpTStr.SaveToFile(path);
  tmpTStr.Free;
end;


//检查字符串是否符合Windows命名规则，将不合法的字符替换为下划线
function fileName_Ok(str: string):string;
begin
  if str = '' then
  begin
    str := '_';
  end
  else
  begin
    str := StringReplace(str,' ','_',[rfReplaceAll]);
    str := StringReplace(str,'/','_',[rfReplaceAll]);
    str := StringReplace(str,'\','_',[rfReplaceAll]);
    str := StringReplace(str,':','_',[rfReplaceAll]);
    str := StringReplace(str,'*','_',[rfReplaceAll]);
    str := StringReplace(str,'?','_',[rfReplaceAll]);
    str := StringReplace(str,'<','_',[rfReplaceAll]);
    str := StringReplace(str,'>','_',[rfReplaceAll]);
    str := StringReplace(str,'|','_',[rfReplaceAll]);
    str := StringReplace(str,'"','_',[rfReplaceAll]);
  end;
  Result := str;
end;


//检查一个文件是否存在（不区分大小写），如果不存在则新建
//参数为检查的文件路径（包含文件名）
procedure check_File(fileName: string);
var
  nFile: TextFile;
begin

  if not FileExists(fileName) then
  begin
    AssignFile(nFile,fileName);
    Rewrite(nFile);
    CloseFile(nFile);
  end;

  //检查是否勾选追加字典选项，如果勾选，则先追加字典到该文件
  if TXT_0X00_SWITCH then
  begin
    add_File('Dic\0x00.txt',fileName);
  end;
  if TXT_0X01_SWITCH then
  begin
    add_File('Dic\0x01.txt',fileName);
  end;
  if TXT_EDIT_SWITCH then
  begin
    strAdd_File(MMO_ADD_TEXT,fileName);
  end;
end;


//一位组合函数
//s_Path为保存路径
procedure doCombination_1(str_A: TMemo;s_Path: string);
var
  num_A,len_A1,len_A2: Integer;
  wText: TextFile;
begin
  len_A1 := str_A.Lines.Count;
  len_A2 := len_A1-1;

  check_File(s_Path + 'res.txt');
  AssignFile(wText,s_Path + 'res.txt');
  Append(wText);

  if len_A1 > 0 then
  begin
  for num_A := 0 to len_A2 do
  begin
    Writeln(wText,str_A.Lines[num_A]);
    Application.ProcessMessages;
  end;
  CloseFile(wText);
  end
  else if len_A1 = 0 then
  begin

  end
  else
  begin
    ShowMessage('出现了BUG。');
  end;
end;


//两位组合函数，前两个参数为参与组合的备注框
//s_Path为保存路径
//is_str_A为A项字典的位置，0为字典输出单文件，1为第一个参数为A项，2为第二个参数为A项
procedure doCombination_2(str_A,str_B: TMemo;s_Path: string;is_str_A: Byte);
var
  num_A,num_B,len_A1,len_A2,len_B1,len_B2: Integer;
  wText: TextFile;
begin
  len_A1 := str_A.Lines.Count;
  len_A2 := len_A1-1;
  len_B1 := str_B.Lines.Count;
  len_B2 := len_B1-1;

  if MULTI_FILE_SWITCH = False then
  begin
    is_str_A := 0;
  end;

  case is_str_A of
    0:begin  //没有勾选“按A项的行生成多个文件”
        check_File(s_Path + 'res.txt');
        AssignFile(wText,s_Path + 'res.txt');
        Append(wText);

        if (len_A1 > 0) and (len_B2 > 0) then
        begin
          for num_A := 0 to len_A2 do
          begin
            for num_B := 0 to len_B2 do
            begin
              Writeln(wText,str_A.Lines[num_A] + str_B.Lines[num_B]);
              Application.ProcessMessages;
            end;
          end;
          CloseFile(wText);
        end
        else if (len_A1 = 0) and (len_B1 > 0) then
        begin
          for num_B := 0 to len_B2 do
          begin
            Writeln(wText,str_B.Lines[num_B]);
            Application.ProcessMessages;
          end;
          CloseFile(wText);
        end
        else if (len_A1 > 0) and (len_B1 = 0) then
        begin
          for num_A := 0 to len_A2 do
          begin
            Writeln(wText,str_A.Lines[num_A]);
            Application.ProcessMessages;
          end;
          CloseFile(wText);
        end
        else if (len_A1 = 0) and (len_B1 = 0) then
        begin

        end
        else
        begin
          ShowMessage('出现了BUG。');
        end;
      end;

    1:begin  //A为第一个备注框，按A的行生成多文件
        if (len_A1 > 0) and (len_B2 > 0) then
        begin
          for num_A := 0 to len_A2 do
          begin
            check_File(s_Path + fileName_Ok(str_A.Lines[num_A]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_A.Lines[num_A]) + '.txt');
            Append(wText);

            for num_B := 0 to len_B2 do
            begin
              Writeln(wText,str_A.Lines[num_A] + str_B.Lines[num_B]);
              Application.ProcessMessages;
            end;
            CloseFile(wText);
          end;
        end
        else if (len_A1 = 0) and (len_B1 > 0) then
        begin
          check_File(s_Path + 'res.txt');
          AssignFile(wText,s_Path + 'res.txt');
          Append(wText);

          for num_B := 0 to len_B2 do
          begin
            Writeln(wText,str_B.Lines[num_B]);
            Application.ProcessMessages;
          end;
          CloseFile(wText);
        end
        else if (len_A1 > 0) and (len_B1 = 0) then
        begin
          for num_A := 0 to len_A2 do
          begin
            check_File(s_Path + fileName_Ok(str_A.Lines[num_A]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_A.Lines[num_A]) + '.txt');
            Append(wText);

            Writeln(wText,str_A.Lines[num_A]);

            CloseFile(wText);
            Application.ProcessMessages;
          end;
        end
        else if (len_A1 = 0) and (len_B1 = 0) then
        begin

        end
        else
        begin
          ShowMessage('出现了BUG。');
        end;
      end;

    2:begin  //B为第一个备注框，按B的行生成多个文件
        if (len_A1 > 0) and (len_B2 > 0) then
        begin
          for num_B := 0 to len_B2 do
          begin
            check_File(s_Path + fileName_Ok(str_B.Lines[num_B]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_B.Lines[num_B]) + '.txt');
            Append(wText);

            for num_A := 0 to len_A2 do
            begin
              Writeln(wText,str_A.Lines[num_A] + str_B.Lines[num_B]);
              Application.ProcessMessages;
            end;
            CloseFile(wText);
          end;
        end
        else if (len_A1 = 0) and (len_B1 > 0) then
        begin
          for num_B := 0 to len_B2 do
          begin
            check_File(s_Path + fileName_Ok(str_B.Lines[num_B]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_B.Lines[num_B]) + '.txt');
            Append(wText);

            Writeln(wText,str_B.Lines[num_B]);

            CloseFile(wText);
            Application.ProcessMessages;
          end;
        end
        else if (len_A1 > 0) and (len_B1 = 0) then
        begin
          check_File(s_Path + 'res.txt');
          AssignFile(wText,s_Path + 'res.txt');
          Append(wText);

          for num_A := 0 to len_A2 do
          begin
            Writeln(wText,str_A.Lines[num_A]);
            Application.ProcessMessages;
          end;
          CloseFile(wText);
        end
        else if (len_A1 = 0) and (len_B1 = 0) then
        begin

        end
        else
        begin
          ShowMessage('出现了BUG。');
        end;
      end;
  end;
end;


//三位组合函数，前三个参数为参与组合的备注框
//s_Path为保存路径
//is_str_A为A项字典的位置，0为字典输出单文件，1为第一个参数为A项（备注框），2为第二个参数为A项，3为第三个参数为A项
procedure doCombination_3(str_A,str_B,str_C: TMemo;s_Path: string;is_str_A: Byte);
var
  num_A,num_B,num_C,len_A1,len_A2,len_B1,len_B2,len_C1,len_C2: Integer;
  wText: TextFile;
begin
  len_A1 := str_A.Lines.Count;
  len_A2 := len_A1-1;
  len_B1 := str_B.Lines.Count;
  len_B2 := len_B1-1;
  len_C1 := str_C.Lines.Count;
  len_C2 := len_C1-1;

  if MULTI_FILE_SWITCH = False then
  begin
    is_str_A := 0;
  end;

  case is_str_A of
    0:begin  //没有勾选“按A项的行生成多个文件”
        check_File(s_Path + 'res.txt');
        AssignFile(wText,s_Path + 'res.txt');
        Append(wText);

        if (len_A1 > 0) and (len_B1 > 0) and (len_C1 > 0) then
        begin
          for num_A := 0 to len_A2 do
          begin
            for num_B := 0 to len_B2 do
            begin
              for num_C := 0 to len_C2 do
              begin
                Writeln(wText,str_A.Lines[num_A] + str_B.Lines[num_B] + str_C.Lines[num_C]);
                Application.ProcessMessages;
              end;
            end;
          end;
          CloseFile(wText);
        end
        else if (len_A1 = 0) and (len_B1 > 0) and (len_C1 > 0) then
        begin
          for num_B := 0 to len_B2 do
          begin
            for num_C := 0 to len_C2 do
            begin
              Writeln(wText,str_B.Lines[num_B] + str_C.Lines[num_C]);
              Application.ProcessMessages;
            end;
          end;
          CloseFile(wText);
        end
        else if (len_A1 = 0) and (len_B1 = 0) and (len_C1 > 0) then
        begin
          for num_C := 0 to len_C2 do
          begin
            Writeln(wText,str_C.Lines[num_C]);
            Application.ProcessMessages;
          end;
          CloseFile(wText);
        end
        else if (len_A1 = 0) and (len_B1 > 0) and (len_C1 = 0) then
        begin
          for num_B := 0 to len_B2 do
          begin
            Writeln(wText,str_B.Lines[num_B]);
            Application.ProcessMessages;
          end;
          CloseFile(wText);
        end
        else if (len_A1 > 0) and (len_B1 = 0) and (len_C1 > 0) then
        begin
          for num_A := 0 to len_A2 do
          begin
            for num_C := 0 to len_C2 do
            begin
              Writeln(wText,str_A.Lines[num_A] + str_C.Lines[num_C]);
              Application.ProcessMessages;
            end;
          end;
          CloseFile(wText);
        end
        else if (len_A1 > 0) and (len_B1 = 0) and (len_C1 = 0) then
        begin
          for num_A := 0 to len_A2 do
          begin
            Writeln(wText,str_A.Lines[num_A]);
            Application.ProcessMessages;
          end;
          CloseFile(wText);
        end
        else if (len_A1 = 0) and (len_B1 = 0) and (len_C1 = 0) then
        begin

        end
        else
        begin
          ShowMessage('出现了BUG。');
        end;
      end;

    1:begin  //A为第一个备注框，按A的行生成多文件
        if (len_A1 > 0) and (len_B1 > 0) and (len_C1 > 0) then
        begin
          for num_A := 0 to len_A2 do
          begin
            check_File(s_Path + fileName_Ok(str_A.Lines[num_A]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_A.Lines[num_A]) + '.txt');
            Append(wText);

            for num_B := 0 to len_B2 do
            begin
              for num_C := 0 to len_C2 do
              begin
                Writeln(wText,str_A.Lines[num_A] + str_B.Lines[num_B] + str_C.Lines[num_C]);
                Application.ProcessMessages;
              end;
            end;
            CloseFile(wText);
          end;
        end
        else if (len_A1 = 0) and (len_B1 > 0) and (len_C1 > 0) then
        begin
          check_File(s_Path + 'res.txt');
          AssignFile(wText,s_Path + 'res.txt');
          Append(wText);

          for num_B := 0 to len_B2 do
          begin
            for num_C := 0 to len_C2 do
            begin
              Writeln(wText,str_B.Lines[num_B] + str_C.Lines[num_C]);
              Application.ProcessMessages;
            end;
          end;
          CloseFile(wText);
        end
        else if (len_A1 = 0) and (len_B1 = 0) and (len_C1 > 0) then
        begin
          check_File(s_Path + 'res.txt');
          AssignFile(wText,s_Path + 'res.txt');
          Append(wText);

          for num_C := 0 to len_C2 do
          begin
            Writeln(wText,str_C.Lines[num_C]);
            Application.ProcessMessages;
          end;
          CloseFile(wText);
        end
        else if (len_A1 = 0) and (len_B1 > 0) and (len_C1 = 0) then
        begin
          check_File(s_Path + 'res.txt');
          AssignFile(wText,s_Path + 'res.txt');
          Append(wText);

          for num_B := 0 to len_B2 do
          begin
            Writeln(wText,str_B.Lines[num_B]);
            Application.ProcessMessages;
          end;
          CloseFile(wText);
        end
        else if (len_A1 > 0) and (len_B1 = 0) and (len_C1 > 0) then
        begin
          for num_A := 0 to len_A2 do
          begin
            check_File(s_Path + fileName_Ok(str_A.Lines[num_A]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_A.Lines[num_A]) + '.txt');
            Append(wText);

            for num_C := 0 to len_C2 do
            begin
              Writeln(wText,str_A.Lines[num_A] + str_C.Lines[num_C]);
              Application.ProcessMessages;
            end;
            CloseFile(wText);
          end;
        end
        else if (len_A1 > 0) and (len_B1 = 0) and (len_C1 = 0) then
        begin
          for num_A := 0 to len_A2 do
          begin
            check_File(s_Path + fileName_Ok(str_A.Lines[num_A]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_A.Lines[num_A]) + '.txt');
            Append(wText);

            Writeln(wText,str_A.Lines[num_A]);

            CloseFile(wText);
            Application.ProcessMessages;
          end;
        end
        else if (len_A1 = 0) and (len_B1 = 0) and (len_C1 = 0) then
        begin

        end
        else
        begin
          ShowMessage('出现了BUG。');
        end;
      end;

    2:begin  //B为第一个备注框，按B的行生成多个文件
        if (len_A1 > 0) and (len_B1 > 0) and (len_C1 > 0) then
        begin
          for num_B := 0 to len_B2 do
          begin
            check_File(s_Path + fileName_Ok(str_B.Lines[num_B]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_B.Lines[num_B]) + '.txt');
            Append(wText);

            for num_A := 0 to len_A2 do
            begin
              for num_C := 0 to len_C2 do
              begin
                Writeln(wText,str_A.Lines[num_A] + str_B.Lines[num_B] + str_C.Lines[num_C]);
                Application.ProcessMessages;
              end;
            end;
            CloseFile(wText);
          end;
        end
        else if (len_A1 = 0) and (len_B1 > 0) and (len_C1 > 0) then
        begin
          for num_B := 0 to len_B2 do
          begin
            check_File(s_Path + fileName_Ok(str_B.Lines[num_B]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_B.Lines[num_B]) + '.txt');
            Append(wText);

            for num_C := 0 to len_C2 do
            begin
              Writeln(wText,str_B.Lines[num_B] + str_C.Lines[num_C]);
              Application.ProcessMessages;
            end;
            CloseFile(wText);
          end;
        end
        else if (len_A1 = 0) and (len_B1 = 0) and (len_C1 > 0) then
        begin
          check_File(s_Path + 'res.txt');
          AssignFile(wText,s_Path + 'res.txt');
          Append(wText);

          for num_C := 0 to len_C2 do
          begin
            Writeln(wText,str_C.Lines[num_C]);
            Application.ProcessMessages;
          end;
          CloseFile(wText);
        end
        else if (len_A1 = 0) and (len_B1 > 0) and (len_C1 = 0) then
        begin
          for num_B := 0 to len_B2 do
          begin
            check_File(s_Path + fileName_Ok(str_B.Lines[num_B]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_B.Lines[num_B]) + '.txt');
            Append(wText);

            Writeln(wText,str_B.Lines[num_B]);

            CloseFile(wText);
            Application.ProcessMessages;
          end;
        end
        else if (len_A1 > 0) and (len_B1 = 0) and (len_C1 > 0) then
        begin
          check_File(s_Path + 'res.txt');
          AssignFile(wText,s_Path + 'res.txt');
          Append(wText);

          for num_A := 0 to len_A2 do
          begin
            for num_C := 0 to len_C2 do
            begin
              Writeln(wText,str_A.Lines[num_A] + str_C.Lines[num_C]);
              Application.ProcessMessages;
            end;
          end;
          CloseFile(wText);
        end
        else if (len_A1 > 0) and (len_B1 = 0) and (len_C1 = 0) then
        begin
          check_File(s_Path + 'res.txt');
          AssignFile(wText,s_Path + 'res.txt');
          Append(wText);

          for num_A := 0 to len_A2 do
          begin
            Writeln(wText,str_A.Lines[num_A]);
            Application.ProcessMessages;
          end;
          CloseFile(wText);
        end
        else if (len_A1 = 0) and (len_B1 = 0) and (len_C1 = 0) then
        begin

        end
        else
        begin
          ShowMessage('出现了BUG。');
        end;
      end;

    3:begin  //C为第一个备注框，按C的行生成多个文件
        if (len_A1 > 0) and (len_B1 > 0) and (len_C1 > 0) then
        begin
          for num_C := 0 to len_C2 do
          begin
            check_File(s_Path + fileName_Ok(str_C.Lines[num_C]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_C.Lines[num_C]) + '.txt');
            Append(wText);

            for num_A := 0 to len_A2 do
            begin
              for num_B := 0 to len_B2 do
              begin
                Writeln(wText,str_A.Lines[num_A] + str_B.Lines[num_B] + str_C.Lines[num_C]);
                Application.ProcessMessages;
              end;
            end;
            CloseFile(wText);
          end;
        end
        else if (len_A1 = 0) and (len_B1 > 0) and (len_C1 > 0) then
        begin
          for num_C := 0 to len_C2 do
          begin
            check_File(s_Path + fileName_Ok(str_C.Lines[num_C]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_C.Lines[num_C]) + '.txt');
            Append(wText);

            for num_B := 0 to len_B2 do
            begin
              Writeln(wText,str_B.Lines[num_B] + str_C.Lines[num_C]);
              Application.ProcessMessages;
            end;
            CloseFile(wText);
          end;
        end
        else if (len_A1 = 0) and (len_B1 = 0) and (len_C1 > 0) then
        begin
          for num_C := 0 to len_C2 do
          begin
            check_File(s_Path + fileName_Ok(str_C.Lines[num_C]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_C.Lines[num_C]) + '.txt');
            Append(wText);

            Writeln(wText,str_C.Lines[num_C]);

            CloseFile(wText);
            Application.ProcessMessages;
          end;
        end
        else if (len_A1 = 0) and (len_B1 > 0) and (len_C1 = 0) then
        begin
          check_File(s_Path + 'res.txt');
          AssignFile(wText,s_Path + 'res.txt');
          Append(wText);

          for num_B := 0 to len_B2 do
          begin
            Writeln(wText,str_B.Lines[num_B]);
            Application.ProcessMessages;
          end;
          CloseFile(wText);
        end
        else if (len_A1 > 0) and (len_B1 = 0) and (len_C1 > 0) then
        begin
          for num_C := 0 to len_C2 do
          begin
            check_File(s_Path + fileName_Ok(str_C.Lines[num_C]) + '.txt');
            AssignFile(wText,s_Path + fileName_Ok(str_C.Lines[num_C]) + '.txt');
            Append(wText);

            for num_A := 0 to len_A2 do
            begin
              Writeln(wText,str_A.Lines[num_A] + str_C.Lines[num_C]);
              Application.ProcessMessages;
            end;
            CloseFile(wText);
          end;
        end
        else if (len_A1 > 0) and (len_B1 = 0) and (len_C1 = 0) then
        begin
          check_File(s_Path + 'res.txt');
          AssignFile(wText,s_Path + 'res.txt');
          Append(wText);

          for num_A := 0 to len_A2 do
          begin
            Writeln(wText,str_A.Lines[num_A]);
            Application.ProcessMessages;
          end;
          CloseFile(wText);
        end
        else if (len_A1 = 0) and (len_B1 = 0) and (len_C1 = 0) then
        begin

        end
        else
        begin
          ShowMessage('出现了BUG。');
        end;
      end;
  end;
end;


//字符串处理函数，只保留大写ABC和英文逗号分隔
function com_StrProcess(str: string):string;
var
  i,j: Integer;
  tmpStr: string;
  tmpTStr: TStrings;
begin
  tmpStr := '';
  str := StringReplace(str,chr(13) + chr(10),',',[rfReplaceAll]);
  str := StringReplace(str,'，',',',[rfReplaceAll]);
  str := UpperCase(str);

  for i := 1 to Length(str) do
  begin
    if (str[i] = ',') or (str[i]='A') or (str[i]='B') or (str[i]='C')then
    begin
      tmpStr := tmpStr + str[i];
    end;
  end;

  tmpTStr := TStringList.Create;
  tmpTStr.CommaText := tmpStr;

  tmpStr := '';

  for j := 0 to tmpTStr.Count-1 do
  begin
    if Length(tmpTStr[j]) < 4 then
    begin
      if (j < tmpTStr.Count-1) and (tmpTStr[j] <> '') then
      begin
        tmpStr := tmpStr + tmpTStr[j] +',';
      end
      else
      begin
        tmpStr := tmpStr + tmpTStr[j];
      end;
    end;
  end;

  tmpTStr.Free;

  Result := tmpStr;
end;


//文本文件去除重复行
procedure dup_File(path: string);
var
  s: TStringList;
begin
  s := TStringList.Create;
  s.CaseSensitive := True;
  s.Sorted := True;
  s.Duplicates := dupIgnore;
  s.LoadFromFile(path);
  s.SaveToFile(path);
  s.Free
end;


//查找指定路径（以\结尾）下面的所有文件（不包含目录），并调用文本去重函数去重
procedure  process_File();
var
  SearchRec: TSearchRec;
  found: integer;
begin
  found := FindFirst(RES_PATH + '*.*',faAnyFile,SearchRec);
  while found = 0 do
  begin
    if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and (SearchRec.Attr <> faDirectory) then
    begin
      dup_File(RES_PATH + SearchRec.Name);
      Application.ProcessMessages;
    end;
    found := FindNext(SearchRec);
  end;
  FindClose(SearchRec);

  Form1.btn_Run.Enabled := True;
  Form1.btn_Run.Caption := '生成字典文件';

  ShowMessage('字典生成完成，保存路径：' + #13#10 + RES_PATH);
end;


procedure TForm1.btn_RunClick(Sender: TObject);
var
  conText: TextFile;
  comTStr,comList: TStrings;
  i: Integer;

begin
  btn_Run.Enabled := False;
  btn_Run.Caption := '正在生成字典';

  //创建生成字典的保存目录
  RES_PATH := ExtractFileDir(ParamStr(0)) + '\Res-' + FormatDateTime('yyyymmddhhnnss',Now()) + '\';
  if not DirectoryExists(RES_PATH) then
  begin
    ForceDirectories(RES_PATH);
  end;

  //是否勾选按A项的行生成多文件
  if chk_A.Checked then
  begin
    MULTI_FILE_SWITCH := True;
  end
  else
  begin
    MULTI_FILE_SWITCH := False;
  end;

  //是否勾选追加字典0x00.txt
  if chk_Add1.Checked then
  begin
    TXT_0X00_SWITCH := True;
  end
  else
  begin
    TXT_0X00_SWITCH := False;
  end;

  //是否勾选追加字典0x01.txt
  if chk_Add2.Checked then
  begin
    TXT_0X01_SWITCH := True;
  end
  else
  begin
    TXT_0X01_SWITCH := False;
  end;

  //追加字典自定义编辑框是否有内容
  if mmo_Add.Lines.Count > 0 then
  begin
    TXT_EDIT_SWITCH := True;
    MMO_ADD_TEXT := mmo_Add.Text;
  end
  else
  begin
    TXT_EDIT_SWITCH := False;
  end;

  //保存组合配置
  mmo_Combination.Text := com_StrProcess(mmo_Combination.Text);
  check_File('config.ini');
  AssignFile(conText,'config.ini');
  Rewrite(conText);
  Writeln(conText,mmo_Combination.Text);
  CloseFile(conText);

  comList := TStringList.Create;
  comList.Add('A');
  comList.Add('B');
  comList.Add('C');
  comList.Add('AA');
  comList.Add('AB');
  comList.Add('AC');
  comList.Add('BA');
  comList.Add('BB');
  comList.Add('BC');
  comList.Add('CA');
  comList.Add('CB');
  comList.Add('CC');
  comList.Add('AAA');
  comList.Add('AAB');
  comList.Add('AAC');
  comList.Add('ABA');
  comList.Add('ABB');
  comList.Add('ABC');
  comList.Add('ACA');
  comList.Add('ACB');
  comList.Add('ACC');
  comList.Add('BAA');
  comList.Add('BAB');
  comList.Add('BAC');
  comList.Add('BBA');
  comList.Add('BBB');
  comList.Add('BBC');
  comList.Add('BCA');
  comList.Add('BCB');
  comList.Add('BCC');
  comList.Add('CAA');
  comList.Add('CAB');
  comList.Add('CAC');
  comList.Add('CBA');
  comList.Add('CBB');
  comList.Add('CBC');
  comList.Add('CCA');
  comList.Add('CCB');
  comList.Add('CCC');

  comTStr := TStringList.Create;
  comTStr.CommaText := mmo_Combination.Text;

  for i := 0 to comTStr.Count-1 do
  begin
    case comList.IndexOf(comTStr[i]) of
      0: doCombination_1(mmo_A,RES_PATH);
      1: doCombination_1(mmo_B,RES_PATH);
      2: doCombination_1(mmo_C,RES_PATH);
      3: doCombination_2(mmo_A,mmo_A,RES_PATH,1);
      4: doCombination_2(mmo_A,mmo_B,RES_PATH,1);
      5: doCombination_2(mmo_A,mmo_C,RES_PATH,1);
      6: doCombination_2(mmo_B,mmo_A,RES_PATH,2);
      7: doCombination_2(mmo_B,mmo_B,RES_PATH,0);
      8: doCombination_2(mmo_B,mmo_C,RES_PATH,0);
      9: doCombination_2(mmo_C,mmo_A,RES_PATH,2);
      10: doCombination_2(mmo_C,mmo_B,RES_PATH,0);
      11: doCombination_2(mmo_C,mmo_C,RES_PATH,0);
      12: doCombination_3(mmo_A,mmo_A,mmo_A,RES_PATH,1);
      13: doCombination_3(mmo_A,mmo_A,mmo_B,RES_PATH,1);
      14: doCombination_3(mmo_A,mmo_A,mmo_C,RES_PATH,1);
      15: doCombination_3(mmo_A,mmo_B,mmo_A,RES_PATH,1);
      16: doCombination_3(mmo_A,mmo_B,mmo_B,RES_PATH,1);
      17: doCombination_3(mmo_A,mmo_B,mmo_C,RES_PATH,1);
      18: doCombination_3(mmo_A,mmo_C,mmo_A,RES_PATH,1);
      19: doCombination_3(mmo_A,mmo_C,mmo_B,RES_PATH,1);
      20: doCombination_3(mmo_A,mmo_C,mmo_C,RES_PATH,1);
      21: doCombination_3(mmo_B,mmo_A,mmo_A,RES_PATH,2);
      22: doCombination_3(mmo_B,mmo_A,mmo_B,RES_PATH,2);
      23: doCombination_3(mmo_B,mmo_A,mmo_C,RES_PATH,2);
      24: doCombination_3(mmo_B,mmo_B,mmo_A,RES_PATH,3);
      25: doCombination_3(mmo_B,mmo_B,mmo_B,RES_PATH,0);
      26: doCombination_3(mmo_B,mmo_B,mmo_C,RES_PATH,0);
      27: doCombination_3(mmo_B,mmo_C,mmo_A,RES_PATH,3);
      28: doCombination_3(mmo_B,mmo_C,mmo_B,RES_PATH,0);
      29: doCombination_3(mmo_B,mmo_C,mmo_C,RES_PATH,0);
      30: doCombination_3(mmo_C,mmo_A,mmo_A,RES_PATH,2);
      31: doCombination_3(mmo_C,mmo_A,mmo_B,RES_PATH,2);
      32: doCombination_3(mmo_C,mmo_A,mmo_C,RES_PATH,2);
      33: doCombination_3(mmo_C,mmo_B,mmo_A,RES_PATH,3);
      34: doCombination_3(mmo_C,mmo_B,mmo_B,RES_PATH,0);
      35: doCombination_3(mmo_C,mmo_B,mmo_C,RES_PATH,0);
      36: doCombination_3(mmo_C,mmo_C,mmo_A,RES_PATH,3);
      37: doCombination_3(mmo_C,mmo_C,mmo_B,RES_PATH,0);
      38: doCombination_3(mmo_C,mmo_C,mmo_C,RES_PATH,0);
      else
      begin

      end;
    end;
  end;

  comTStr.Free;
  comList.Free;

  if chk_Dir_Re.Checked then
  begin
    btn_Run.Caption := '正在对结果去重';

    //对本次生成目录下的所有字典去除重复行
    TThread.CreateAnonymousThread(process_File).Start;
  end
  else
  begin
    btn_Run.Enabled := True;
    btn_Run.Caption := '生成字典文件';
    ShowMessage('字典生成完成，保存路径：' + #13#10 + RES_PATH);
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  mmo_Combination.Text := '';
  mmo_Combination.Lines.LoadFromFile('config.ini');

  mmo_B.Text := '';
  mmo_B.Lines.LoadFromFile('Dic\B1.txt');
  rb_B2.ShowHint := False;
  rb_B1.ShowHint := True;
  rb_B1.Hint := '共 ' + IntToStr(mmo_B.Lines.Count) + ' 项';

  mmo_C.Text := '';
  mmo_C.Lines.LoadFromFile('Dic\C1.txt');
  rb_C2.ShowHint := False;
  rb_C1.ShowHint := True;
  rb_C1.Hint := '共 ' + IntToStr(mmo_C.Lines.Count) + ' 项';
end;

procedure TForm1.rb_B1Click(Sender: TObject);
begin
  mmo_B.Text := '';
  mmo_B.Lines.LoadFromFile('Dic\B1.txt');

  rb_B2.ShowHint := False;
  rb_B1.ShowHint := True;
  rb_B1.Hint := '共 ' + IntToStr(mmo_B.Lines.Count) + ' 项';
end;

procedure TForm1.rb_B2Click(Sender: TObject);
begin
  mmo_B.Text := '';
  mmo_B.Lines.LoadFromFile('Dic\B2.txt');

  rb_B1.ShowHint := False;
  rb_B2.ShowHint := True;
  rb_B2.Hint := '共 ' + IntToStr(mmo_B.Lines.Count) + ' 项';
end;

procedure TForm1.rb_C1Click(Sender: TObject);
begin
  mmo_C.Text := '';
  mmo_C.Lines.LoadFromFile('Dic\C1.txt');

  rb_C2.ShowHint := False;
  rb_C1.ShowHint := True;
  rb_C1.Hint := '共 ' + IntToStr(mmo_C.Lines.Count) + ' 项';
end;

procedure TForm1.rb_C2Click(Sender: TObject);
begin
  mmo_C.Text := '';
  mmo_C.Lines.LoadFromFile('Dic\C2.txt');

  rb_C1.ShowHint := False;
  rb_C2.ShowHint := True;
  rb_C2.Hint := '共 ' + IntToStr(mmo_C.Lines.Count) + ' 项';
end;

end.
