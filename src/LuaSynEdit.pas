unit LuaSynEdit;

interface

Uses Classes, Controls, Contnrs, Forms, ComCtrls, TypInfo,
     LuaPas,
     LuaControl,
     SynEdit,
     SynEditHighlighter,
     SynHighlighterMulti,
     SynCompletion,
     SynMacroRecorder,
     SynExportHTML,
     SynHighlighterAny,
     SynHighlighterCpp,
     SynHighlighterCss,
     SynHighlighterHTML,
     SynHighlighterJava,
     SynHighlighterPas,
     SynHighlighterPerl,
     SynHighlighterPHP,
     SynHighlighterSQL,
     SynHighlighterTeX,
     synhighlighterunixshellscript,
     SynHighlighterXML,
     LuaSyn;

function CreateSynEditor(L: Plua_State): Integer; cdecl;

type
    TLuaSynEdit = class(TSynEdit)
         LuaCtl: TLuaControl;

    end;

    // Syntax highLighters
    TLuaSynLuaSyn = class(TSynLuaSyn)
         LuaCtl: TLuaControl;
    end;
    TLuaSynCppSyn = class(TSynCppSyn)
         LuaCtl: TLuaControl;
    end;
    TLuaSynCssSyn = class(TSynCssSyn)
         LuaCtl: TLuaControl;
    end;
    TLuaSynXMLSyn = class(TSynXMLSyn)
         LuaCtl: TLuaControl;
    end;
    TLuaSynUNIXShellScriptSyn = class(TSynUNIXShellScriptSyn)
         LuaCtl: TLuaControl;
    end;
    TLuaSynFreePascalSyn = class(TSynFreePascalSyn)
         LuaCtl: TLuaControl;
    end;
    TLuaSynPHPSyn = class(TSynPHPSyn)
         LuaCtl: TLuaControl;
    end;
    TLuaSynHTMLSyn = class(TSynHTMLSyn)
         LuaCtl: TLuaControl;
    end;
    TLuaSynPerlSyn = class(TSynPerlSyn)
         LuaCtl: TLuaControl;
    end;
    TLuaSynJavaSyn = class(TSynJavaSyn)
         LuaCtl: TLuaControl;
    end;
    TLuaSynTeXSyn = class(TSynTeXSyn)
         LuaCtl: TLuaControl;
    end;
    TLuaSynSQLSyn  = class(TSynSQLSyn)
         LuaCtl: TLuaControl;
    end;
    // other sources
    TLuaSynAnySyn  = class(TSynAnySyn)
         LuaCtl: TLuaControl;
    end;

// ***********************************************

implementation

Uses SysUtils, LuaProperties, Lua, Dialogs, SynEditTypes, SynEditKeyCmds;

function realPos(s:String; x:Integer; w:Integer):Integer;
var i,n:Integer;
begin
     n:=0;
     try
       if s<>'' then
         For i:=0 to x-1 do
           if s[i]=#9 then
            inc(n);
     except
       n:=0;
     end;
     if n>0 then
        x := x - w*n+n;
     result := x;
end;

function WordAtCursor(L: Plua_State): Integer; cdecl;
var
    lSynEdit:TLuaSynEdit;
    CXY:TPoint;
    s:String;
begin
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  CXY := lSynEdit.CaretXY;
  CXY.x := realPos(lSynEdit.LineText,CXY.x,lSynEdit.TabWidth);
  s := lSynEdit.GetWordAtRowCol(CXY);
  if (s<>'') then begin
      lua_pushstring(L,pchar(s));
  end else
      lua_pushnil(L);
  result := 1;
end;

function GetSelectedText(L: Plua_State): Integer; cdecl;
var lSynEdit:TLuaSynEdit;
begin
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  if lSynEdit.SelAvail then
      lua_pushstring(L,pchar(lSynEdit.SelText))
  else
      lua_pushnil(L);
  result := 1;
end;

