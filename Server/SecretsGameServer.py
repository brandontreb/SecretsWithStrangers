from gameServer.roomServer import RoomServer
from gameServer.messageHandler import MessageHandler
from gameServer.util.messageWriter import MessageWriter
import time
import datetime

MESSAGE_PLAYER_CONNECTED = 0
MESSAGE_PLAYER_DISCONNECTED = 1
MESSAGE_PLAYER_CHAT = 2
MESSAGE_BEGIN_CHAT = 6

IP_ADDRESS = "192.168.1.149"

class ChatServer(MessageHandler):
	def __init__(self):
		self.today = None
		self.logfile = None
		self.roomServer = RoomServer(self)
		self.openLog()	

	def start(self):
		self.roomServer.start(1955,IP_ADDRESS,1956)

	def handleMessage(self,messageId,message,player):
		
		print "Got " + str(messageId)
		
		if messageId == MESSAGE_PLAYER_CHAT:
			self.playerChat(player,message)
		elif messageId == MESSAGE_PLAYER_CONNECTED:
			self.playerCon(player)
		else:
			for p in player.room.players:
				if p != player:
					message.offset = 0
					outgoingMessage = MessageWriter()
					outgoingMessage.data = message.data
					p.protocol.sendMessage(outgoingMessage)
					
	def playerCon(self,player):		
		self.openLog()
		print "CONNECTED "  +str(len(player.room.players))
		# Close the room at 2
		if(len(player.room.players) == 2):
			print "Chat started in " + player.room.roomID
			player.room.open = False
			# Tell players its time to chat
			messageChatStart = MessageWriter()
			messageChatStart.writeByte(MESSAGE_BEGIN_CHAT)			
			messageChatStart.writeInt(1)
			for p in player.room.players:
				p.protocol.sendMessage(messageChatStart)

	def playerDisconnected(self,player):

		if player == None:
			return

		messagePlayerDisconnected = MessageWriter()
		messagePlayerDisconnected.writeByte(MESSAGE_PLAYER_DISCONNECTED)
		messagePlayerDisconnected.writeInt(player.playerID)

		# Notify the other players that the player disconnected
		if player.room and len(player.room.players) > 0:
			for p in player.room.players:			
				if p != player:			
					p.protocol.sendMessage(messagePlayerDisconnected)

	# MESSAGES
	
	def playerChat(self,player,message):		
		isSecret = message.readByte()
		chat = message.readString()
		t = time.strftime('%Y-%m-%d %H:%M:%S')
		print str(self.logfile) + str(isSecret) + " " + t + ": " + chat + "\n"					
		self.log(str(isSecret) + " " + t + ": " + chat + "\n")
		
		for p in player.room.players:
			# commented for testing
			if p != player:				
				# Forward the message on
				p.protocol.sendMessage(message)
	
	def log(self, string):
		self.logfile = open('./log/' + str(self.today) + ".txt", 'a')
		self.logfile.write(string)
		self.logfile.close()
	
	def openLog(self):
		#update the log file if the day changes
		if(self.today != datetime.date.today()):			
			self.today = datetime.date.today()
			print "Opening " + './log/' + str(self.today) + ".txt"
			if(self.logfile != None and self.logfile.closed() == False):
				self.logfile.close()
			self.log("Secrets With Strangers\n")
	

chatServer = ChatServer()
chatServer.start()
