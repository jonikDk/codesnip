{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012-2013, Peter Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * Implements a dialogue box that accesses program update web service and
 * reports if a new version of CodeSnip is available.
}


unit FmProgramUpdatesDlg;


interface


uses
  // Delphi
  StdCtrls, Controls, ExtCtrls, Classes,
  // Project
  FmGenericViewDlg, UBaseObjects, Web.UProgramUpdateMgr;


type
  TProgramUpdatesDlg = class(TGenericViewDlg, INoPublicConstruct)
    lblProgram: TLabel;
    btnProgUpdate: TButton;
    lblPreReleaseMsg: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnProgUpdateClick(Sender: TObject);
  strict private
    var
      fProgUpdateMgr: TProgramUpdateMgr;
      fDownloadURL: string;
    procedure CheckProgramUpdates;
  strict protected
    ///  <summary>Triggers checks for updates.</summary>
    ///  <remarks>Called from ancestor class.</remarks>
    procedure AfterShowForm; override;
    procedure ArrangeForm; override;
    procedure InitForm; override;
  public
    class procedure Execute(AOwner: TComponent);
  end;


implementation


uses
  // Delphi
  SysUtils, Forms, ExtActns, Graphics,
  // Project
  UAppInfo, UCtrlArranger, UVersionInfo, Web.UInfo;

{$R *.dfm}


{ TCheckUpdatesDlg }

resourcestring
  sChecking = 'Checking...';
  sProgNeedsUpdating = 'CodeSnip version %s is available.';
  sProgUpToDate = 'CodeSnip is up to date.';

procedure TProgramUpdatesDlg.AfterShowForm;
begin
  Screen.Cursor := crHourGlass;
  try
    CheckProgramUpdates;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TProgramUpdatesDlg.ArrangeForm;
begin
  TCtrlArranger.SetLabelHeight(lblPreReleaseMsg);
  TCtrlArranger.MoveBelow(lblProgram, btnProgUpdate, 12);
  TCtrlArranger.MoveBelow(lblProgram, lblPreReleaseMsg, 8);
  pnlBody.ClientHeight := TCtrlArranger.TotalControlHeight(pnlBody) + 8;
  TCtrlArranger.AlignLefts([lblProgram, btnProgUpdate, lblPreReleaseMsg], 0);
  pnlBody.Width := TCtrlArranger.TotalControlWidth(pnlBody);
  inherited;
end;

procedure TProgramUpdatesDlg.btnProgUpdateClick(Sender: TObject);
var
  BrowseAction: TBrowseURL; // action that displays RSS feed URL in browser
begin
  BrowseAction := TBrowseURL.Create(nil);
  try
    BrowseAction.URL := fDownloadURL;
    BrowseAction.Execute;
  finally
    BrowseAction.Free;
  end;
end;

procedure TProgramUpdatesDlg.CheckProgramUpdates;
var
  LatestVersion: TVersionNumber;
  ThisVersion: TVersionNumber;
begin
  btnProgUpdate.Visible := False;
  lblProgram.Caption := sChecking;
  Application.ProcessMessages;
  fProgUpdateMgr.SignOn(Name);
  LatestVersion := fProgUpdateMgr.LatestProgramVersion;
  ThisVersion := TAppInfo.ProgramReleaseVersion;
  if ThisVersion < LatestVersion then
  begin
    fDownloadURL := fProgUpdateMgr.DownloadURL;
    lblProgram.Caption := Format(sProgNeedsUpdating, [string(LatestVersion)]);
    btnProgUpdate.Visible := True;
  end
  else
  begin
    fDownloadURL := '';
    lblProgram.Caption := sProgUpToDate;
    lblPreReleaseMsg.Visible := True;
  end;
end;

class procedure TProgramUpdatesDlg.Execute(AOwner: TComponent);
begin
  with InternalCreate(AOwner) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TProgramUpdatesDlg.FormCreate(Sender: TObject);
begin
  inherited;
  fProgUpdateMgr := TProgramUpdateMgr.Create;
end;

procedure TProgramUpdatesDlg.FormDestroy(Sender: TObject);
begin
  fProgUpdateMgr.Free;
  inherited;
end;

procedure TProgramUpdatesDlg.InitForm;
begin
  inherited;
  lblPreReleaseMsg.Font.Color := clGrayText;
end;

end.

