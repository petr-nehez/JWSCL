{
Description
Project JEDI Windows Security Code Library (JWSCL)

Provides access to credentials tools functions

Author
Christian Wimmer

License
The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy of the
License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
ANY KIND, either express or implied. See the License for the specific language governing rights
and limitations under the License.

Alternatively, the contents of this file may be used under the terms of the
GNU Lesser General Public License (the  "LGPL License"), in which case the
provisions of the LGPL License are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the LGPL License and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting  the provisions above and
replace  them with the notice and other provisions required by the LGPL
License.  If you do not delete the provisions above, a recipient may use
your version of this file under either the MPL or the LGPL License.

For more information about the LGPL: http://www.gnu.org/copyleft/lesser.html

Note
The Original Code is JwsclCredentials.pas.

The Initial Developer of the Original Code is Christian Wimmer.
Portions created by Christian Wimmer are Copyright (C) Christian Wimmer. All rights reserved.

Version
The following values are automatically injected by Subversion on commit.
<table>
\Description                                                        Value
------------------------------------------------------------------  ------------
Last known date the file has changed in the repository              \$Date: 2010-11-14 15:40:34 +0000 (Sun, 14 Nov 2010) $
Last known revision number the file has changed in the repository   \$Revision: 1059 $
Last known author who changed the file in the repository.           \$Author: dezipaitor $
Full URL to the latest version of the file in the repository.       \$HeadURL: file:///svn/p/jedi-apilib/code/jwscl/trunk/source/JwsclCredentials.pas $
</table>
}
{$IFNDEF SL_OMIT_SECTIONS}
unit JwsclCredentials;
{$INCLUDE ..\includes\Jwscl.inc}


interface

uses SysUtils,
  Graphics {includes Windows, SysUtils, Classes},
  jwaWindows,
  JwsclResource,
  JwsclTypes, JwsclExceptions, JwsclSid, JwsclAcl,
  JwsclVersion, JwsclConstants,
  JwsclStrings; //JwsclStrings, must be at the end of uses list!!!

{$ENDIF SL_OMIT_SECTIONS}
{$IFNDEF SL_IMPLEMENTATION_SECTION}

