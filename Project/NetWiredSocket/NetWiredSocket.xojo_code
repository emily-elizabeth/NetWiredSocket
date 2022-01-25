#tag Class
Protected Class NetWiredSocket
Inherits SSLSocket
	#tag Event
		Sub Connected()
		  me.SendHello
		End Sub
	#tag EndEvent

	#tag Event
		Sub DataAvailable()
		  // we need to do the first part using the old String data type due to the way
		  // a previous version of the socket class used byte markers to be able to 
		  // have HTML chat and news, without needing modify the protocol or worry
		  // about the official Zanka client displaying it..
		  
		  me.mBufferString = me.mBufferString + me.ReadAll(Encodings.UTF8)
		  
		  while (me.mBufferString.InStrB(me.EOT) > 0)
		    DIM command As String = NthFieldB(me.mBufferString, me.EOT, 1)
		    me.mBufferString = me.mBufferString.MidB(me.mBufferString.InStrB(me.EOT) + 1)
		    
		    if (command <> "") then
		      DIM replyCode As Integer = Val(command.NthField(" ", 1))  // get the reply code
		      DIM replyDataAsString As String = command.MidB(command.InStr(" ") + 1)  // get the raw reply data
		      DIM replyParamsAsString() As String
		      if (replyDataAsString.InStrB(me.FS) > 0) then
		        replyParamsAsString = replyDataAsString.Split(me.FS)
		      else
		        replyParamsAsString.Append replyDataAsString
		      end if
		      
		      // here's where we replace the byte markers and convert to the new Text data type
		      DIM replyParams() As String
		      for i as Integer = 0 to replyParamsAsString.Ubound
		        if (replyParamsAsString(i).LeftB(1) = ChrB(128)) then  // html chat
		          replyParamsAsString(i) = replyParamsAsString(i).ReplaceB(ChrB(128), Chr(128))
		        end if
		        if (replyParamsAsString(i).LeftB(1) = ChrB(129)) then
		          replyParamsAsString(i) = replyParamsAsString(i).ReplaceB(ChrB(129), Chr(129))
		        end if
		        if (replyParamsAsString(i).LeftB(1) = ChrB(130)) then
		          replyParamsAsString(i) = replyParamsAsString(i).ReplaceB(ChrB(130), Chr(130))
		        end if
		        replyParams.Append replyParamsAsString(i).ToText
		      next
		      
		      /// handle the command
		      select case replyCode
		      case 200 ' server info;
		        me.DataAvailableServerInfo replyParams(0), replyParams(1), replyParams(2), replyParams(3), _
		        me.DateFromString(replyParams(4)), Integer.FromString(replyParams(5)), Integer.FromString(replyParams(6))
		        
		      case 201 ' login successful
		        me.DataAvailableLoginSuccessful Integer.FromString(replyParams(0))
		        
		      case 202 ' ping reply
		        me.DataAvailablePongReceived
		        
		      case 203 ' server banner
		        me.DataAvailableServerBannerReceived me.PictureFromString(replyParams(0))
		        
		      case 300, 301 ' chat received
		        me.DataAvailableChatReceived Integer.FromString(replyParams(0)), Integer.FromString(replyParams(1)), _
		        replyParams(2), (replyCode = 301)
		        
		      case 302 ' user joined server/private chat
		        REDIM replyParams(10)
		        me.DataAvailableUserJoined Integer.FromString(replyParams(0)), Integer.FromString(replyParams(1)), _
		        me.BooleanFromString(replyParams(2)), me.BooleanFromString(replyParams(3)), replyParams(5), replyParams(6), _
		        replyParams(7), replyParams(8), replyParams(9), me.PictureFromString(replyParams(10))
		        
		      case 303 ' user left server/private chat
		        me.DataAvailableUserLeft Integer.FromString(replyParams(0)), Integer.FromString(replyParams(1))
		        
		      case 304 ' user changed
		        me.DataAvailableUserChanged Integer.FromString(replyParams(0)), me.BooleanFromString(replyParams(1)), _
		        me.BooleanFromString(replyParams(2)), replyParams(4), replyParams(5)
		        
		      case 305, 309 ' private message/broadcast
		        me.DataAvailableMessageReceived Integer.FromString(replyParams(0)), replyParams(1), (replyCode = 309)
		        
		      case 306, 307 ' user kicked
		        me.DataAvailableUserKicked Integer.FromString(replyParams(0)), Integer.FromString(replyParams(1)), _
		        replyParams(2), (replyCode = 307)
		        
		      case 308 ' user information
		        REDIM replyParams(16)
		        me.DataAvailableUserInfoReceived Integer.FromString(replyParams(0)), me.BooleanFromString(replyParams(1)), _
		        me.BooleanFromString(replyParams(2)), replyParams(4), replyParams(5), replyParams(6), replyParams(7), _
		        replyParams(8), replyParams(9), Integer.FromString(replyParams(10)), me.DateFromString(replyParams(11)), _
		        me.DateFromString(replyParams(12)), replyParams(13), replyParams(14), replyParams(15), me.PictureFromString(replyParams(16))
		        
		      case 310 ' user list entry
		        REDIM replyParams(10)
		        me.DataAvailableUserListEntry Integer.FromString(replyParams(0)), Integer.FromString(replyParams(1)), _
		        me.BooleanFromString(replyParams(2)), me.BooleanFromString(replyParams(3)), replyParams(5), replyParams(6), _
		        replyParams(7), replyParams(8), replyParams(9), me.PictureFromString(replyParams(10))
		        
		      case 311 ' user list termination
		        me.DataAvailableUserListEnd Integer.FromString(replyParams(0))
		        
		      case 320  ' news entry
		        me.DataAvailableNewsListEntry replyParams(0), me.DateFromString(replyParams(1)), replyParams(2)
		        
		      case 321  ' news done
		        me.DataAvailableNewsListEnd
		        
		      case 322  ' news posted
		        me.DataAvailableNewsPosted replyParams(0), me.DateFromString(replyParams(1)), replyParams(2)
		        
		      case 330 ' private chat created
		        me.DataAvailablePrivateChatCreated Integer.FromString(replyParams(0))
		        
		      case 331  ' private chat invitation
		        me.DataAvailablePrivateChatInvitationReceived Integer.FromString(replyParams(0)), Integer.FromString(replyParams(1))
		        
		      case 332  ' private chat declined
		        me.DataAvailablePrivateChatDeclined Integer.FromString(replyParams(0)), Integer.FromString(replyParams(1))
		        
		      case 340  ' user icon changed
		        me.DataAvailableUserIconChanged Integer.FromString(replyParams(0)), me.PictureFromString(replyParams(1))
		        
		      case 341  ' chat topic changed
		        me.DataAvailableChatTopicReceived Integer.FromString(replyParams(0)), replyParams(1), replyParams(2), _
		        replyParams(3), me.DateFromString(replyParams(4)), replyParams(5)
		        
		      case 400  ' transfer ready
		        me.DataAvailableTransferReady replyParams(0), Integer.FromString(replyParams(1)), replyParams(2)
		        
		      case 401  ' transfer queued
		        me.DataAvailableTransferQueued replyParams(0), Integer.FromString(replyParams(1))
		        
		      case 410  ' file listing
		        me.DataAvailableFileListEntry replyParams(0), Integer.FromString(replyParams(1)), _
		        Integer.FromString(replyParams(2)), me.DateFromString(replyParams(3)), me.DateFromString(replyParams(4))
		        
		      case 411  ' file listing done - path(0), free(1)
		        me.DataAvailableFileListEnd replyParams(0), Integer.FromString(replyParams(1))
		        
		      case 420  ' search listing
		        'me.DataAvailableSearchListEntry replyParams(0), CType(Integer.FromString(replyParams(1)), WiredSocket.FileType), _
		        'Integer.FromString(replyParams(2)), me.ToDate(replyParams(3)), me.ToDate(replyParams(4))
		        
		      case 421  ' search listing done - "done"(0)
		        me.DataAvailableSearchListEnd
		        
		      case 500  ' command failed
		        me.DataAvailableErrorCommandFailed replyParams(0)
		        
		      case 501  ' command not recognized
		        me.DataAvailableErrorCommandNotRecognized replyParams(0)
		        
		      case 502  ' command not implemented
		        me.DataAvailableErrorCommandNotImplemented replyParams(0)
		        
		      case 503  ' syntax error
		        me.DataAvailableErrorSyntaxError replyParams(0)
		        
		      case 510  ' login failed
		        me.DataAvailableErrorLoginFailed replyParams(0)
		        
		      case 511  ' banned
		        me.DataAvailableErrorBanned replyParams(0)
		        
		      case 512  ' client not found
		        me.DataAvailableErrorClientNotFound replyParams(0)
		        
		      case 513  ' account not found
		        me.DataAvailableErrorAccountNotFound replyParams(0)
		        
		      case 514  ' account exists
		        me.DataAvailableErrorAccountExists replyParams(0)
		        
		      case 515  ' cannot be disconnected
		        me.DataAvailableErrorCannotBeDisconnected replyParams(0)
		        
		      case 516  ' permission denied
		        me.DataAvailableErrorPermissionDenied replyParams(0)
		        
		      case 520  ' file or directory not found
		        me.DataAvailableErrorFileNotFound replyParams(0)
		        
		      case 521  ' file or directory exists
		        me.DataAvailableErrorFileExists replyParams(0)
		        
		      case 522  ' checksum mismatch
		        me.DataAvailableErrorChecksumMismatch replyParams(0)
		        
		      case 523  ' Queue Limit Exceeded
		        me.DataAvailableErrorQueueLimitExceeded replyParams(0)
		        
		      case 600  ' user specification
		        REDIM replyParams(25)
		        me.DataAvailableAccountInfoReceived replyParams(0), replyParams(1), replyParams(2), me.BooleanFromString(replyParams(3)), _
		        me.BooleanFromString(replyParams(4)), me.BooleanFromString(replyParams(5)), me.BooleanFromString(replyParams(6)), _
		        me.BooleanFromString(replyParams(7)), me.BooleanFromString(replyParams(8)), me.BooleanFromString(replyParams(9)), _
		        me.BooleanFromString(replyParams(10)), me.BooleanFromString(replyParams(11)), me.BooleanFromString(replyParams(12)), _
		        me.BooleanFromString(replyParams(13)), me.BooleanFromString(replyParams(14)), me.BooleanFromString(replyParams(15)), _
		        me.BooleanFromString(replyParams(16)), me.BooleanFromString(replyParams(17)), me.BooleanFromString(replyParams(18)), _
		        me.BooleanFromString(replyParams(19)), me.BooleanFromString(replyParams(20)), Integer.FromString(replyParams(21)), _
		        Integer.FromString(replyParams(22)), Integer.FromString(replyParams(23)), Integer.FromString(replyParams(24)), _
		        me.BooleanFromString(replyParams(25))
		        
		      case 601  ' group specification
		        REDIM replyParams(23)
		        me.DataAvailableGroupInfoReceived replyParams(0), me.BooleanFromString(replyParams(1)), me.BooleanFromString(replyParams(2)), _
		        me.BooleanFromString(replyParams(3)), me.BooleanFromString(replyParams(4)), me.BooleanFromString(replyParams(5)), _
		        me.BooleanFromString(replyParams(6)), me.BooleanFromString(replyParams(7)), me.BooleanFromString(replyParams(8)), _
		        me.BooleanFromString(replyParams(9)), me.BooleanFromString(replyParams(10)), me.BooleanFromString(replyParams(11)), _
		        me.BooleanFromString(replyParams(12)), me.BooleanFromString(replyParams(13)), me.BooleanFromString(replyParams(14)), _
		        me.BooleanFromString(replyParams(15)), me.BooleanFromString(replyParams(16)), me.BooleanFromString(replyParams(17)), _
		        me.BooleanFromString(replyParams(18)), Integer.FromString(replyParams(19)), Integer.FromString(replyParams(20)), _
		        Integer.FromString(replyParams(21)), Integer.FromString(replyParams(22)), me.BooleanFromString(replyParams(23))
		        
		      case 602  ' privileges
		        REDIM replyParams(22)
		        me.DataAvailablePrivilegesReceived me.BooleanFromString(replyParams(0)), me.BooleanFromString(replyParams(1)), _
		        me.BooleanFromString(replyParams(2)), me.BooleanFromString(replyParams(3)), me.BooleanFromString(replyParams(4)), _
		        me.BooleanFromString(replyParams(5)), me.BooleanFromString(replyParams(6)), me.BooleanFromString(replyParams(7)), _
		        me.BooleanFromString(replyParams(8)), me.BooleanFromString(replyParams(9)), me.BooleanFromString(replyParams(10)), _
		        me.BooleanFromString(replyParams(11)), me.BooleanFromString(replyParams(12)), me.BooleanFromString(replyParams(13)), _
		        me.BooleanFromString(replyParams(14)), me.BooleanFromString(replyParams(15)), me.BooleanFromString(replyParams(16)), _
		        me.BooleanFromString(replyParams(17)), Integer.FromString(replyParams(18)), Integer.FromString(replyParams(19)), _
		        Integer.FromString(replyParams(20)), Integer.FromString(replyParams(21)), me.BooleanFromString(replyParams(22))
		        
		      case 610  ' user listing (accounts) - login(0)
		        me.DataAvailableAccountListEntry replyParams(0)
		        
		      case 611  ' user listing done (accounts) - "done"(0)
		        me.DataAvailableAccountListEnd
		        
		      case 620  ' group listing - name(0)
		        me.DataAvailableGroupListEntry replyParams(0)
		        
		      case 621  ' group listing done - "done"(0)
		        me.DataAvailableGroupListEnd
		      end select
		    end if
		  wend
		End Sub
	#tag EndEvent

	#tag Event
		Sub Error(err As RuntimeException)
		  if (me.LastErrorCode <> 0) then
		    RaiseEvent Error err.Message
		  end if
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function BooleanFromString(value As String) As Boolean
		  // converts a string to a boolean
		  // if the strings "true" or "1" are passed, TRUE is returned FALSE otherwise
		  
		  Return ((value = "TRUE") OR (value = "1"))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ChangeChatTopic(chatID As Integer, topic As String)
		  me.Write "TOPIC " + chatID.ToText + me.FS + topic
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ChangeComment(path As String, comment As String)
		  me.Write "COMMENT " + path + me.FS + comment
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ChangeFolderType(path As String, type As Integer)
		  me.Write "TYPE " + path + me.FS + type.ToString
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ChangeIcon(icon As Picture)
		  me.Write "ICON 0" + me.FS + me.StringFromPicture(icon)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ChangeNick(nick As String)
		  me.Write "NICK " + nick
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ChangeStatus(status As String)
		  me.Write "STATUS " + status
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearNews()
		  me.Write "CLEARNEWS"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  me.Secure = TRUE
		  me.ConnectionType = SSLSocket.TLSv1
		  me.Port = 2000
		  me.mDataPort = 2001
		  
		  // Calling the overridden superclass constructor.
		  // Note that this may need modifications if there are multiple constructor choices.
		  // Possible constructor calls:
		  // Constructor() -- From TCPSocket
		  // Constructor() -- From SocketCore
		  Super.Constructor
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(aDelegate As NetWiredSocketInterface)
		  me.mDelegate = NEW WeakRef(aDelegate)
		  me.Constructor
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CreateAccount(login As String, hashedPassword As String, group As String, getUserInfo As Boolean, broadcast As Boolean, postNews As Boolean, clearNews As Boolean, download As Boolean, upload As Boolean, uploadAnywhere As Boolean, createFolders As Boolean, alterFiles As Boolean, deleteFiles As Boolean, viewDropboxes As Boolean, createAccounts As Boolean, editAccounts As Boolean, deleteAccounts As Boolean, elevatePrivileges As Boolean, kickUsers As Boolean, banUsers As Boolean, cannotBeKicked As Boolean, downloadSpeed As UInt64, uploadSpeed As UInt64, downloadLimit As UInt64, uploadLimit As UInt64, changeTopic As Boolean)
		  me.Write "CREATEUSER " + login + me.FS + hashedPassword + me.FS + group + me.FS + _
		  StringFromBoolean(getUserInfo) + me.FS + _
		  StringFromBoolean(broadcast) + me.FS + _
		  StringFromBoolean(postNews) + me.FS + _
		  StringFromBoolean(clearNews) + me.FS + _
		  StringFromBoolean(download) + me.FS + _
		  StringFromBoolean(upload) + me.FS + _
		  StringFromBoolean(uploadAnywhere) + me.FS + _
		  StringFromBoolean(createFolders) + me.FS + _
		  StringFromBoolean(alterFiles) + me.FS + _
		  StringFromBoolean(deleteFiles) + me.FS + _
		  StringFromBoolean(viewDropboxes) + me.FS + _
		  StringFromBoolean(createAccounts) + me.FS + _
		  StringFromBoolean(editAccounts) + me.FS + _
		  StringFromBoolean(deleteAccounts) + me.FS + _
		  StringFromBoolean(elevatePrivileges) + me.FS + _
		  StringFromBoolean(kickUsers) + me.FS + _
		  StringFromBoolean(banUsers) + me.FS + _
		  StringFromBoolean(cannotBeKicked) + me.FS + _
		  downloadSpeed.ToText + me.FS + _
		  uploadSpeed.ToText + me.FS + _
		  downloadLimit.ToText + me.FS + _
		  uploadLimit.ToText + me.FS + _
		  StringFromBoolean(changeTopic)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CreateFolder(path As String)
		  me.Write "FOLDER " + path
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CreateGroup(name As String, getUserInfo As Boolean, broadcast As Boolean, postNews As Boolean, clearNews As Boolean, download As Boolean, upload As Boolean, uploadAnywhere As Boolean, createFolders As Boolean, alterFiles As Boolean, deleteFiles As Boolean, viewDropboxes As Boolean, createAccounts As Boolean, editAccounts As Boolean, deleteAccounts As Boolean, elevatePrivileges As Boolean, kickUsers As Boolean, banUsers As Boolean, cannotBeKicked As Boolean, downloadSpeed As UInt64, uploadSpeed As UInt64, downloadLimit As UInt64, uploadLimit As UInt64, changeTopic As Boolean)
		  me.Write "CREATEGROUP " + name + me.FS + _
		  StringFromBoolean(getUserInfo) + me.FS + _
		  StringFromBoolean(broadcast) + me.FS + _
		  StringFromBoolean(postNews) + me.FS + _
		  StringFromBoolean(clearNews) + me.FS + _
		  StringFromBoolean(download) + me.FS + _
		  StringFromBoolean(upload) + me.FS + _
		  StringFromBoolean(uploadAnywhere) + me.FS + _
		  StringFromBoolean(createFolders) + me.FS + _
		  StringFromBoolean(alterFiles) + me.FS + _
		  StringFromBoolean(deleteFiles) + me.FS + _
		  StringFromBoolean(viewDropboxes) + me.FS + _
		  StringFromBoolean(createAccounts) + me.FS + _
		  StringFromBoolean(editAccounts) + me.FS + _
		  StringFromBoolean(deleteAccounts) + me.FS + _
		  StringFromBoolean(elevatePrivileges) + me.FS + _
		  StringFromBoolean(kickUsers) + me.FS + _
		  StringFromBoolean(banUsers) + me.FS + _
		  StringFromBoolean(cannotBeKicked) + me.FS + _
		  downloadSpeed.ToText + me.FS + _
		  uploadSpeed.ToText + me.FS + _
		  downloadLimit.ToText + me.FS + _
		  uploadLimit.ToText + me.FS + _
		  StringFromBoolean(changeTopic)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CreatePrivateChat()
		  me.Write "PRIVCHAT"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableAccountInfoReceived(login As String, password As String, group As String, getUserInfo As Boolean, broadcast As Boolean, postNews As Boolean, clearNews As Boolean, download As Boolean, upload As Boolean, uploadAnywhere As Boolean, createFolders As Boolean, alterFiles As Boolean, deleteFiles As Boolean, viewDropboxes As Boolean, createAccounts As Boolean, editAccounts As Boolean, deleteAccounts As Boolean, elevatePrivileges As Boolean, kickUsers As Boolean, banUsers As Boolean, cannotBeKicked As Boolean, downloadSpeed As UInt64, uploadSpeed As UInt64, downloadLimit As UInt64, uploadLimit As UInt64, changeTopic As Boolean)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent AccountInfoReceived login, password, group, getUserInfo, broadcast, postNews, clearNews, _
		    download, upload, uploadAnywhere, createFolders, alterFiles, deleteFiles, viewDropboxes, createAccounts, _
		    editAccounts, deleteAccounts, elevatePrivileges, kickUsers, banUsers, cannotBeKicked, downloadSpeed, _
		    uploadSpeed, downloadLimit, uploadLimit, changeTopic
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).AccountInfoReceived login, password, group, getUserInfo, broadcast, postNews, clearNews, _
		    download, upload, uploadAnywhere, createFolders, alterFiles, deleteFiles, viewDropboxes, createAccounts, _
		    editAccounts, deleteAccounts, elevatePrivileges, kickUsers, banUsers, cannotBeKicked, downloadSpeed, _
		    uploadSpeed, downloadLimit, uploadLimit, changeTopic
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableAccountListEnd()
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent AccountListEnd
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).AccountListEnd
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableAccountListEntry(login As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent AccountListEntry login
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).AccountListEntry login
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableChatReceived(chatID As Integer, userID As Integer, message As String, isAction As Boolean)
		  'if (self.mUsersDict.HasKey(userID)) then
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ChatReceived chatID, userID, message, isAction
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ChatReceived chatID, userID, message, isAction
		  end if
		  'end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableChatTopicReceived(chatID As Integer, nick As String, login As String, IP As String, time As DateTime, topic As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ChatTopicReceived chatID, nick, login, IP, time, topic
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ChatTopicReceived chatID, nick, login, IP, time, topic
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorAccountExists(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorAccountExists message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorAccountExists message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorAccountNotFound(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorAccountNotFound message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorAccountNotFound message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorBanned(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorBanned message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorBanned message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorCannotBeDisconnected(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorCannotBeDisconnected message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorCannotBeDisconnected message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorChecksumMismatch(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorChecksumMismatch message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorChecksumMismatch message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorClientNotFound(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorClientNotFound message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorClientNotFound message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorCommandFailed(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorCommandFailed message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorCommandFailed message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorCommandNotImplemented(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorCommandNotImplemented message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorCommandNotImplemented message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorCommandNotRecognized(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorCommandNotRecognized message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorCommandNotRecognized message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorFileExists(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorFileExists message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorFileExists message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorFileNotFound(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorFileNotFound message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorFileNotFound message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorLoginFailed(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorLoginFailed message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorLoginFailed message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorPermissionDenied(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorPermissionDenied message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorPermissionDenied message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorQueueLimitExceeded(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorQueueLimitExceeded message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorQueueLimitExceeded message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableErrorSyntaxError(message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ErrorSyntaxError message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ErrorSyntaxError message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableFileListEnd(path As String, free As UInt64)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent FileListEnd path, free
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).FileListEnd path, free
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableFileListEntry(path As String, type As Integer, size As UInt64, created As DateTime, modified As DateTime)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent FileListEntry path, type, size, created, modified
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).FileListEntry path, type, size, created, modified
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableGroupInfoReceived(name As String, getUserInfo As Boolean, broadcast As Boolean, postNews As Boolean, clearNews As Boolean, download As Boolean, upload As Boolean, uploadAnywhere As Boolean, createFolders As Boolean, alterFiles As Boolean, deleteFiles As Boolean, viewDropboxes As Boolean, createAccounts As Boolean, editAccounts As Boolean, deleteAccounts As Boolean, elevatePrivileges As Boolean, kickUsers As Boolean, banUsers As Boolean, cannotBeKicked As Boolean, downloadSpeed As UInt64, uploadSpeed As UInt64, downloadLimit As UInt64, uploadLimit As UInt64, changeTopic As Boolean)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent GroupInfoReceived name, getUserInfo, broadcast, postNews, clearNews, download, upload, _
		    uploadAnywhere, createFolders, alterFiles, deleteFiles, viewDropboxes, createAccounts, editAccounts, _
		    deleteAccounts, elevatePrivileges, kickUsers, banUsers, cannotBeKicked, downloadSpeed, uploadSpeed, _
		    downloadLimit, uploadLimit, changeTopic
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).GroupInfoReceived name, getUserInfo, broadcast, postNews, clearNews, download, upload, _
		    uploadAnywhere, createFolders, alterFiles, deleteFiles, viewDropboxes, createAccounts, editAccounts, _
		    deleteAccounts, elevatePrivileges, kickUsers, banUsers, cannotBeKicked, downloadSpeed, uploadSpeed, _
		    downloadLimit, uploadLimit, changeTopic
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableGroupListEnd()
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent GroupListEnd
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).GroupListEnd
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableGroupListEntry(name As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent GroupListEntry name
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).GroupListEntry name
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableLoginSuccessful(myUserID As Integer)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent LoginSuccessful myUserID
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).LoginSuccessful myUserID
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableMessageReceived(userID As Integer, message As String, isBroadcast As Boolean)
		  'if (self.mUsersDict.HasKey(userID)) then
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent MessageReceived userID, message, isBroadcast
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).MessageReceived userID, message, isBroadcast
		  end if
		  'end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableNewsListEnd()
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent NewsListEnd
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).NewsListEnd
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableNewsListEntry(nick As String, time As DateTime, message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent NewsListEntry nick, time, message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).NewsListEntry nick, time, message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableNewsPosted(nick As String, time As DateTime, message As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent NewsPosted nick, time, message
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).NewsPosted nick, time, message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailablePongReceived()
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent PongReceived
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).PongReceived
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailablePrivateChatCreated(chatID As Integer)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent PrivateChatCreated chatID
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).PrivateChatCreated chatID
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailablePrivateChatDeclined(chatID As Integer, userID As Integer)
		  'if (self.mUsersDict.HasKey(userID)) then
		  'DIM user As WiredUser = self.mUsersDict.Value(userID)
		  
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent PrivateChatDeclined chatID, userID
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).PrivateChatDeclined chatID, userID
		  end if
		  'end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailablePrivateChatInvitationReceived(chatID As Integer, userID As Integer)
		  'if (self.mUsersDict.HasKey(userID)) then
		  'DIM user As WiredUser = self.mUsersDict.Value(userID)
		  
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent PrivateChatInvitationReceived chatID, userID
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).PrivateChatInvitationReceived chatID, userID
		  end if
		  'end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailablePrivilegesReceived(getUserInfo As Boolean, broadcast As Boolean, postNews As Boolean, clearNews As Boolean, download As Boolean, upload As Boolean, uploadAnywhere As Boolean, createFolders As Boolean, alterFiles As Boolean, deleteFiles As Boolean, viewDropboxes As Boolean, createAccounts As Boolean, editAccounts As Boolean, deleteAccounts As Boolean, elevatePrivileges As Boolean, kickUsers As Boolean, banUsers As Boolean, cannotBeKicked As Boolean, downloadSpeed As UInt64, uploadSpeed As UInt64, downloadLimit As UInt64, uploadLimit As UInt64, changeTopic As Boolean)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent PrivilegesReceived getUserInfo, broadcast, postNews, clearNews, download, upload, _
		    uploadAnywhere, createFolders, alterFiles, deleteFiles, viewDropboxes, createAccounts, editAccounts, _
		    deleteAccounts, elevatePrivileges, kickUsers, banUsers, cannotBeKicked, downloadSpeed, uploadSpeed, _
		    downloadLimit, uploadLimit, changeTopic
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).PrivilegesReceived getUserInfo, broadcast, postNews, clearNews, download, upload, _
		    uploadAnywhere, createFolders, alterFiles, deleteFiles, viewDropboxes, createAccounts, editAccounts, _
		    deleteAccounts, elevatePrivileges, kickUsers, banUsers, cannotBeKicked, downloadSpeed, uploadSpeed, _
		    downloadLimit, uploadLimit, changeTopic
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableSearchListEnd()
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent SearchListEnd
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).SearchListEnd
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableSearchListEntry(path As String, type As Integer, size As UInt64, created As DateTime, modified As DateTime)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent SearchListEntry path, type, size, created, modified
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).SearchListEntry path, type, size, created, modified
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableServerBannerReceived(serverBanner As Picture)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ServerBannerReceived serverBanner
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ServerBannerReceived serverBanner
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableServerInfo(appVersion As String, protocolVersion As String, serverName As String, serverDescription As String, startTime As DateTime, filesCount As UInt64, filesSize As UInt64)
		  if (NOT me.mHelloIsReceived) then
		    me.mHelloIsReceived = TRUE
		    if (me.mDelegate.Value = Nil) then
		      RaiseEvent Connected
		    else
		      NetWiredSocketInterface(me.mDelegate.Value).Connected
		    end if
		  end if
		  
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent ServerInfoReceived appVersion, protocolVersion, serverName, serverDescription, startTime, filesCount, filesSize
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).ServerInfoReceived appVersion, protocolVersion, serverName, serverDescription, startTime, filesCount, filesSize
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableTransferQueued(path As String, position As Integer)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent TransferQueued path, position
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).TransferQueued path, position
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableTransferReady(path As String, offset As UInt64, hash As String)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent TransferReady path, offset, hash
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).TransferReady path, offset, hash
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableUserChanged(userID As Integer, isIdle As Boolean, isAdmin As Boolean, nick As String, status As String)
		  'if (self.mUsersDict.HasKey(userID)) then
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent UserChanged userID, isIdle, isAdmin, nick, status
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).UserChanged userID, isIdle, isAdmin, nick, status
		  end if
		  'end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableUserIconChanged(userID As Integer, icon As Picture)
		  'if (self.mUsersDict.HasKey(userID)) then
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent UserIconChanged userID, icon
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).UserIconChanged userID, icon
		  end if
		  'end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableUserInfoReceived(userID As Integer, isIdle As Boolean, isAdmin As Boolean, nick As String, login As String, IP As String, host As String, clientVersion As String, cipherName As String, cipherBits As Integer, loginTime As DateTime, idleTime As DateTime, downloads As String, uploads As String, status As String, icon As Picture)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent UserInfoReceived userID, isIdle, isAdmin, nick, login, IP, host, clientVersion, _
		    cipherName, cipherBits, loginTime, idleTime, downloads, uploads, status, icon
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).UserInfoReceived userID, isIdle, isAdmin, nick, login, IP, host, clientVersion, _
		    cipherName, cipherBits, loginTime, idleTime, downloads, uploads, status, icon
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableUserJoined(chatID As Integer, userID As Integer, isIdle As Boolean, isAdmin As Boolean, nick As String, login As String, IP As String, host As String, status As String, icon As Picture)
		  'if (NOT self.mUsersDict.HasKey(userID)) then
		  'self.mUsersDict.Value(userID) = NEW WiredUser(userID, isIdle, isAdmin, nick, login, IP, host, status, icon)
		  'end if
		  
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent UserJoined chatID, userID, isIdle, isAdmin, nick, login, IP, host, status, icon
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).UserJoined chatID, userID, isIdle, isAdmin, nick, login, IP, host, status, icon
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableUserKicked(victimID As Integer, killerID As Integer, message As String, isBan As Boolean)
		  'if (self.mUsersDict.HasKey(victimID)) AND (self.mUsersDict.HasKey(killerID)) then
		  'DIM victim As WiredUser = self.mUsersDict.Value(victimID)
		  'DIM killer As WiredUser = self.mUsersDict.Value(killerID)
		  'self.mUsersDict.Remove victimID
		  
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent UserKicked victimID, killerID, message, isBan
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).UserKicked victimID, killerID, message, isBan
		  end if
		  'end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableUserLeft(chatID As Integer, userID As Integer)
		  'if (self.mUsersDict.HasKey(userID)) then
		  'DIM user As WiredUser = self.mUsersDict.Value(userID)
		  '
		  'if (chatID = 1) then
		  'self.mUsersDict.Remove userID
		  'end if
		  
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent UserLeft chatID, userID
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).UserLeft chatID, userID
		  end if
		  'end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableUserListEnd(chatID As Integer)
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent UserListEnd chatID
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).UserListEnd chatID
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DataAvailableUserListEntry(chatID As Integer, userID As Integer, isIdle As Boolean, isAdmin As Boolean, nick As String, login As String, IP As String, host As String, status As String, icon As Picture)
		  'if (NOT self.mUsersDict.HasKey(userID)) then
		  'self.mUsersDict.Value(userID) = NEW WiredUser(userID, isIdle, isAdmin, nick, login, IP, host, status, icon)
		  'end if
		  
		  if (me.mDelegate.Value = Nil) then
		    RaiseEvent UserListEntry chatID, userID, isIdle, isAdmin, nick, login, IP, host, status, icon
		  else
		    NetWiredSocketInterface(me.mDelegate.Value).UserListEntry chatID, userID, isIdle, isAdmin, nick, login, IP, host, status, icon
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DateFromString(value As String) As DateTime
		  // converts ISO 8601 full "date-time" format (RFC 3339) to a Xojo DateTime object
		  // example: 1996-12-19T16:39:57-08:00
		  // This represents 39 minutes and 57 seconds after the 16th hour of December 19th, 1996 with an offset of -08:00 from UTC.
		  
		  DIM tYear As Integer = val(value.Mid(1,4))
		  DIM tMonth As Integer = val(value.Mid(6,2))
		  DIM tDay As Integer = val(value.Mid(9,2))
		  DIM tHours As Integer = val(value.Mid(12,2))
		  DIM tMinutes As Integer = val(value.Mid(15,2))
		  DIM tSeconds As Integer = val(value.Mid(18,2))
		  DIM tGMTOffset As Double = val(value.Mid(20,3)) + (val(value.Mid(24,2)) / 60)
		  
		  DIM tDate As NEW Date
		  DIM tLocalGMT As Double = tDate.GMTOffset
		  
		  tDate.GMTOffset = tGMTOffset
		  tDate.Year = tYear
		  tDate.Month = tMonth
		  tDate.Day = tDay
		  tDate.Hour = tHours
		  tDate.Minute = tMinutes
		  tDate.Second = tSeconds
		  tDate.GMTOffset = tLocalGMT
		  
		  DIM results As NEW DateTime(tDate)
		  Return results
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeclinePrivateChatInvitation(chatID As Integer)
		  me.Write "DECLINE " + chatID.ToText
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteAccount(login As String)
		  me.Write "DELETEUSER " + login
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteFile(path As String)
		  me.Write "DELETE " + path
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteGroup(name As String)
		  me.Write "DELETEGROUP " + name
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Disconnect()
		  Super.Disconnect
		  me.mBuffer = ""
		  me.mHelloIsReceived = FALSE
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Get(path As String, offset As UInt64 = 0)
		  me.Write "GET " + path + me.FS + offset.ToText
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function HashPassword(password As String) As String
		  DIM returnValue As String = ""
		  
		  if (Trim(password) <> "") then
		    returnValue = Crypto.SHA1(password)
		    returnValue = EncodeHex(returnValue)
		    returnValue = returnValue.Lowercase
		  end if
		  
		  Return returnValue.ToText
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub InviteUserToPrivateChat(userID As Integer, chatID As Integer)
		  me.Write "INVITE " + userID.ToText + me.FS + chatID.ToText
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub JoinPrivateChat(chatID As Integer)
		  me.Write "JOIN " + chatID.ToText
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub KickUser(userID As Integer, isBan As Boolean, message As String = "")
		  me.Write if(isBan, "BAN ", "KICK ") + userID.ToText + me.FS + message
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LeavePrivateChat(chatID As Integer)
		  me.Write "LEAVE " + chatID.ToText
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Move(fromPath As String, toPath As String)
		  me.Write "MOVE " + fromPath + me.FS + toPath
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PictureFromString(value As String) As Picture
		  DIM results As Picture
		  
		  if (NOT value.IsEmpty) then
		    DIM temp() As String = value.Split(",")
		    value = temp(temp.Ubound)
		    results = Picture.FromData(DecodeBase64(value))
		  end if
		  
		  Return results
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PostNews(message As String)
		  me.Write "POST " + message
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Put(path As String, size As UInt64, checksum As String)
		  me.Write "PUT " + path + me.FS + size.ToText + me.FS + checksum
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RequestAccountInfo(login As String)
		  me.Write "READUSER " + login
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RequestAccounts()
		  me.Write "USERS"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RequestDirectoryListing(path As String = "/")
		  me.Write "LIST " + path
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RequestFileInfo(path As String)
		  me.Write "STAT " + path
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RequestGroupInfo(name As String)
		  me.Write "READGROUP " + name
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RequestGroups()
		  me.Write "GROUPS"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RequestNews()
		  me.Write "NEWS"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RequestPrivileges()
		  me.Write "PRIVILEGES"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RequestServerBanner()
		  me.Write "BANNER"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RequestUserInfo(userID As Integer)
		  me.Write "INFO " + userID.ToText
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RequestUserList(chatID As Integer)
		  me.Write "WHO " + chatID.ToText
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Search(query As String)
		  me.Write "SEARCH " + query
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendChat(chatID As Integer, message As String, isAction As Boolean)
		  me.Write if(isAction, "ME ", "SAY ") + chatID.ToText + me.FS + message
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendClient(info As String)
		  me.Write "CLIENT " + info
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendHello()
		  me.Write "HELLO"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendIcon(icon As Picture)
		  me.Write "ICON 0" + me.FS + me.StringFromPicture(icon)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendLogin(login As String = "guest")
		  me.Write "USER " + login
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendMessage(userID As Integer, message As String, isBroadcast As Boolean)
		  if (isBroadcast) then
		    me.Write "BROADCAST " + message
		  else
		    me.Write "MSG " + userID.ToString + me.FS + message
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendNick(nick As String)
		  me.Write "NICK " + nick
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendPass(hashedPassword As String)
		  me.Write "PASS " + hashedPassword
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendPing()
		  me.Write "PING"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendStatus(status As String)
		  me.Write "STATUS " + status
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StringFromBoolean(value As Boolean) As String
		  Return if(value, "1", "0")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StringFromPicture(image As Picture) As String
		  DIM value As String = ""
		  
		  if (image <> Nil) then
		    DIM aMemoryBlock As MemoryBlock = image.GetData(Picture.FormatPNG)
		    value = EncodeBase64(aMemoryBlock, 0).ToText
		  end if
		  
		  Return value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Transfer(hash As String)
		  me.Write "TRANSFER " + hash
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateAccount(login As String, hashedPassword As String, group As String, getUserInfo As Boolean, broadcast As Boolean, postNews As Boolean, clearNews As Boolean, download As Boolean, upload As Boolean, uploadAnywhere As Boolean, createFolders As Boolean, alterFiles As Boolean, deleteFiles As Boolean, viewDropboxes As Boolean, createAccounts As Boolean, editAccounts As Boolean, deleteAccounts As Boolean, elevatePrivileges As Boolean, kickUsers As Boolean, banUsers As Boolean, cannotBeKicked As Boolean, downloadSpeed As UInt64, uploadSpeed As UInt64, downloadLimit As UInt64, uploadLimit As UInt64, changeTopic As Boolean)
		  me.Write "EDITUSER " + login + me.FS + hashedPassword + me.FS + group + me.FS + _
		  StringFromBoolean(getUserInfo) + me.FS + _
		  StringFromBoolean(broadcast) + me.FS + _
		  StringFromBoolean(postNews) + me.FS + _
		  StringFromBoolean(clearNews) + me.FS + _
		  StringFromBoolean(download) + me.FS + _
		  StringFromBoolean(upload) + me.FS + _
		  StringFromBoolean(uploadAnywhere) + me.FS + _
		  StringFromBoolean(createFolders) + me.FS + _
		  StringFromBoolean(alterFiles) + me.FS + _
		  StringFromBoolean(deleteFiles) + me.FS + _
		  StringFromBoolean(viewDropboxes) + me.FS + _
		  StringFromBoolean(createAccounts) + me.FS + _
		  StringFromBoolean(editAccounts) + me.FS + _
		  StringFromBoolean(deleteAccounts) + me.FS + _
		  StringFromBoolean(elevatePrivileges) + me.FS + _
		  StringFromBoolean(kickUsers) + me.FS + _
		  StringFromBoolean(banUsers) + me.FS + _
		  StringFromBoolean(cannotBeKicked) + me.FS + _
		  downloadSpeed.ToText + me.FS + _
		  uploadSpeed.ToText + me.FS + _
		  downloadLimit.ToText + me.FS + _
		  uploadLimit.ToText + me.FS + _
		  StringFromBoolean(changeTopic)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateGroup(name As String, getUserInfo As Boolean, broadcast As Boolean, postNews As Boolean, clearNews As Boolean, download As Boolean, upload As Boolean, uploadAnywhere As Boolean, createFolders As Boolean, alterFiles As Boolean, deleteFiles As Boolean, viewDropboxes As Boolean, createAccounts As Boolean, editAccounts As Boolean, deleteAccounts As Boolean, elevatePrivileges As Boolean, kickUsers As Boolean, banUsers As Boolean, cannotBeKicked As Boolean, downloadSpeed As UInt64, uploadSpeed As UInt64, downloadLimit As UInt64, uploadLimit As UInt64, changeTopic As Boolean)
		  me.Write "EDITGROUP " + name + me.FS + _
		  StringFromBoolean(getUserInfo) + me.FS + _
		  StringFromBoolean(broadcast) + me.FS + _
		  StringFromBoolean(postNews) + me.FS + _
		  StringFromBoolean(clearNews) + me.FS + _
		  StringFromBoolean(download) + me.FS + _
		  StringFromBoolean(upload) + me.FS + _
		  StringFromBoolean(uploadAnywhere) + me.FS + _
		  StringFromBoolean(createFolders) + me.FS + _
		  StringFromBoolean(alterFiles) + me.FS + _
		  StringFromBoolean(deleteFiles) + me.FS + _
		  StringFromBoolean(viewDropboxes) + me.FS + _
		  StringFromBoolean(createAccounts) + me.FS + _
		  StringFromBoolean(editAccounts) + me.FS + _
		  StringFromBoolean(deleteAccounts) + me.FS + _
		  StringFromBoolean(elevatePrivileges) + me.FS + _
		  StringFromBoolean(kickUsers) + me.FS + _
		  StringFromBoolean(banUsers) + me.FS + _
		  StringFromBoolean(cannotBeKicked) + me.FS + _
		  downloadSpeed.ToText + me.FS + _
		  uploadSpeed.ToText + me.FS + _
		  downloadLimit.ToText + me.FS + _
		  uploadLimit.ToText + me.FS + _
		  StringFromBoolean(changeTopic)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Write(data As String)
		  if (me.IsConnected) AND (not data.IsEmpty) then
		    Super.Write ConvertEncoding(data + me.EOT, Encodings.UTF8)
		    Super.Flush
		  end if
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event AccountExists(data() As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event AccountInfoReceived(login As String, password As String, group As String, getUserInfo As Boolean, broadcast As Boolean, postNews As Boolean, clearNews As Boolean, download As Boolean, upload As Boolean, uploadAnywhere As Boolean, createFolders As Boolean, alterFiles As Boolean, deleteFiles As Boolean, viewDropboxes As Boolean, createAccounts As Boolean, editAccounts As Boolean, deleteAccounts As Boolean, elevatePrivileges As Boolean, kickUsers As Boolean, banUsers As Boolean, cannotBeKicked As Boolean, downloadSpeed As UInt64, uploadSpeed As UInt64, downloadLimit As UInt64, uploadLimit As UInt64, changeTopic As Boolean)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event AccountListEnd()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event AccountListEntry(login As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event AccountNotFound(data() As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ChatReceived(chatID As Integer, userID As Integer, message As String, isAction As Boolean)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ChatTopicReceived(chatID As Integer, nick As String, login As String, IP As String, time As DateTime, topic As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Connected()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Error(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorAccountExists(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorAccountNotFound(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorBanned(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorCannotBeDisconnected(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorChecksumMismatch(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorClientNotFound(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorCommandFailed(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorCommandNotImplemented(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorCommandNotRecognized(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorFileExists(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorFileNotFound(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorLoginFailed(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorPermissionDenied(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorQueueLimitExceeded(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ErrorSyntaxError(message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event FileListEnd(path As String, free As UInt64)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event FileListEntry(path As String, type As Integer, size As UInt64, created As DateTime, modified As DateTime)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event GroupInfoReceived(name As String, getUserInfo As Boolean, broadcast As Boolean, postNews As Boolean, clearNews As Boolean, download As Boolean, upload As Boolean, uploadAnywhere As Boolean, createFolders As Boolean, alterFiles As Boolean, deleteFiles As Boolean, viewDropboxes As Boolean, createAccounts As Boolean, editAccounts As Boolean, deleteAccounts As Boolean, elevatePrivileges As Boolean, kickUsers As Boolean, banUsers As Boolean, cannotBeKicked As Boolean, downloadSpeed As UInt64, uploadSpeed As UInt64, downloadLimit As UInt64, uploadLimit As UInt64, changeTopic As Boolean)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event GroupListEnd()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event GroupListEntry(name As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event LoginSuccessful(myUserID As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event MessageReceived(userID As Integer, message As String, isBroadcast As Boolean)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event NewsListEnd()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event NewsListEntry(nick As String, time As DateTime, message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event NewsPosted(nick As String, time As DateTime, message As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event PongReceived()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event PrivateChatCreated(chatID As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event PrivateChatDeclined(chatID As Integer, userID As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event PrivateChatInvitationReceived(chatID As Integer, userID As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event PrivilegesReceived(getUserInfo As Boolean, broadcast As Boolean, postNews As Boolean, clearNews As Boolean, download As Boolean, upload As Boolean, uploadAnywhere As Boolean, createFolders As Boolean, alterFiles As Boolean, deleteFiles As Boolean, viewDropboxes As Boolean, createAccounts As Boolean, editAccounts As Boolean, deleteAccounts As Boolean, elevatePrivileges As Boolean, kickUsers As Boolean, banUsers As Boolean, cannotBeKicked As Boolean, downloadSpeed As UInt64, uploadSpeed As UInt64, downloadLimit As UInt64, uploadLimit As UInt64, changeTopic As Boolean)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event SearchListEnd()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event SearchListEntry(path As String, type As Integer, size As UInt64, created As DateTime, modified As DateTime)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ServerBannerReceived(serverBanner As Picture)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ServerInfoReceived(appVersion As String, protocolVersion As String, serverName As String, serverDescription As String, startTime As DateTime, filesCount As UInt64, filesSize As UInt64)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event TransferQueued(path As String, position As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event TransferReady(path As String, offset As UInt64, hash As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UserChanged(userID As Integer, isIdle As Boolean, isAdmin As Boolean, nick As String, status As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UserIconChanged(userID As Integer, icon As Picture)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UserInfoReceived(userID As Integer, isIdle As Boolean, isAdmin As Boolean, nick As String, login As String, IP As String, host As String, clientVersion As String, cipherName As String, cipherBits As Integer, loginTime As DateTime, idleTime As DateTime, downloads As String, uploads As String, status As String, icon As Picture)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UserJoined(chatID As Integer, userID As Integer, isIdle As Boolean, isAdmin As Boolean, nick As String, login As String, IP As String, host As String, status As String, icon As Picture)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UserKicked(victimID As Integer, killerID As Integer, message As String, isBan As Boolean)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UserLeft(chatID As Integer, userID As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UserListEnd(chatID As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UserListEntry(chatID As Integer, userID As Integer, isIdle As Boolean, isAdmin As Boolean, nick As String, login As String, IP As String, host As String, status As String, icon As Picture)
	#tag EndHook


	#tag Note, Name = UNLICENSE
		
		This is free and unencumbered software released into the public domain.
		
		Anyone is free to copy, modify, publish, use, compile, sell, or
		distribute this software, either in source code form or as a compiled
		binary, for any purpose, commercial or non-commercial, and by any
		means.
		
		In jurisdictions that recognize copyright laws, the author or authors
		of this software dedicate any and all copyright interest in the
		software to the public domain. We make this dedication for the benefit
		of the public at large and to the detriment of our heirs and
		successors. We intend this dedication to be an overt act of
		relinquishment in perpetuity of all present and future rights to this
		software under copyright law.
		
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
		OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
		ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
		OTHER DEALINGS IN THE SOFTWARE.
		
		For more information, please refer to <http://unlicense.org>
	#tag EndNote


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return me.mDataPort
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #Pragma Unused value
			End Set
		#tag EndSetter
		DataPort As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mBuffer As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBufferString As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDataPort As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDelegate As WeakRef
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHelloIsReceived As Boolean
	#tag EndProperty


	#tag Constant, Name = EOT, Type = Double, Dynamic = False, Default = \"&u04", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FS, Type = Double, Dynamic = False, Default = \"&u1C", Scope = Public
	#tag EndConstant

	#tag Constant, Name = GS, Type = Double, Dynamic = False, Default = \"&u1D", Scope = Public
	#tag EndConstant

	#tag Constant, Name = RS, Type = Double, Dynamic = False, Default = \"&u1E", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Address"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Port"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SSLConnectionType"
			Visible=true
			Group="Behavior"
			InitialValue="3"
			Type="SSLConnectionTypes"
			EditorType="Enum"
			#tag EnumValues
				"1 - SSLv23"
				"3 - TLSv1"
				"4 - TLSv11"
				"5 - TLSv12"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="SSLEnabled"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SSLConnected"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SSLConnecting"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BytesAvailable"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BytesLeftToSend"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastErrorCode"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CertificatePassword"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DataPort"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=false
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