function TextToLineEnd(L: Plua_State): Integer; cdecl;
var
    lSynEdit:TLuaSynEdit;
    CXY,EXY:TPoint;
    s:String;
begin
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  CXY := lSynEdit.CaretXY;
  EXY := CXY;
  CXY.x := realPos(lSynEdit.LineText, CXY.x, lSynEdit.TabWidth);
  EXY.x := length(lSynEdit.LineText)+1;
  s := lSynEdit.TextBetweenPoints[CXY, EXY];
  if (s<>'') then begin
      lua_pushstring(L,pchar(s));
  end else
      lua_pushnil(L);
  result := 1;
end;

function TextPos(L: Plua_State): Integer; cdecl;
var
    lSynEdit:TLuaSynEdit;
    CXY:TPoint;
begin
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  CXY := lSynEdit.CaretXY;
  CXY.x := realPos(lSynEdit.LineText,CXY.x,lSynEdit.TabWidth);
  lua_pushnumber(L,CXY.x);
  lua_pushnumber(L,CXY.y);
  result := 2;
end;

function CaretPos(L: Plua_State): Integer; cdecl;
var
    lSynEdit:TLuaSynEdit;
    CXY:TPoint;
begin
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  CXY := lSynEdit.CaretXY;
  lua_pushnumber(L,CXY.x);
  lua_pushnumber(L,CXY.y);
  result := 2;
end;

function MouseToCaretPos(L: Plua_State): Integer; cdecl;
var
    lSynEdit:TLuaSynEdit;
    CXY:TPoint;
begin
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  CXY := lSynEdit.LogicalCaretXY ;
  lua_pushnumber(L,CXY.x);
  lua_pushnumber(L,CXY.y);
  result := 2;
end;


function SaveToFile(L: Plua_State): Integer; cdecl;
var
    lSynEdit:TLuaSynEdit;
    fn: String;
begin
  CheckArg(L,2);
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  fn := lua_tostring(L, 2);
  lSynEdit.Lines.SaveToFile(fn);
  result := 0;
end;

function LoadFromFile(L: Plua_State): Integer; cdecl;
var
    lSynEdit:TLuaSynEdit;
    fn: String;
begin
  CheckArg(L,2);
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  fn := lua_tostring(L, 2);
  lSynEdit.Lines.LoadFromFile(fn);
  result := 0;
end;

function SynEditClear(L: Plua_State): Integer; cdecl;
var
  lSynEdit:TLuaSynEdit;
begin
  CheckArg(L, 1);
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  lSynEdit.Lines.Clear;
  Result := 0;
end;

function CommandProcessor(L: Plua_State): Integer; cdecl;
var
  lSynEdit:TLuaSynEdit;
  Command:Longint;
begin
  CheckArg(L, 2);
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  if IdentToEditorCommand(lua_tostring(L,2),Command) then
     lSynEdit.CommandProcessor(TSynEditorCommand(Command),'',nil);
  Result := 0;
end;

function GotoLine(L: Plua_State): Integer; cdecl;
var
  lSynEdit:TLuaSynEdit;
  i:Integer;
begin
  CheckArg(L, 2);
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  i:= trunc(lua_tonumber(L,2));
  lSynEdit.CaretX := 1;
  lSynEdit.CaretY := i;
  lSynEdit.Update;
  lSynEdit.SetFocus;
  Result := 0;
end;

procedure AddToSSSet(var SSSet:TSynSearchOptions; opt:String);
begin
    Include(SSSet,TSynSearchOption(GetEnumValue(TypeInfo(TSynSearchOption),opt)));
end;

function FindReplace(L: Plua_State): Integer; cdecl;
var
    lSynEdit:TLuaSynEdit;
    a,r,act: String;
    CXY: TPoint;
    SSSet: TSynSearchOptions;
    n: Integer;