type

  TJwCredentialsPrompt = class;

     {<B>TJwOnConfirmCredential</B> is a callback method that is called if the flag cfFlagsExpectConfirmation is set.
      It is used to verify the input by the application.
      To verify the inputs one can use the properties in parameter Dialog.

      @param Dialog is a pointer to the instance that calls that callback method.
      @param bConfirm [in, out] defines whether the user input is valid (true) or not (false).
          If set to true, the data can be stored into the credential store.
          The parameter value is also used as the result value in TJwCredentialsTools.ShowModal.
          The default in-value is true.
      }
  TJwOnConfirmCredential = procedure(const Dialog: TJwCredentialsPrompt;
    var bConfirm: boolean) of object;

     {<B>TJwCredentialsTools</B> provides static methods to maniplute credential values.
     }
  TJwCredentialsTools = class
  public
       {<B>ParseUserName</B> splits a fully qualified name into domain and username.
        See CredUIParseUserName (http://msdn2.microsoft.com/en-us/library/aa375175.aspx)

        @param Input [in] gets a fully qualified name to be parsed.
        @param User [out] receives the username
        @param Domain [out] receives the domain name. If Input specifies a certificate, the parameter is empty.

        raises
 EJwsclInvalidParameterException:  will be raised if the username is not valid.
         EJwsclInvalidParameterException: will be raised if the allocated buffer for user or password buffer is to small.
                Currently the buffer is limited to 500 (wide-) characters.
       }
    class procedure ParseUserName(Input: TJwString;
      out User, Domain: TJwString);
  end;

  {<B>TJwCredentialsPrompt</B> provides methods and properties to create a credential command prompt under Windows XP.}
  TJwCredentialsPrompt = class
  protected
    fMessageText, fCaption: TJwString;
    fParentWindow: HWND;
    fBanner: Graphics.TBitmap;

    fMaxUserNameLength, fMaxPasswordLength: Cardinal;

    fAuthError: Cardinal;

    fServerName, fUserName, fPassword: TJwString;
    fSaveCheck: boolean;

    fFlags: TJwCredentialFlagSet;

    fOnConfirmCredential: TJwOnConfirmCredential;

    procedure SetServerName(Name: TJwString);

  public
       {<B>Create</B> creates an credential prompt instance.
        raises
 EJwsclUnsupportedWindowsVersionException:  if the credential prompt api is not available on the system.}
    constructor Create();

       {<B>Destroy</B> frees the instance.
        It also clears UserName and Password in a secure way by overwriting it with zeros.}
    destructor Destroy; override;

    {<B>MessageText</B> receives a text that is displayed in the dialog}
    property MessageText: TJwString Read fMessageText Write fMessageText;
    {<B>Caption</B> receives a text that is displayed in the caption bar of the dialog}
    property Caption: TJwString Read fCaption Write fCaption;
    {<B>ParentWindow</B> receives the parent handle. It is automatically set to the active window.}
    property ParentWindow: HWND Read fParentWindow Write fParentWindow;
    {<B>Banner</B> receives a banner bitmap that is displayed in the dialog}
    property Banner: Graphics.TBitmap Read fBanner Write fBanner;

    {<B>AuthError</B> receives an NTERROR value that is used by the credential dialog to perfom actions.}
    property AuthError: Cardinal Read fAuthError Write fAuthError;

    {<B>ServerName</B> receives a servername. This value must not be empty otherwise EJwsclInvalidParameterException will be raised!}
    property ServerName: TJwString Read fServerName Write SetServerName;

       {<B>UserName</B> sets and gets the username that will be displayed in the prompt.
        It is automatically reset to the users input string if the the prompt is not cancelled.
        The username will be secure deleted on instance freeing.
        }
    property UserName: TJwString Read fUserName Write fUserName;
       {<B>Password</B> sets and gets the password that will be displayed in the prompt.
       It is automatically reset to the users input string if the the prompt is not cancelled.
        The username will be secure deleted on instance freeing.
       }
    property Password: TJwString Read fPassword Write fPassword;

     {<B>MaxUserNameLength</B> sets or gets the maximum (input) length of the username.
      This value is CRED_MAX_USERNAME_LENGTH (513) by default;

      This property is ignored. For more information see remarks section of method ShowModal.
      }
    property MaxUserNameLength: Cardinal
      Read fMaxUserNameLength write fMaxUserNameLength;

       {<B>MaxPasswordLength</B> sets or gets the maximum (input) length of the password.
        This value is CREDUI_MAX_PASSWORD_LENGTH (256) by default;

        This property is ignored. For more information see remarks section of method ShowModal.
        }
    property MaxPasswordLength: Cardinal
      Read fMaxPasswordLength write fMaxPasswordLength;

       {<B>SaveCheck</B> sets or gets the save checkbox state.
         It is automatically reset to the checkbox state in the prompt.
        }
    property SaveCheck: boolean Read fSaveCheck Write fSaveCheck;

       {<B>Flags</B> sets or gets the flags for the credential prompt.
        See MSDN (http://msdn2.microsoft.com/en-us/library/aa375171.aspx) for more information.
        Some flags are mutualyl exclusive.
        If the flag cfFlagsExpectConfirmation is set you must define property OnConfirmCredential
        }
    property Flags: TJwCredentialFlagSet Read fFlags Write fFlags;

       {<B>OnConfirmCredential</B> sets or gets a credential confirmation callback method that is called if the
        flag cfFlagsExpectConfirmation is set. In this case <B>OnConfirmCredential</B> must not be nil!
        }
    property OnConfirmCredential: TJwOnConfirmCredential
      Read fOnConfirmCredential Write fOnConfirmCredential;

       { <b>ShowModal</b> displays a GUI or console credential promp.t
         Parameters
         CommandLine :  If set to true, the commandline version of credential prompt is used. Read the Remarks section to get
                        more information.
         Exceptions
         EJwsclInvalidFlagsException :      will be raised if the flag cfFlagsExpectConfirmation is set but
                                            OnConfirmCredential is nil. will raised if fhe property Flags is invalid! This
                                            message comes from a winapi call and does not contain more information
         EJwsclInvalidParameterException :  will be raised if
                                            * Length of Servername exceeds CREDUI_MAX_DOMAIN_TARGET_LENGTH
                                            * Length of Servername is zero
                                            * Length of property Username is greater than CRED_MAX_USERNAME_LENGTH ( 513)
                                            * Length of property Password is greater than CREDUI_MAX_PASSWORD_LENGTH (256)
                                            * One or more parameters of CredUIPromptForCredentials are invalid! This also
                                              happens if the user enters a username or password that is greater than
                                              CREDUI_MAX_PASSWORD_LENGTH or CREDUI_MAX_PASSWORD_LENGTH. This error comes from
                                              the WinAPI call itself.
         EJwsclNoSuchLogonSession :         will raised if there is no such logon session! This message comes from a winapi
                                            call and does not contain more information<p />
         Returns
         <b>ShowModal</b> returns true if the credential prompt was closed by OK; otherwise false. If OnConfirmCredential is
         not nil, the parameter bConfirm will be used as the result.
         The method will also return false if CommandLine is true, property Flags contains cfFlagsRequireSmartCard (also implicitly :
          see Remarks) and there are no smartcards in the system.
         Remarks
         MaxUserNameLength and MaxPasswordLength are obsolete and are ignored. For more information see Bugs section.



         If parameter CommandLine is true, the property Flags must contain either cfFlagsRequireSmartCard or
         cfFlagsExcludeCertificates. If none is given, JWSCL will assume cfFlagsExcludeCertificates. If both flags are given,
         the flag cfFlagsExcludeCertificates will be removed for the call.



         Be aware, if parameter CommandLine is true, that the Flags are constricted more. For more information read the
         \Remarks section of CredUICmdLinePromptForCredentials in MSDN.
         Bugs
         To the MSDN doc of CredUIPromptForCredentials (http://msdn.microsoft.com/en-us/library/aa375171%28VS.85%29.aspx) the
         function truncates the output string to the maximum given length.

         However, in tests the function returned an error 87 (ERROR_INVALID_PARAMETER) in such a case instead. Thus the
         Username and Password properties can receive CRED_MAX_USERNAME_LENGTH and CREDUI_MAX_PASSWORD_LENGTH chars now.      }
    function ShowModal(const CommandLine: boolean = False): boolean;

       {<B>ParseInstanceUserName</B> parses the property UserName into the user and domain.

        See TJwCredentialsTools.ParseUserName for more information.
       }
    procedure ParseInstanceUserName(out User, Domain: TJwString);



  end;



{$ENDIF SL_IMPLEMENTATION_SECTION}

{$IFNDEF SL_OMIT_SECTIONS}
implementation
uses JwsclEnumerations, JwsclUtils, JwsclComUtils;


{$ENDIF SL_OMIT_SECTIONS}

{$IFNDEF SL_INTERFACE_SECTION}


{ TJwCredentialsPrompt }

class procedure TJwCredentialsTools.ParseUserName(Input: TJwString;
  out User, Domain: TJwString);
var
  Result: Cardinal;
  pUser, pDomain: TJwPChar;
const
  Len = 500 * sizeof(TJwChar);
begin
  User := '';
  Domain := '';

  pUser := TJwPChar(LocalAlloc(LMEM_ZEROINIT, Len));
  pDomain := TJwPChar(LocalAlloc(LMEM_ZEROINIT, Len));

  if ((pos('@', Input) = 0) and (pos('\', Input) = 0)) then
    Input := RsCredentialsLocalName+'\' + Input;


  Result :=
  {$IFDEF UNICODE}
      CredUIParseUserNameW
  {$ELSE}
    CredUIParseUserNameA
  {$ENDIF}
    (TJwPChar(Input), //PCTSTR pszUserName,
    TJwPChar(pUser), //PTSTR pszUser,
    Len, //ULONG ulUserMaxChars,
    TJwPChar(pDomain), //PTSTR pszDomain,
    Len  //ULONG ulDomainMaxChars
    );

  if (Result <> NO_ERROR) then
  begin
    LocalFree(HLOCAL(pUser));
    LocalFree(HLOCAL(pDomain));
    case Result of
      ERROR_INVALID_PARAMETER:
        raise EJwsclInvalidParameterException.CreateFmtEx(
          RsUNCredentialsInvalidParameters,
          'ParseUserName', ClassName, RsUNCredentials, 0, True, []);
      ERROR_INVALID_ACCOUNT_NAME:
        raise EJwsclInvalidParameterException.CreateFmtEx(
          RsUNCredentialsInvalidUserName, 'ParseUserName', ClassName, RsUNCredentials,
          0, True, []);
      ERROR_INSUFFICIENT_BUFFER:
        raise EJwsclInvalidParameterException.CreateFmtEx(
          RsUNCredentialsTooSmallBuffer, 'ParseUserName', ClassName,
          RsUNCredentials, 0, True, []);
    end;

    exit;
  end;

  {$IFDEF UNICODE}
      SetLength(User,Len);
  {$ELSE}
  SetLength(User, StrLen(pUser));
  {$ENDIF}
  User := TJwString(pUser);

  {$IFDEF UNICODE}
      SetLength(Domain,Len);
  {$ELSE}
  SetLength(Domain, StrLen(pDomain));
  {$ENDIF}

  Domain := TJwString(pDomain);

end;



constructor TJwCredentialsPrompt.Create;
var
  _CredUIPromptForCredentials: Pointer;
begin
  fMessageText := RsUNCredentialsMessageTextDefault;
  fCaption := RsUNCredentialsCaptionDefault;
  fParentWindow := GetActiveWindow;
  fBanner  := nil;

  fAuthError := 0;

  fServerName := RsUNCredentialsLocalServerNameDefault;
  fUserName  := '';
  fPassword  := '';
  fSaveCheck := False;

  fMaxUserNameLength := CREDUI_MAX_USERNAME_LENGTH;
  fMaxPasswordLength := CREDUI_MAX_PASSWORD_LENGTH;

  fFlags := [cfFlagsAlwaysShowUi,
    cfFlagsGenericCredentials];

  _CredUIPromptForCredentials := nil;
  try
    GetProcedureAddress(_CredUIPromptForCredentials, credui,
      'CredUIPromptForCredentialsA');
  except
  end;

  if _CredUIPromptForCredentials = nil then
    raise EJwsclUnsupportedWindowsVersionException.CreateFmtEx(
      RsUNCredentialsUnsupported,
      'Create', ClassName, RsUNCredentials, 0, False, []);
end;

destructor TJwCredentialsPrompt.Destroy;
var
  i: integer;
begin
  //overwrite the password and username with zeroes
  for i := 1 to Length(fPassword) do
    fPassword[i] := '0';
  fPassword := '';

  for i := 1 to Length(fUserName) do
    fUserName[i] := '0';

  fUserName := '';
end;


procedure TJwCredentialsPrompt.ParseInstanceUserName(
  out User, Domain: TJwString);
begin
  TJwCredentialsTools.ParseUserName(UserName, User, Domain);
end;




procedure TJwCredentialsPrompt.SetServerName(Name: TJwString);
begin
  if Length(Name) = 0 then
    raise EJwsclInvalidParameterException.CreateFmtEx(
      RsUNCredentialsInvalidEmptyServerName, 'SetServerName', ClassName,
      RsUNCredentials, 0, False, []);

  fServerName := Name;
end;

function TJwCredentialsPrompt.ShowModal(const CommandLine: boolean): boolean;
var
  info: {$IFDEF UNICODE}TCredUIInfoW{$ELSE}TCredUIInfoA{$ENDIF}
  ;
  aBool: longbool;
  pUser, pPass: TJwPChar;
  hRes : HRESULT;
  lResult: Cardinal;

  bConfirm: boolean;
  tempFlag : TJwCredentialFlagSet;
begin
  if (cfFlagsExpectConfirmation in Flags) and not
    Assigned(OnConfirmCredential) then
    raise EJwsclInvalidFlagsException.CreateFmtEx(
      RsUNCredentialsInvalidUseOfCredFlags,
      'ShowModal', ClassName, RsUNCredentials, 0, False, []);

  if (Length(fServerName) > CREDUI_MAX_DOMAIN_TARGET_LENGTH) then
    raise EJwsclInvalidParameterException.CreateFmtEx(
      RsUNCredentialsTooLongServerName, 'ShowModal',
      ClassName, RsUNCredentials, 0, False, []);

  if (Length(fServerName) = 0) then
    raise EJwsclInvalidParameterException.CreateFmtEx(
      RsUNCredentialsEmptyServerName, 'ShowModal',
      ClassName, RsUNCredentials, 0, False, []);

  GetMem(pUser, CRED_MAX_USERNAME_LENGTH * sizeof(TJwChar));
  //release point automatically and overwrite it with zeroes
  TJwAutoPointer.Wrap(pUser, CRED_MAX_USERNAME_LENGTH * sizeof(TJwChar), ptGetMem);

  hRes := {$IFDEF UNICODE}StringCchCopyW{$ELSE}StringCchCopyA{$ENDIF}
    (pUser, CRED_MAX_USERNAME_LENGTH, TJwPChar(fUserName));

  if FAILED(hRes) then
  begin
    raise EJwsclInvalidParameterException.CreateFmtEx(
      'Property %0:s must be between %1:d and %2:d.', 'ShowModal',
      ClassName, RsUNCredentials, 0, hRes, ['UserName', 0, CRED_MAX_USERNAME_LENGTH]);
  end;

  GetMem(pPass, CREDUI_MAX_PASSWORD_LENGTH * sizeof(TJwChar));
  //release point automatically and overwrite it with zeroes
  TJwAutoPointer.Wrap(pPass, CREDUI_MAX_PASSWORD_LENGTH * sizeof(TJwChar), ptGetMem);

  hRes := {$IFDEF UNICODE}StringCchCopyW{$ELSE}StringCchCopyA{$ENDIF}
    (pPass, CREDUI_MAX_PASSWORD_LENGTH, TJwPChar(fPassword));
  if FAILED(hRes) then
  begin
    raise EJwsclInvalidParameterException.CreateFmtEx(
      'Property %0:s must be between %1:d and %2:d.', 'ShowModal',
      ClassName, RsUNCredentials, 0, hRes, ['Password', 0, CREDUI_MAX_PASSWORD_LENGTH]);
  end;

  FillChar(info, sizeof(info), 0);
  info.cbSize := sizeof(info);
  info.hwndParent := fParentWindow;
  info.pszMessageText := TJwPChar(fMessageText);
  info.pszCaptionText := TJwPChar(fCaption);

  if Assigned(fBanner) then
    info.hbmBanner := fBanner.Handle;

  aBool := fSaveCheck;

  if (CommandLine) then
  begin
    tempFlag := fFlags;
    //CredUICmdLinePromptForCredentials needs cfFlagsRequireSmartCard or cfFlagsExcludeCertificates
    if not (cfFlagsRequireSmartCard in Flags)  then
      Include(tempFlag, cfFlagsExcludeCertificates)
    else
      Exclude(tempFlag, cfFlagsExcludeCertificates);

    lResult :=
{$IFDEF UNICODE}
      CredUICmdLinePromptForCredentialsW
{$ELSE}
      CredUICmdLinePromptForCredentialsA
{$ENDIF}
          (TJwPChar(fServerName),      //PCTSTR pszTargetName,
          nil,     //PCtxtHandle Reserved,
          fAuthError,     //DWORD dwAuthError,
          pUser,     //PCTSTR pszUserName,
          CRED_MAX_USERNAME_LENGTH,     //ULONG ulUserNameMaxChars,
          pPass,     //PCTSTR pszPassword,
          CREDUI_MAX_PASSWORD_LENGTH,     //ULONG ulPasswordMaxChars,
          @aBool,     //PBOOL pfSave,
          TJwEnumMap.ConvertToCredentialFlag(tempFlag)     //DWORD dwFlags
          );
  end
  else
  begin
    lResult :=
{$IFDEF UNICODE}
      CredUIPromptForCredentialsW
{$ELSE}
      CredUIPromptForCredentialsA
{$ENDIF}
        (@info,      //PCREDUI_INFO pUiInfo,
        TJwPChar(fServerName),      //PCTSTR pszTargetName,
        nil,     //PCtxtHandle Reserved,
        fAuthError,     //DWORD dwAuthError,
        pUser,     //PCTSTR pszUserName,
        CRED_MAX_USERNAME_LENGTH,     //ULONG ulUserNameMaxChars,
        pPass,     //PCTSTR pszPassword,
        CREDUI_MAX_PASSWORD_LENGTH,     //ULONG ulPasswordMaxChars,
        aBool,     //PBOOL pfSave,
        TJwEnumMap.ConvertToCredentialFlag(fFlags)      //DWORD dwFlags
        );

  end;

  if (lResult <> NO_ERROR) then
  begin
    SetLastError(lResult);

    case lResult of
      ERROR_CANCELLED: ;
      ERROR_INVALID_FLAGS:
        raise EJwsclInvalidFlagsException.CreateFmtEx(
          RsUNCredentialsInvalidPropertyFlags, 'ShowModal', ClassName, RsUNCredentials,
          0, true, []);
      ERROR_INVALID_PARAMETER:
        raise EJwsclInvalidParameterException.CreateFmtEx(
          RsUNCredentialsInvalidParametersCUIPFC, 'ShowModal',
          ClassName, RsUNCredentials, 0, true, []);
      ERROR_NO_SUCH_LOGON_SESSION: raise EJwsclNoSuchLogonSession.CreateFmtEx(
          RsUNCredentialsInvalidLogonSession, 'ShowModal', ClassName, RsUNCredentials,
          0, true, []);
    else
      raise EJwsclWinCallFailedException.CreateFmtWinCall(
          RsWinCallFailed, 'ShowModal', ClassName, RsUNCredentials,
          0, true, 'CredUIPromptForCredentials',['CredUIPromptForCredentials']);
    end;
  end
  else
  if (lResult = NO_ERROR) then
  begin
    fUserName := TJwString(pUser);
    fPassword := TJwString(pPass);
  end;

  fSaveCheck := aBool;

  Result := lResult = NO_ERROR;

  if (Result and (cfFlagsExpectConfirmation in Flags)) then
  begin
    bConfirm := True;
    OnConfirmCredential(Self, bConfirm);

    if (
  {$IFDEF UNICODE}
     CredUIConfirmCredentialsW
  {$ELSE}
      CredUIConfirmCredentialsA
  {$ENDIF}
      (TJwPChar(fServerName), bConfirm) <> NO_ERROR) then
      raise EJwsclWinCallFailedException.CreateFmtEx(
        RsWinCallFailed, 'ShowModal', ClassName,
        RsUNCredentials, 0, True, ['CredUIConfirmCredentials']);

    Result := bConfirm;
  end;
end;

{$ENDIF SL_INTERFACE_SECTION}

{$IFNDEF SL_OMIT_SECTIONS}
initialization
{$ENDIF SL_OMIT_SECTIONS}

{$IFNDEF SL_INITIALIZATION_SECTION}
{$ENDIF SL_INITIALIZATION_SECTION}


{$IFNDEF SL_OMIT_SECTIONS}
end.
{$ENDIF SL_OMIT_SECTIONS}
