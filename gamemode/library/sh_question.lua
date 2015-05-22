--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

catherine.question = catherine.question or { }
catherine.question.lists = { multipleChoice = { }, descriptive = { } }
CAT_QUESTION_MULTIPLE_CHOICE = 1
CAT_QUESTION_DESCRIPTIVE = 2

function catherine.question.RegisterMultipleChoice( title, answerList, answerIndex )
	catherine.question.lists.multipleChoice[ #catherine.question.lists.multipleChoice + 1 ] = {
		title = title,
		answerList = answerList,
		answerIndex = answerIndex
	}
end

function catherine.question.RegisterDescriptive( title, defVal )
	catherine.question.lists.descriptive[ #catherine.question.lists.descriptive + 1 ] = {
		title = title,
		defVal = defVal
	}
end

function catherine.question.GetAllMultipleChoice( )
	return catherine.question.lists.multipleChoice
end

function catherine.question.GetAllDescriptive( )
	return catherine.question.lists.descriptive
end

function catherine.question.FindByIndex( typ, index )
	if ( typ == CAT_QUESTION_MULTIPLE_CHOICE ) then
		return catherine.question.lists.multipleChoice[ index ]
	elseif ( typ == CAT_QUESTION_DESCRIPTIVE ) then
		return catherine.question.lists.descriptive[ index ]
	end
end

if ( SERVER ) then
	function catherine.question.Start( pl )
		local data = {
			questions = { }
		}
		
		local questionType = catherine.question.GetQuestionType( )
		
		if ( questionType == CAT_QUESTION_MULTIPLE_CHOICE ) then
			local questions = catherine.question.GetAllMultipleChoice( )
			
			if ( #questions > 0 ) then
				data.questions = questions
				
				netstream.Start( pl, "catherine.question.Start", {
					questionType = questionType,
					questions = questions
				} )
			else
				print("Can't run - reason 1")
			end
		elseif ( questionType == CAT_QUESTION_DESCRIPTIVE ) then
			local questions = catherine.question.GetAllDescriptive( )
			
			if ( #questions > 0 ) then
				data.questions = questions
				
				netstream.Start( pl, "catherine.question.Start", {
					questionType = questionType,
					questions = questions
				} )
				
				data.juror = catherine.util.GetAdmins( )
				
				--[[
				for k, v in pairs( data.juror ) do
					if ( !IsValid( v ) or !v:IsPlayer( ) ) then continue end
					
					
				end--]]
			else
				print("Can't run - reason 2")
			end
		else
			print(" !")
		end
	end
	
	function catherine.question.CheckMultipleChoice( pl, answers )
		local questionTable = catherine.question.GetAllMultipleChoice( )
		
		if ( #questionTable == 0 ) then
			catherine.question.SetQuestionComplete( pl, "1" )
			netstream.Start( pl, "catherine.question.CloseMenu" )
			return
		end
		
		local answerIndexes = { }
		
		for k, v in pairs( questionTable ) do
			answerIndexes[ k ] = v.answerIndex
		end
		
		for k, v in pairs( answers ) do
			if ( v != answerIndexes[ k ] ) then
				pl:Kick( "Answer is not valid!" )
				return
			end
		end
		
		catherine.question.SetQuestionComplete( pl, "1" )
		netstream.Start( pl, "catherine.question.CloseMenu" )
	end
	
	function catherine.question.GetQuestionType( )
		local adminsCount = #catherine.util.GetAdmins( )
		local descriptiveCount = #catherine.question.GetAllDescriptive( )
		
		if ( adminsCount <= 0 or descriptiveCount == 0 and #catherine.question.GetAllMultipleChoice( ) > 0 ) then
			return CAT_QUESTION_MULTIPLE_CHOICE
		elseif ( adminsCount > 0 and descriptiveCount != 0 ) then
			return CAT_QUESTION_DESCRIPTIVE
		else
			return nil
		end
	end
	
	function catherine.question.SetQuestionComplete( pl, val )
		catherine.catData.SetVar( pl, "question", val, false, true )
	end
	
	--[[
	catherine.question.RegisterMultipleChoice( "1", ..., 2 )
	catherine.question.RegisterMultipleChoice( "2", ..., 1 )
	catherine.question.RegisterMultipleChoice( "3", ..., 3 )
	
	catherine.question.Check( pl, {
		questionType = CAT_QUESTION_MULTIPLE_CHOICE,
		answers = {
			2,
			1,
			3
		},
		answerIndexes = {
			2,
			1,
			3
		}
	} )
	--]]
	
	netstream.Hook( "catherine.question.CheckMultipleChoice", function( pl, data )
		catherine.question.CheckMultipleChoice( pl, data )
	end )
else
	netstream.Hook( "catherine.question.Start", function( data )
		// menu call;
	end )
	
	netstream.Hook( "catherine.question.CloseMenu", function( data )
		// menu close ;
	end )
end