begin
  CheckArg(L,6);
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  SSSet := [];
  if (lua_isnil(L,2)) then
     a:=''
  else
     a := lua_tostring(L,2);
  if (lua_isnil(L,3)) then
     r := a
  else
     r := lua_tostring(L,3);

  n := lua_gettop(L);
  // assign options
  if lua_istable(L,4) then begin
     lua_pushnil(L);
     while (lua_next(L, 4) <> 0) do begin
        AddToSSSet(SSSet,lua_tostring(L, -1));
        lua_pop(L, 1);
     end;
  end else begin
      if (lua_isstring(L,4)) then begin
         act := lua_tostring(L,4);
         AddToSSSet(SSSet,act);
      end;
  end;

  CXY.x := 0;
  CXY.y := 0;
  CXY.x := trunc(lua_tonumber(L,5));
  CXY.y := trunc(lua_tonumber(L,6));

  lua_pushnumber(L,lSynEdit.SearchReplaceEx( a, r, SSSet, CXY));
  result := 1;
end;

function Info(L: Plua_State): Integer; cdecl;
var
    lSynEdit:TLuaSynEdit;
begin
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  lua_pushnumber(L,lSynEdit.Lines.Count);
  lua_pushnumber(L,length(lSynEdit.Text));
  result := 2;
end;

function SaveToHtml(L: Plua_State): Integer; cdecl;
var
    lSynEdit:TLuaSynEdit;
    lSynExp:TSynExporterHTML;
    fn: String;
begin
  CheckArg(L,3);
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  fn := lua_tostring(L,2);
  if lSynEdit.Highlighter<>nil then begin
     lSynExp := TSynExporterHTML.Create(lSynEdit);
     lSynExp.Highlighter := lSynEdit.Highlighter;
     if lua_istable(L,3) then
        SetPropertiesFromLuaTable(L,lSynExp,3);
     lSynExp.ExportAsText:=true;
     lSynExp.ExportAll(lSynEdit.Lines);
     lSynExp.SaveToFile(fn);
     lSynExp.Free;
  end;
  result := 0;
end;

// **************************************************************
function SaveHLToFile(L: Plua_State): Integer; cdecl;
var
    HL:TSynCustomHighLighter;
    fn: String;
begin
  CheckArg(L,2);
  HL := TSynCustomHighLighter(GetLuaObject(L, 1));
  fn := lua_tostring(L, 2);
  HL.SaveToFile(fn);
  result := 0;
end;

function LoadHLFromFile(L: Plua_State): Integer; cdecl;
var
    HL:TSynCustomHighLighter;
    fn: String;
begin
  CheckArg(L,2);
  HL := TSynCustomHighLighter(GetLuaObject(L, 1));
  fn := lua_tostring(L, 2);
  HL.LoadFromFile(fn);
  result := 0;
end;

procedure HLToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  LuaSetTableFunction(L, Index, 'SaveToFile',SaveHLToFile);
  LuaSetTableFunction(L, Index, 'LoadFromFile',LoadHLFromFile);
  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

function Language(L: Plua_State): Integer; cdecl;
var
    lSynEdit:TLuaSynEdit;
    lng:String;
    anysyn: TLuaSynAnySyn;
    luasyn: TLuaSynLuaSyn;
    cppsyn: TLuaSynCppSyn;
    csssyn: TLuaSynCssSyn;
    xmlsyn: TLuaSynXMLSyn;
    shsyn: TLuaSynUNIXShellScriptSyn;
    fpcsyn: TLuaSynFreePascalSyn;
    phpsyn: TLuaSynPHPSyn;
    htmsyn: TLuaSynHTMLSyn;
    plsyn: TLuaSynPerlSyn;
    javasyn: TLuaSynJavaSyn;
    texsyn: TLuaSynTeXSyn;
    sqlsyn: TLuaSynSQLSyn;
