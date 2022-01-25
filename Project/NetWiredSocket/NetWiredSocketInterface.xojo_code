#tag Interface
Protected Interface NetWiredSocketInterface
	#tag Method, Flags = &h0
		Sub AccountExists()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AccountInfoReceived(login As String, password As String, group As String, getUserInfo As Boolean, broadcast As Boolean, postNews As Boolean, clearNews As Boolean, download As Boolean, upload As Boolean, uploadAnywhere As Boolean, createFolders As Boolean, alterFiles As Boolean, deleteFiles As Boolean, viewDropboxes As Boolean, createAccounts As Boolean, editAccounts As Boolean, deleteAccounts As Boolean, elevatePrivileges As Boolean, kickUsers As Boolean, banUsers As Boolean, cannotBeKicked As Boolean, downloadSpeed As UInt64, uploadSpeed As UInt64, downloadLimit As UInt64, uploadLimit As UInt64, changeTopic As Boolean)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AccountListEnd()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AccountListEntry(login As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AccountNotFound()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ChatReceived(chatID As Integer, userID As Integer, message As String, isAction As Boolean)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ChatTopicReceived(chatID As Integer, nick As String, login As String, IP As String, time As DateTime, topic As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Connected()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Error(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorAccountExists(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorAccountNotFound(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorBanned(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorCannotBeDisconnected(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorChecksumMismatch(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorClientNotFound(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorCommandFailed(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorCommandNotImplemented(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorCommandNotRecognized(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorFileExists(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorFileNotFound(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorLoginFailed(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorPermissionDenied(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorQueueLimitExceeded(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorSyntaxError(message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FileListEnd(path As String, free As UInt64)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FileListEntry(path As String, type As Integer, size As UInt64, created As DateTime, modified As DateTime)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GroupInfoReceived(name As String, getUserInfo As Boolean, broadcast As Boolean, postNews As Boolean, clearNews As Boolean, download As Boolean, upload As Boolean, uploadAnywhere As Boolean, createFolders As Boolean, alterFiles As Boolean, deleteFiles As Boolean, viewDropboxes As Boolean, createAccounts As Boolean, editAccounts As Boolean, deleteAccounts As Boolean, elevatePrivileges As Boolean, kickUsers As Boolean, banUsers As Boolean, cannotBeKicked As Boolean, downloadSpeed As UInt64, uploadSpeed As UInt64, downloadLimit As UInt64, uploadLimit As UInt64, changeTopic As Boolean)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GroupListEnd()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GroupListEntry(name As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoginSuccessful(myUserID As Integer)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MessageReceived(userID As Integer, message As String, isBroadcast As Boolean)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NewsListEnd()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NewsListEntry(nick As String, time As DateTime, message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NewsPosted(nick As String, time As DateTime, message As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PongReceived()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PrivateChatCreated(chatID As Integer)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PrivateChatDeclined(chatID As Integer, userID As Integer)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PrivateChatInvitationReceived(chatID As Integer, userID As Integer)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PrivilegesReceived(getUserInfo As Boolean, broadcast As Boolean, postNews As Boolean, clearNews As Boolean, download As Boolean, upload As Boolean, uploadAnywhere As Boolean, createFolders As Boolean, alterFiles As Boolean, deleteFiles As Boolean, viewDropboxes As Boolean, createAccounts As Boolean, editAccounts As Boolean, deleteAccounts As Boolean, elevatePrivileges As Boolean, kickUsers As Boolean, banUsers As Boolean, cannotBeKicked As Boolean, downloadSpeed As UInt64, uploadSpeed As UInt64, downloadLimit As UInt64, uploadLimit As UInt64, changeTopic As Boolean)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SearchListEnd()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SearchListEntry(path As String, type As Integer, size As UInt64, created As DateTime, modified As DateTime)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ServerBannerReceived(serverBanner As Picture)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ServerInfoReceived(appVersion As String, protocolVersion As String, serverName As String, serverDescription As String, startTime As DateTime, filesCount As UInt64, filesSize As UInt64)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TransferQueued(path As String, position As Integer)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TransferReady(path As String, offset As UInt64, hash As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UserChanged(userID As Integer, isIdle As Boolean, isAdmin As Boolean, nick As String, status As String)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UserIconChanged(userID As Integer, icon As Picture)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UserInfoReceived(userID As Integer, isIdle As Boolean, isAdmin As Boolean, nick As String, login As String, IP As String, host As String, clientVersion As String, cipherName As String, cipherBits As Integer, loginTime As DateTime, idleTime As DateTime, downloads As String, uploads As String, status As String, icon As Picture)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UserJoined(chatID As Integer, userID As Integer, isIdle As Boolean, isAdmin As Boolean, nick As String, login As String, IP As String, host As String, status As String, icon As Picture)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UserKicked(victimID As Integer, killerID As Integer, message As String, isBan As Boolean)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UserLeft(chatID As Integer, userID As Integer)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UserListEnd(chatID As Integer)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UserListEntry(chatID As Integer, userID As Integer, isIdle As Boolean, isAdmin As Boolean, nick As String, login As String, IP As String, host As String, status As String, icon As Picture)
		  
		End Sub
	#tag EndMethod


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


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
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
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Interface
#tag EndInterface
