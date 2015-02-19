--[[

--]]
catherine.chat = catherine.chat or { }

if ( SERVER ) then



else
	catherine.chat.panels = catherine.chat.panels or nil
	
	local CHATBox_w, CHATBox_h = ScrW( ) * 0.25, ScrH( ) * 0.2
	local CHATBox_x, CHATBox_y = 10, ScrH( ) - CHATBox_h - 10
	
	function catherine.chat.SetStatus( bool )
		if ( bool ) then
			
			return
		end
		if ( !catherine.chat.panels ) then
			catherine.chat.panels = vgui.Create( "DPanel" )
			catherine.chat.panels:SetPos( CHATBox_x, CHATBox_y )
			catherine.chat.panels:SetSize( CHATBox_w, CHATBox_h )
		end
			local self = catherine.chat.panels
			
			self.entry = vgui.Create( "EditablePanel" )
			self.entry:SetPos(self.x + 4, self.y + self:GetTall() - 32)
			self.entry:SetWide(self:GetWide( ) - 8)
			self.entry.Paint = function(this, w, h)
			end
			self.entry:SetTall(28)

			nut.chat.history = nut.chat.history or {}

			self.text = self.entry:Add("DTextEntry")
			self.text:Dock(FILL)
			self.text.History = nut.chat.history
			self.text:SetHistoryEnabled(true)
			self.text:DockMargin(3, 3, 3, 3)
			self.text:SetFont("nutChatFont")
			self.text.OnEnter = function(this)
				local text = this:GetText()

				this:Remove()

				self.tabs:SetVisible(false)
				self.active = false
				self.entry:Remove()

				if (text:find("%S")) then
					if (!(nut.chat.lastLine or ""):find(text, 1, true)) then
						nut.chat.history[#nut.chat.history + 1] = text
						nut.chat.lastLine = text
					end

					netstream.Start("msg", text)
				end
			end
			self.text:SetAllowNonAsciiCharacters(true)
			self.text.Paint = function(this, w, h)
				surface.SetDrawColor(0, 0, 0, 100)
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawOutlinedRect(0, 0, w, h)

				this:DrawTextEntryText(TEXT_COLOR, nut.config.get("color"), TEXT_COLOR)
			end
			self.text.OnTextChanged = function(this)
				local text = this:GetText()

				hook.Run("ChatTextChanged", text)

				if (text:sub(1, 1) == "/") then
					self.arguments = nut.command.extractArgs(text:sub(2))
				end
			end

			self.entry:MakePopup()
			self.text:RequestFocus()
			self.tabs:SetVisible(true)

			hook.Run("StartChat")
			
	end
end