begin
  CheckArg(L,2);
  result := 1;
  lSynEdit := TLuaSynEdit(GetLuaObject(L, 1));
  if lua_isnil(L,2) then begin
     lng := ''
  end else
     lng := UpperCase(lua_tostring(L,2));
  if (lSynEdit.Highlighter<>nil) then
     lSynEdit.Highlighter.Free;
  if lng='LUA' then begin
         luasyn := TLuaSynLuaSyn.Create(lSynEdit);
         luasyn.LuaCtl := TLuaControl.Create(luasyn,L, @HLToTable);
         lSynEdit.Highlighter := luasyn;
         HlToTable(L, -1, luasyn);
  end else
  if (lng='C') or (lng='CPP') or (lng='H') or (lng='HPP') or (lng='C++') or (lng='HH') then begin
         cppsyn := TLuaSynCppSyn.Create(lSynEdit);
         cppsyn.LuaCtl := TLuaControl.Create(cppsyn,L, @HLToTable);
         lSynEdit.Highlighter := cppsyn;
         HlToTable(L, -1, cppsyn);
  end else
  if (lng='XML') or (lng='XSD') or (lng='XSL') or (lng='XSLT') or (lng='DTD') then begin
         xmlsyn := TLuaSynXMLSyn.Create(lSynEdit);
         xmlsyn.LuaCtl := TLuaControl.Create(xmlsyn,L, @HLToTable);
         lSynEdit.Highlighter := xmlsyn;
         HlToTable(L, -1, xmlsyn);
  end else
  if (lng='SHELL') or (lng='SH') or (lng='CSH') or (lng='KSH') or (lng='BASH') then begin
         shsyn := TLuaSynUNIXShellScriptSyn.Create(lSynEdit);
         shsyn.LuaCtl := TLuaControl.Create(shsyn,L, @HLToTable);
         lSynEdit.Highlighter := shsyn;
         HlToTable(L, -1, shsyn);
  end else
  if (lng='PAS') or (lng='FPC') then begin
         fpcsyn := TLuaSynFreePascalSyn.Create(lSynEdit);
         fpcsyn.LuaCtl := TLuaControl.Create(fpcsyn,L, @HLToTable);
         lSynEdit.Highlighter := fpcsyn;
         HlToTable(L, -1, fpcsyn);
  end else
  if (lng='PHP') or (lng='PHTML') then begin
         phpsyn := TLuaSynPHPSyn.Create(lSynEdit);
         phpsyn.LuaCtl := TLuaControl.Create(phpsyn,L, @HLToTable);
         lSynEdit.Highlighter := phpsyn;
         HlToTable(L, -1, phpsyn);
  end else
  if (lng='HTM') or (lng='HTML') then begin
         htmsyn := TLuaSynHTMLSyn.Create(lSynEdit);
         htmsyn.LuaCtl := TLuaControl.Create(htmsyn,L, @HLToTable);
         lSynEdit.Highlighter := htmsyn;
         HlToTable(L, -1, htmsyn);
  end else
  if (lng='PL') or (lng='PERL') or (lng='PM') or (lng='CGI') then begin
         plsyn := TLuaSynPerlSyn.Create(lSynEdit);
         plsyn.LuaCtl := TLuaControl.Create(plsyn,L, @HLToTable);
         lSynEdit.Highlighter := plsyn;
         HlToTable(L, -1, plsyn);
  end else
  if lng='CSS' then begin
         csssyn := TLuaSynCssSyn.Create(lSynEdit);
         csssyn.LuaCtl := TLuaControl.Create(csssyn,L, @HLToTable);
         lSynEdit.Highlighter := csssyn;
         HlToTable(L, -1, csssyn);
  end else
  if lng='JAVA' then begin
         javasyn := TLuaSynJavaSyn.Create(lSynEdit);
         javasyn.LuaCtl := TLuaControl.Create(javasyn,L, @HLToTable);
         lSynEdit.Highlighter := javasyn;
         HlToTable(L, -1, javasyn);
  end else
  if lng='TEX' then begin
         texsyn := TLuaSynTeXSyn.Create(lSynEdit);
         texsyn.LuaCtl := TLuaControl.Create(texsyn,L, @HLToTable);
         lSynEdit.Highlighter := texsyn;
         HlToTable(L, -1, texsyn);
  end else
  if lng='SQL' then begin
         sqlsyn := TLuaSynSQLSyn.Create(lSynEdit);
         sqlsyn.LuaCtl := TLuaControl.Create(sqlsyn,L, @HLToTable);
         lSynEdit.Highlighter := sqlsyn;
         HlToTable(L, -1, sqlsyn);
  end else begin
      anysyn := TLuaSynAnySyn.Create(lSynEdit);
      anysyn.LuaCtl := TLuaControl.Create(anysyn,L, @HLToTable);
      lSynEdit.Highlighter := anysyn;
      HlToTable(L, -1, anysyn);
  end;
end;

procedure ToTable(L:Plua_State; Index:Integer; Sender:TObject);
begin
  SetDefaultMethods(L, Index, Sender);
  SetAnchorMethods(L,Index,Sender);
  SetStringListMethods(L,Index,Sender);

  LuaSetTableFunction(L, index, 'FindReplace', FindReplace);
  LuaSetTableFunction(L, index, 'WordAtCursor', WordAtCursor);
  LuaSetTableFunction(L, index, 'Get', GetSelectedText);
  LuaSetTableFunction(L, index, 'GetSelectedText', GetSelectedText);
  LuaSetTableFunction(L, index, 'TextToLineEnd', TextToLineEnd);
  LuaSetTableFunction(L, index, 'TextPos', TextPos);
  LuaSetTableFunction(L, index, 'CaretPos', CaretPos);
  LuaSetTableFunction(L, index, 'MouseToCaretPos', MouseToCaretPos);
  LuaSetTableFunction(L, Index, 'SaveToFile',SaveToFile);
  LuaSetTableFunction(L, Index, 'SaveToHtml',SaveToHtml);
  LuaSetTableFunction(L, Index, 'LoadFromFile',LoadFromFile);
  LuaSetTableFunction(L, Index, 'Clear',SynEditClear);
  LuaSetTableFunction(L, Index, 'CommandProcessor',CommandProcessor);
  LuaSetTableFunction(L, Index, 'GotoLine',GotoLine);
  LuaSetTableFunction(L, Index, 'Info',Info);
  LuaSetTableFunction(L, Index, 'SetLang',Language);

  LuaSetMetaFunction(L, index, '__index', LuaGetProperty);
  LuaSetMetaFunction(L, index, '__newindex', LuaSetProperty);
end;

function CreateSynEditor(L: Plua_State): Integer; cdecl;
var
  lSynEdit:TLuaSynEdit;
  // lLuaComp:TSynCompletion;
  // lLuaMac:TSynMacroRecorder;
  anysyn: TLuaSynAnySyn;
  Parent:TComponent;
  Name:String;
begin
  GetControlParents(L,Parent,Name);
  lSynEdit := TLuaSynEdit.Create(Parent);
  lSynEdit.Parent := TWinControl(Parent);
  lSynEdit.LuaCtl := TLuaControl.Create(lSynEdit,L, @ToTable);
  // move to top!
  lSynEdit.LuaCtl.ComponentIndex:=0;

  // lLuaComp:= TSynCompletion.Create(lSynEdit);
  // lLuaMac := TSynMacroRecorder.Create(lSynEdit);

  lSynEdit.Gutter.Visible:=false;
  lSynEdit.TabWidth:=5;
  lSynEdit.Lines.Clear;

  anysyn := TLuaSynAnySyn.Create(lSynEdit);

  anysyn.LuaCtl := TLuaControl.Create(anysyn,L, @HLToTable);
  lSynEdit.Highlighter := anysyn;
  if (lua_gettop(L)>0) and (GetLuaObject(L, -1) = nil) then
     SetPropertiesFromLuaTable(L, TObject(lSynEdit),-1)
  else 
     lSynEdit.Name := Name;
  ToTable(L, -1, lSynEdit);
  Result := 1;
end;

end.

